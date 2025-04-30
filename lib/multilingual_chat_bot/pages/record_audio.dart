import 'package:flutter/material.dart';
import 'package:flutter_ar/multilingual_chat_bot/services/langchain_service.dart';
import 'package:flutter_ar/multilingual_chat_bot/services/speak_words.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:avatar_glow/avatar_glow.dart';

class RecordAudio extends StatefulWidget {
  const RecordAudio({super.key});

  @override
  State<RecordAudio> createState() => _RecordAudioState();
}

class _RecordAudioState extends State<RecordAudio> {
  SpeechToText speechToText = SpeechToText();
  String text = "Hold the button to start speaking";
  bool isListening = false;
  bool isProcessing = false;
  List<Map<String, String>> chatMessages = []; // To store chat history

  void startListening() async {
    bool available = await speechToText.initialize();
    if (available) {
      setState(() {
        isListening = true;
      });
      speechToText.listen(
        onResult: (result) {
          setState(() {
            text = result.recognizedWords;
          });
        },
      );
    }
  }

  void stopListening() async {
    setState(() {
      isListening = false;
      isProcessing = true;
    });
    speechToText.stop();

    if (text.isNotEmpty) {
      // Add the user's question to the chat
      setState(() {
        chatMessages.add({"role": "user", "message": text});
      });

      print("Passing the text to AI");
      print(text);
      String ans = await sendMessage(text);
      print("AI response received");

      // Add the AI's response to the chat
      setState(() {
        chatMessages.add({"role": "ai", "message": ans.replaceAll("*", "")});
      });

      await speak(ans.replaceAll("*", ""));

      setState(() {
        isProcessing = false;
      });
      print("Done");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.greenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final message = chatMessages[index];
                  final isUser = message["role"] == "user";
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.green.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        message["message"] ?? "",
                        style: TextStyle(
                          color: isUser ? Colors.black : Colors.green.shade800,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isProcessing)
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Image.network(
                  height: 100,
                  width: 100,
                  "https://mir-s3-cdn-cf.behance.net/project_modules/disp/998fe3171675349.6472d19e31239.gif",
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          isProcessing
              ? null
              : AvatarGlow(
                animate: isListening,
                duration: const Duration(seconds: 2),
                glowColor: Colors.green.shade400,
                repeat: true,
                startDelay: const Duration(milliseconds: 100),
                child: GestureDetector(
                  onTapDown: (_) => startListening(),
                  onTapUp: (_) => stopListening(),
                  child: CircleAvatar(
                    backgroundColor: Colors.green.shade900,
                    radius: 45,
                    child: Icon(
                      isListening ? Icons.pause : Icons.mic,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ),
    );
  }
}
