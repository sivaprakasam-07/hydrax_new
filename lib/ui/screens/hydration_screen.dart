import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  _HydrationScreenState createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  List<double> hydrationData = [500, 750, 1000, 800, 1200, 900, 1100];

  void _updateChartData() {
    setState(() {
      hydrationData = List.from(hydrationData); // Create a new instance of the data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hydration Tracker'),
      ),
      body: Center(
        child: HydrationChart(
          key: UniqueKey(), // Assign a unique key to force rebuild
          hydrationData: hydrationData,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateChartData,
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class HydrationChart extends StatelessWidget {
  final List<double> hydrationData;

  const HydrationChart({
    super.key,
    this.hydrationData = const [500, 750, 1000, 800, 1200, 900, 1100],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent.withOpacity(0.2), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 3,
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 1500, // Adjust max value dynamically if needed
          backgroundColor: Colors.transparent,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${value.toInt()} ml',
                      style: TextStyle(fontSize: 12, color: theme.primaryColorDark),
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
                  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        days[value.toInt()],
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColorDark),
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                hydrationData.length,
                (index) => FlSpot(index.toDouble(), hydrationData[index]),
              ),
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, _) => true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 6,
                  color: Colors.blueAccent,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 1000,
                color: Colors.redAccent,
                strokeWidth: 2,
                dashArray: [5, 5],
              ),
            ],
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueAccent.withOpacity(0.8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toInt()} ml',
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
            touchCallback: (FlTouchEvent event, LineTouchResponse? response) {},
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }
}
