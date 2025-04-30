import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StateWiseCount extends StatefulWidget {
  const StateWiseCount({super.key});

  @override
  State<StateWiseCount> createState() => _StateWiseCountState();
}

class _StateWiseCountState extends State<StateWiseCount> {
  late List<StateChargingData> stateData;
  int selectedView = 0; // 0 for list, 1 for chart
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    stateData = getStateChargingData();
  }

  @override
  Widget build(BuildContext context) {
    // Filter states based on search query
    final filteredStates =
        stateData
            .where(
              (state) =>
                  state.name.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    // Sort states by charging count (descending)
    filteredStates.sort((a, b) => b.chargingCount.compareTo(a.chargingCount));

    // Calculate total charging stations
    final totalStations = stateData.fold(
      0,
      (sum, state) => sum + state.chargingCount,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'EV Charging Stations by State',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              selectedView == 0 ? Icons.bar_chart : Icons.list,
              color: Colors.green,
            ),
            onPressed: () {
              setState(() {
                selectedView = selectedView == 0 ? 1 : 0;
              });
            },
            tooltip: selectedView == 0 ? 'Show Chart' : 'Show List',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats summary card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade900,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Stations',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$totalStations',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'States/UTs',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${stateData.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.ev_station,
                      color: Colors.green.shade300,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search states...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.green),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          SizedBox(height: 16),

          // List/Chart view
          Expanded(
            child:
                selectedView == 0
                    ? _buildListView(filteredStates)
                    : _buildChartView(filteredStates),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<StateChargingData> states) {
    return ListView.builder(
      itemCount: states.length,
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final state = states[index];
        // Calculate percentage of total
        final totalStations = stateData.fold(
          0,
          (sum, state) => sum + state.chargingCount,
        );
        final percentage = (state.chargingCount / totalStations * 100)
            .toStringAsFixed(1);

        return Card(
          color: Colors.grey.shade900,
          elevation: 2,
          margin: EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              state.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value:
                      state.chargingCount / 200, // Assuming max is around 200
                  backgroundColor: Colors.grey.shade800,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getColorForCount(state.chargingCount),
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: 4),
                Text(
                  '$percentage% of total stations',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getColorForCount(state.chargingCount),
                  width: 1.5,
                ),
              ),
              child: Text(
                '${state.chargingCount}',
                style: TextStyle(
                  color: _getColorForCount(state.chargingCount),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartView(List<StateChargingData> states) {
    // Take top 10 states for the chart
    final topStates = states.take(10).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Top 10 States by Number of Charging Stations',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    topStates.isNotEmpty
                        ? (topStates.first.chargingCount * 1.2).toDouble()
                        : 200,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${topStates[groupIndex].name}\n',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${rod.toY.round()} stations',
                            style: TextStyle(
                              color: _getColorForCount(rod.toY.round()),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < topStates.length) {
                          String name = topStates[value.toInt()].name;
                          // Abbreviate long state names
                          if (name.length > 8) {
                            name = name.substring(0, 6) + '...';
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              name,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('');
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade800,
                      strokeWidth: 0.5,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups:
                    topStates.asMap().entries.map((entry) {
                      int index = entry.key;
                      StateChargingData state = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: state.chargingCount.toDouble(),
                            color: _getColorForCount(state.chargingCount),
                            width: 20,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: Colors.grey, size: 16),
                SizedBox(width: 8),
                Text(
                  "Tap on chart for more details",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForCount(int count) {
    if (count > 100) return Colors.green.shade400;
    if (count > 50) return Colors.green.shade300;
    if (count > 20) return Colors.lightGreen.shade400;
    return Colors.lightGreen.shade300;
  }

  List<StateChargingData> getStateChargingData() {
    return [
      StateChargingData("Andhra Pradesh", 65),
      StateChargingData("Arunachal Pradesh", 4),
      StateChargingData("Assam", 19),
      StateChargingData("Bihar", 26),
      StateChargingData("Chandigarh", 4),
      StateChargingData("Chhattisgarh", 51),
      StateChargingData("Delhi", 66),
      StateChargingData("Goa", 17),
      StateChargingData("Gujarat", 87),
      StateChargingData("Haryana", 114),
      StateChargingData("Himachal Pradesh", 13),
      StateChargingData("Jharkhand", 22),
      StateChargingData("Jammu and Kashmir", 3),
      StateChargingData("Karnataka", 100),
      StateChargingData("Kerala", 39),
      StateChargingData("Leh", 2),
      StateChargingData("Madhya Pradesh", 167),
      StateChargingData("Maharashtra", 88),
      StateChargingData("Manipur", 1),
      StateChargingData("Meghalaya", 3),
      StateChargingData("Nagaland", 2),
      StateChargingData("Odisha", 26),
      StateChargingData("Pondicherry", 2),
      StateChargingData("Punjab", 41),
      StateChargingData("Rajasthan", 174),
      StateChargingData("Tamil Nadu", 76),
      StateChargingData("Telangana", 112),
      StateChargingData("Tripura", 3),
      StateChargingData("Uttar Pradesh", 128),
      StateChargingData("Uttarakhand", 10),
      StateChargingData("West Bengal", 71),
    ];
  }
}

class StateChargingData {
  final String name;
  final int chargingCount;

  StateChargingData(this.name, this.chargingCount);
}
