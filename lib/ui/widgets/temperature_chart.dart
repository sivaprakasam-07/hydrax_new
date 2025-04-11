import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TemperatureChart extends StatefulWidget {
  final List<double> temperatureValues;
  final List<double> maxTemperatureValues; // ✅ For Gray Background Rods

  const TemperatureChart({super.key, 
    required this.temperatureValues,
    required this.maxTemperatureValues,
  });

  @override
  _TemperatureChartState createState() => _TemperatureChartState();
}

class _TemperatureChartState extends State<TemperatureChart> {
  List<BarChartGroupData> barData = [];

  @override
  void initState() {
    super.initState();
    loadTemperatureData();
  }

  void loadTemperatureData() {
    List<BarChartGroupData> bars = List.generate(widget.temperatureValues.length, (index) {
      return BarChartGroupData(
        x: index + 1,
        barRods: [
          _buildRod(widget.temperatureValues[index]), // Actual Temperature (Blue)
        ],
      );
    });

    setState(() {
      barData = bars;
    });
  }

  BarChartRodData _buildRod(double temperature) {
    return BarChartRodData(
      toY: temperature,
      width: 18,
      gradient: LinearGradient(colors: [Colors.blue, Colors.cyan]), // ✅ Gradient Effect
      borderRadius: BorderRadius.circular(6),
      backDrawRodData: BackgroundBarChartRodData(
        show: true,
        toY: 50, // ✅ Max Temperature (50°C)
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
            "Temperature Trend",
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
                          "${value.toInt()}°C",
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
                        "${rod.toY.toStringAsFixed(1)}°C",
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
