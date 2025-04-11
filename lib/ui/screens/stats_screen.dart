import 'package:flutter/material.dart';
import '../widgets/hydration_chart.dart';

class StatsScreen extends StatelessWidget {
  final List<String> temperatureLogs = [
    "Monday: 500ml - 25°C",
    "Tuesday: 600ml - 24°C",
    "Wednesday: 750ml - 26°C",
    "Thursday: 500ml - 23°C",
    "Friday: 900ml - 27°C"
  ];

  StatsScreen({super.key}); // 🔥 Replace this with Firebase data later.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hydration Stats'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 Hydration Chart Section
            _buildSectionTitle(context, 'Water Intake History'),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: HydrationChart(),
            ),

            SizedBox(height: 20), // ✅ Space to avoid overlap
            Divider(),

            // 🌡️ Temperature Logs Section
            _buildSectionTitle(context, 'Temperature Logs'),
            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true, // ✅ Prevents unnecessary scrolling issues
                physics: NeverScrollableScrollPhysics(), // ✅ Uses parent scrolling
                itemCount: temperatureLogs.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      title: Text(
                        temperatureLogs[index],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      leading: Icon(Icons.thermostat, color: Colors.blue),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20), // ✅ Extra padding at the bottom
          ],
        ),
      ),
    );
  }

  // 🔹 Section Title Widget
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
    );
  }
}
