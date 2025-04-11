// // import 'package:flutter/material.dart';
// // import '../widgets/temperature_chart.dart';

// // class TemperatureScreen extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Temperature Logs")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text("Temperature Usage", 
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
// //             ),
// //             SizedBox(height: 10),
// //             Expanded(
// //               child: TemperatureChart(
// //                 temperatureValues: [], // Add appropriate values
// //                 maxTemperatureValues: [], // Add appropriate values
// //               ), // ✅ Display Temperature Chart
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';
// import '../widgets/temperature_chart.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class TemperatureScreen extends StatefulWidget {
//   @override
//   _TemperatureScreenState createState() => _TemperatureScreenState();
// }

// class _TemperatureScreenState extends State<TemperatureScreen> {
//   double selectedTemperature = 25.0; // Default value

//   // Function to handle temperature selection and store in Firestore
//   void _fixTemperature() async {
//     try {
//       // Create a Firestore reference
//       final docRef = FirebaseFirestore.instance.collection('temperatureLogs').doc();

//       // Prepare data to store
//       Map<String, dynamic> temperatureData = {
//         'temperature': selectedTemperature,
//         'timestamp': FieldValue.serverTimestamp(),
//       };

//       // Save data to Firestore
//       await docRef.set(temperatureData);

//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Temperature fixed at $selectedTemperature°C')),
//       );
//     } catch (e) {
//       // Handle errors gracefully
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: Failed to fix temperature!')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Temperature Logs")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title
//             const Text(
//               "Temperature Usage",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),

//             // Temperature Slider
//             Row(
//               children: [
//                 Expanded(
//                   child: Slider(
//                     value: selectedTemperature,
//                     min: 10.0,
//                     max: 50.0,
//                     divisions: 40,
//                     label: '${selectedTemperature.round()}°C',
//                     onChanged: (value) {
//                       setState(() {
//                         selectedTemperature = value;
//                       });
//                     },
//                   ),
//                 ),
//                 Text(
//                   '${selectedTemperature.round()}°C',
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),

//             // Fix Temperature Button
//             Center(
//               child: ElevatedButton(
//                 onPressed: _fixTemperature,
//                 child: const Text('Fix Temperature'),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Temperature Chart
//             Expanded(
//               child: TemperatureChart(
//                 temperatureValues: [], // Add appropriate values dynamically
//                 maxTemperatureValues: [], // Add appropriate values dynamically
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:hydrax/services/firebase_service.dart';

class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key});

  @override
  _TemperatureScreenState createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  List<Map<String, dynamic>> _temperatureLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchTemperatureLogs();
  }

  // ✅ Fetch Temperature Logs
  Future<void> _fetchTemperatureLogs() async {
    List<Map<String, dynamic>> logs = await FirebaseService().getTemperatureLogs();
    setState(() {
      _temperatureLogs = logs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Logs'),
      ),
      body: _temperatureLogs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _temperatureLogs.length,
              itemBuilder: (context, index) {
                var log = _temperatureLogs[index];
                return ListTile(
                  leading: const Icon(Icons.thermostat),
                  title: Text('${log['temperature']}°C'),
                  subtitle: Text(
                    'Logged at: ${log['timestamp'].toString()}',
                  ),
                );
              },
            ),
    );
  }
}
