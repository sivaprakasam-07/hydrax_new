import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HydrationChart extends StatefulWidget {
  const HydrationChart({super.key});

  @override
  _HydrationChartState createState() => _HydrationChartState();
}

class _HydrationChartState extends State<HydrationChart> {
  List<BarChartGroupData> barData = [];

  @override
  void initState() {
    super.initState();
    loadPlaceholderData(); // Using placeholder values for now
  }

  void loadPlaceholderData() {
    List<BarChartGroupData> bars = [
      BarChartGroupData(x: 1, barRods: [_buildRod(2.5)]),
      BarChartGroupData(x: 2, barRods: [_buildRod(3.0)]),
      BarChartGroupData(x: 3, barRods: [_buildRod(1.8)]),
      BarChartGroupData(x: 4, barRods: [_buildRod(2.2)]),
      BarChartGroupData(x: 5, barRods: [_buildRod(4.0)]),
      BarChartGroupData(x: 6, barRods: [_buildRod(3.5)]),
      BarChartGroupData(x: 7, barRods: [_buildRod(2.8)]),
    ];

    setState(() {
      barData = bars;
    });
  }

  BarChartRodData _buildRod(double litres) {
    return BarChartRodData(
      toY: litres,
      width: 18,
      gradient: LinearGradient(colors: [Colors.blue, Colors.cyan]),
      borderRadius: BorderRadius.circular(6),
      backDrawRodData: BackgroundBarChartRodData(
        show: true,
        toY: 5, // Max capacity is 5L
        color: Colors.grey.withOpacity(0.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Hydration Trend",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                barGroups: barData,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${value.toInt()}L",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "Day ${value.toInt()}",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueAccent.withOpacity(0.8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        "${rod.toY.toStringAsFixed(1)}L",
                        TextStyle(color: Colors.white, fontSize: 14),
                      );
                    },
                  ),
                  touchCallback: (event, response) {},
                  handleBuiltInTouches: true,
                ),
              ),
              swapAnimationDuration: Duration(milliseconds: 500),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}

