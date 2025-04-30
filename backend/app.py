from flask import Flask, request, jsonify
from langchain_groq import ChatGroq
from dotenv import load_dotenv
from langchain_core.messages import HumanMessage, SystemMessage
import firebase_admin
from firebase_admin import credentials, firestore
import os
from datetime import datetime
import re

load_dotenv()

# Initialize Firebase
cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "credential.json")
cred = credentials.Certificate(cred_path)
firebase_admin.initialize_app(cred)
db = firestore.client()

# Initialize LLM
llm = ChatGroq(
    model="llama-3.1-8b-instant",
    temperature=0,
    max_tokens=None,
    timeout=None,
    max_retries=2,
)

app = Flask(__name__)

# Store chat history in memory
chat_history = [
    SystemMessage(
        "You are a Smart Manufacturing AI assistant specialized in answering questions related to assets, maintenance, "
        "and worker tasks. You have access to a database with information about asset status, maintenance schedules, "
        "assigned tasks, and worker activities. Provide clear, concise, and accurate responses based on the available data. "
        "If I provide you with database information, focus on that data in your response. "
        "If I don't provide database information, clearly state 'I have no current info about this in the database' "
        "and avoid making up specific numbers or details that aren't in the data provided. "
        "If the question is unrelated to manufacturing assets or maintenance, politely inform the user that you specialize in "
        "manufacturing asset maintenance and worker task management."
    )
]

@app.route("/chat", methods=["POST"])
def chat():
    data = request.get_json()
    user_input = data.get("message")
    
    if not user_input:
        return jsonify({"error": "Message is required"}), 400
    
    # Check if query involves database access
    database_query = check_if_database_query(user_input)
    
    # If it's a database query, first fetch the relevant data
    firestore_data = None
    summarized_data = ""
    database_used = False
    
    if database_query:
        query_type = determine_query_type(user_input)
        firestore_data = query_firestore(query_type)
        
        # Append relevant data to the user's query for context
        if firestore_data and len(firestore_data) > 0:
            summarized_data = summarize_data(firestore_data, query_type)
            context = f"Here is the information from the database: {summarized_data} "
            user_input = context + user_input
            database_used = True
        else:
            # No data found in database
            no_data_context = "I checked the database but found no relevant information for this query. Please respond with 'I have no current info about this in the database' and avoid speculating. "
            user_input = no_data_context + user_input
    
    # Add new user input to history
    human_message = HumanMessage(user_input)
    chat_history.append(human_message)
    
    # Get AI response
    response = llm.invoke(chat_history)
    
    # If this was a database query but no data was found, ensure the response clearly states that
    if database_query and not database_used:
        content = response.content
        # Check if the AI's response already mentions the lack of data
        if not re.search(r"no (current |available )?info(rmation)?|don't have (the |any )?data", content.lower()):
            modified_content = "I have no current info about this in the database. " + content
            response.content = modified_content
    
    chat_history.append(response)
    
    # Store conversation in Firestore
    conversation_ref = db.collection('conversations').document()
    conversation_ref.set({
        'user_message': data.get("message"),  # Original user message
        'ai_response': response.content,
        'timestamp': firestore.SERVER_TIMESTAMP,
        'database_data_used': database_used,
        'query_type': determine_query_type(user_input) if database_query else "general"
    })
    
    return jsonify({
        "response": response.content,
        "message_count": len(chat_history) - 1,  # Excluding system message
        "database_data_used": database_used,
        "summarized_data": summarized_data if summarized_data else None
    })

def check_if_database_query(query):
    """Check if the user query is likely requesting asset or task database information."""
    # Asset and maintenance related keywords
    database_keywords = [
        "asset", "pump", "station", "maintenance", "repair", "status",
        "worker", "assigned", "task", "completed", "schedule", "last serviced", "next service",
        "under maintenance", "operational", "location", "coordinates", "performance",
        "how many", "count", "when", "date", "who", "responsible", "worker"
    ]
    
    return any(keyword in query.lower() for keyword in database_keywords)

def determine_query_type(query):
    """Determine what type of query the user is asking."""
    query = query.lower()
    
    if any(word in query for word in ["maintenance", "next service", "last service", "schedule"]):
        return "maintenance_info"
    elif any(word in query for word in ["status", "condition", "working", "operational", "completed"]):
        return "status_info"
    elif any(word in query for word in ["worker", "assigned", "responsible", "who"]):
        return "worker_info"
    elif any(word in query for word in ["location", "where", "coordinates"]):
        return "location_info"
    elif any(word in query for word in ["asset", "pump", "equipment"]):
        return "asset_info"
    elif any(word in query for word in ["task", "assignment", "work"]):
        return "task_info"
    else:
        return "general_info"

def query_firestore(query_type):
    """Query Firestore for relevant data based on query type."""
    try:
        results = []
        
        # Check if users collection exists
        collections = [coll.id for coll in db.collections()]
        if "users" not in collections:
            print("Collection 'users' does not exist in Firestore")
            return []
        
        if query_type == "worker_info":
            # Get worker information
            users = db.collection("users").where("role", "==", "worker").get()
            for user in users:
                user_data = user.to_dict()
                user_data["id"] = user.id
                
                # Get tasks for this user
                tasks = db.collection("users").document(user.id).collection("assignedTasks").get()
                user_data["task_count"] = len([t for t in tasks])
                
                results.append(user_data)
                
        elif query_type == "maintenance_info":
            # Get maintenance information for all assets
            users = db.collection("users").get()
            for user in users:
                user_id = user.id
                tasks = db.collection("users").document(user_id).collection("assignedTasks").get()
                
                for task in tasks:
                    task_data = task.to_dict()
                    if "lastMaintenance" in task_data or "nextMaintenance" in task_data:
                        task_data["id"] = task.id
                        task_data["user_id"] = user_id
                        task_data["user_name"] = user.to_dict().get("name", "Unknown")
                        results.append(task_data)
                
        elif query_type == "status_info":
            # Get status information for all assets
            users = db.collection("users").get()
            for user in users:
                user_id = user.id
                tasks = db.collection("users").document(user_id).collection("assignedTasks").get()
                
                for task in tasks:
                    task_data = task.to_dict()
                    if "status" in task_data:
                        task_data["id"] = task.id
                        task_data["user_id"] = user_id
                        task_data["user_name"] = user.to_dict().get("name", "Unknown")
                        results.append(task_data)
                
        elif query_type == "location_info":
            # Get location information for all assets
            users = db.collection("users").get()
            for user in users:
                user_id = user.id
                tasks = db.collection("users").document(user_id).collection("assignedTasks").get()
                
                for task in tasks:
                    task_data = task.to_dict()
                    if "coordinates" in task_data:
                        task_data["id"] = task.id
                        task_data["user_id"] = user_id
                        task_data["user_name"] = user.to_dict().get("name", "Unknown")
                        results.append(task_data)
                
        elif query_type == "asset_info":
            # Get general asset information
            users = db.collection("users").get()
            asset_map = {}
            
            for user in users:
                user_id = user.id
                tasks = db.collection("users").document(user_id).collection("assignedTasks").get()
                
                for task in tasks:
                    task_data = task.to_dict()
                    if "assetName" in task_data:
                        asset_name = task_data["assetName"]
                        if asset_name not in asset_map:
                            asset_map[asset_name] = task_data
                            asset_map[asset_name]["id"] = task.id
                            asset_map[asset_name]["user_id"] = user_id
                            asset_map[asset_name]["user_name"] = user.to_dict().get("name", "Unknown")
            
            results = list(asset_map.values())
                
        elif query_type == "task_info":
            # Get all task information
            users = db.collection("users").get()
            for user in users:
                user_id = user.id
                user_name = user.to_dict().get("name", "Unknown")
                tasks = db.collection("users").document(user_id).collection("assignedTasks").get()
                
                for task in tasks:
                    task_data = task.to_dict()
                    task_data["id"] = task.id
                    task_data["user_id"] = user_id
                    task_data["user_name"] = user_name
                    results.append(task_data)
                
        else:  # general_info
            # Get a summary of all data
            users = db.collection("users").get()
            worker_count = 0
            task_count = 0
            completed_tasks = 0
            
            for user in users:
                user_data = user.to_dict()
                if user_data.get("role") == "worker":
                    worker_count += 1
                    
                user_id = user.id
                tasks = db.collection("users").document(user_id).collection("assignedTasks").get()
                
                user_tasks = 0
                for task in tasks:
                    task_data = task.to_dict()
                    user_tasks += 1
                    if task_data.get("status") == "Completed":
                        completed_tasks += 1
                
                task_count += user_tasks
            
            results = [{
                "worker_count": worker_count,
                "task_count": task_count,
                "completed_tasks": completed_tasks,
                "completion_rate": completed_tasks / task_count if task_count > 0 else 0
            }]
            
        return results
        
    except Exception as e:
        print(f"Error querying Firestore: {e}")
        return []

def summarize_data(data, query_type):
    """Summarize data based on query type for better context."""
    if not data:
        return "No data available in the database for this query."
    
    if query_type == "worker_info":
        worker_count = len(data)
        task_summary = sum(worker.get("task_count", 0) for worker in data)
        
        worker_info = []
        for worker in data[:3]:  # Limit to top 3 workers
            name = worker.get("name", "Unknown")
            tasks = worker.get("task_count", 0)
            worker_info.append(f"{name} ({tasks} tasks)")
        
        return f"Found {worker_count} workers with a total of {task_summary} assigned tasks. Some workers include: {', '.join(worker_info)}"
        
    elif query_type == "maintenance_info":
        asset_count = len(data)
        
        # Group assets by maintenance dates
        upcoming_maintenance = []
        for asset in data[:5]:
            name = asset.get("assetName", "Unknown asset")
            next_date = asset.get("nextMaintenance", "Unknown")
            last_date = asset.get("lastMaintenance", "Unknown")
            upcoming_maintenance.append(f"{name} (Last: {last_date}, Next: {next_date})")
            
        return f"Maintenance information for {asset_count} assets: {'; '.join(upcoming_maintenance)}"
        
    elif query_type == "status_info":
        asset_count = len(data)
        completed = sum(1 for asset in data if asset.get("status") == "Completed")
        pending = asset_count - completed
        
        status_summary = f"Status summary for {asset_count} assets: {completed} completed, {pending} pending or in progress."
        
        # Add details for a few assets
        asset_details = []
        for asset in data[:3]:
            name = asset.get("assetName", "Unknown asset")
            status = asset.get("status", "Unknown")
            asset_details.append(f"{name} ({status})")
            
        return f"{status_summary} Examples: {', '.join(asset_details)}"
        
    elif query_type == "location_info":
        asset_count = len(data)
        
        location_info = []
        for asset in data[:3]:
            name = asset.get("assetName", "Unknown asset")
            coords = asset.get("coordinates", {})
            lat = coords.get("latitude", "Unknown")
            lon = coords.get("longitude", "Unknown")
            location_info.append(f"{name} (Lat: {lat}, Long: {lon})")
            
        return f"Location information for {asset_count} assets: {'; '.join(location_info)}"
        
    elif query_type == "asset_info":
        asset_count = len(data)
        
        asset_types = {}
        for asset in data:
            asset_type = asset.get("assetType", "Unknown")
            if asset_type in asset_types:
                asset_types[asset_type] += 1
            else:
                asset_types[asset_type] = 1
        
        type_summary = ", ".join([f"{count} {asset_type}s" for asset_type, count in asset_types.items()])
        
        asset_list = []
        for asset in data[:5]:
            name = asset.get("assetName", "Unknown")
            asset_type = asset.get("assetType", "Unknown")
            asset_list.append(f"{name} ({asset_type})")
            
        return f"Found {asset_count} assets ({type_summary}). Some assets include: {', '.join(asset_list)}"
        
    elif query_type == "task_info":
        task_count = len(data)
        completed = sum(1 for task in data if task.get("status") == "Completed")
        pending = task_count - completed
        
        worker_tasks = {}
        for task in data:
            worker = task.get("user_name", "Unknown")
            if worker in worker_tasks:
                worker_tasks[worker] += 1
            else:
                worker_tasks[worker] = 1
                
        worker_summary = ", ".join([f"{worker}: {count} tasks" for worker, count in list(worker_tasks.items())[:3]])
        
        return f"Task summary: {task_count} total tasks, {completed} completed, {pending} pending. Distribution among workers: {worker_summary}"
        
    else:  # general_info
        summary = data[0]
        worker_count = summary.get("worker_count", 0)
        task_count = summary.get("task_count", 0)
        completed = summary.get("completed_tasks", 0)
        completion_rate = summary.get("completion_rate", 0) * 100
        
        return f"The database contains information on {worker_count} workers with a total of {task_count} tasks. Overall completion rate: {completion_rate:.1f}%."

@app.route("/clear", methods=["POST"])
def clear_history():
    global chat_history
    # Reset chat history, keeping only the system message
    chat_history = [chat_history[0]]
    return jsonify({"status": "success", "message": "Chat history cleared"})

@app.route("/dashboard", methods=["GET"])
def dashboard():
    """Endpoint for getting dashboard statistics about assets and workers."""
    try:
        # Check if collection exists
        if "users" not in [coll.id for coll in db.collections()]:
            return jsonify({
                "error": "Collection 'users' does not exist in Firestore",
                "available_collections": [coll.id for coll in db.collections()]
            }), 404
            
        # Get all users
        users = db.collection("users").get()
        
        # Initialize counters and data structures
        worker_count = 0
        workers = []
        asset_count = 0
        assets_by_type = {}
        tasks_completed = 0
        tasks_pending = 0
        upcoming_maintenance = []
        
        for user in users:
            user_data = user.to_dict()
            user_id = user.id
            
            # Count workers
            if user_data.get("role") == "worker":
                worker_count += 1
                worker_info = {
                    "id": user_id,
                    "name": user_data.get("name", "Unknown"),
                    "email": user_data.get("email", ""),
                    "lastLogin": user_data.get("lastLogin", ""),
                    "tasks": {
                        "completed": 0,
                        "pending": 0
                    }
                }
                
                # Get tasks for this worker
                tasks = db.collection("users").document(user_id).collection("assignedTasks").get()
                for task in tasks:
                    task_data = task.to_dict()
                    
                    # Count task status
                    if task_data.get("status") == "Completed":
                        tasks_completed += 1
                        worker_info["tasks"]["completed"] += 1
                    else:
                        tasks_pending += 1
                        worker_info["tasks"]["pending"] += 1
                    
                    # Count assets by type
                    asset_type = task_data.get("assetType", "Unknown")
                    if asset_type in assets_by_type:
                        assets_by_type[asset_type] += 1
                    else:
                        assets_by_type[asset_type] = 1
                        
                    # Track unique assets
                    asset_count += 1
                    
                    # Check for upcoming maintenance
                    next_maintenance = task_data.get("nextMaintenance")
                    if next_maintenance:
                        try:
                            # Parse date string
                            next_date = datetime.strptime(next_maintenance, "%Y-%m-%d")
                            now = datetime.now()
                            
                            # If maintenance is due within the next 30 days
                            days_remaining = (next_date - now).days
                            if 0 <= days_remaining <= 30:
                                upcoming_maintenance.append({
                                    "asset": task_data.get("assetName", "Unknown asset"),
                                    "type": task_data.get("assetType", "Unknown"),
                                    "next_date": next_maintenance,
                                    "days_remaining": days_remaining,
                                    "assigned_to": user_data.get("name", "Unknown")
                                })
                        except ValueError:
                            # Skip if date format is invalid
                            pass
                
                workers.append(worker_info)
                
        # Sort upcoming maintenance by days remaining
        upcoming_maintenance.sort(key=lambda x: x["days_remaining"])
                
        return jsonify({
            "summary": {
                "worker_count": worker_count,
                "asset_count": asset_count,
                "tasks_completed": tasks_completed,
                "tasks_pending": tasks_pending,
                "completion_rate": tasks_completed / (tasks_completed + tasks_pending) if (tasks_completed + tasks_pending) > 0 else 0
            },
            "workers": workers,
            "assets": {
                "by_type": assets_by_type
            },
            "upcoming_maintenance": upcoming_maintenance[:5],  # Top 5 most urgent
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)