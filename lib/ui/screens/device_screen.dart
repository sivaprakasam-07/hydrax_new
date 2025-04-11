// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'dart:typed_data';
// import 'package:permission_handler/permission_handler.dart';

// class DeviceScreen extends StatefulWidget {
//   final BluetoothDevice device;
//   const DeviceScreen({super.key, required this.device});

//   @override
//   State<DeviceScreen> createState() => _DeviceScreenState();
// }

// class _DeviceScreenState extends State<DeviceScreen> {
//   BluetoothConnection? connection;
//   final TextEditingController _controller = TextEditingController();
//   bool isConnected = false;

//   @override
//   void initState() {
//     super.initState();
//     checkBluetoothPermissions().then((_) {
//       connectToDevice();
//     });
//   }

//   Future<void> checkBluetoothPermissions() async {
//     final bluetoothStatus = await Permission.bluetooth.status;
//     final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
//     final bluetoothScanStatus = await Permission.bluetoothScan.status;

//     if (!bluetoothStatus.isGranted ||
//         !bluetoothConnectStatus.isGranted ||
//         !bluetoothScanStatus.isGranted) {
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: const Text("Permission Denied"),
//           content: const Text(
//             "Bluetooth permissions are required for this app to function. Please grant the necessary permissions.",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => openAppSettings(),
//               child: const Text("Go to Settings"),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   Future<void> connectToDevice() async {
//     try {
//       connection = await BluetoothConnection.toAddress(widget.device.address);
//       print('✅ Connected to ${widget.device.name}');
//       setState(() {
//         isConnected = true;
//       });
//     } catch (e) {
//       print('❌ Failed to connect: $e');
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: const Text("Connection Failed"),
//           content: Text(
//             "Could not connect to ${widget.device.name}. Please ensure the device is paired and powered on.",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   void sendMessage(String message) {
//     if (connection != null && connection!.isConnected) {
//       connection!.output.add(Uint8List.fromList(message.codeUnits));
//       connection!.output.allSent;
//       print("📤 Sent: $message");
//     }
//   }

//   @override
//   void dispose() {
//     connection?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.device.name ?? 'ESP32 Device')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               decoration: const InputDecoration(
//                 labelText: "Enter temperature (°C)",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: isConnected
//                   ? () {
//                       final msg = _controller.text.trim();
//                       if (msg.isNotEmpty) {
//                         sendMessage(msg);
//                         FocusScope.of(context).unfocus();
//                         _controller.clear();
//                       }
//                     }
//                   : null,
//               child: const Text("Send to ESP32"),
//             ),
//             const SizedBox(height: 20),
//             Text(isConnected ? "✅ Connected to ESP32" : "🔌 Not Connected"),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  const DeviceScreen({super.key, required this.device});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  BluetoothConnection? connection;
  final TextEditingController _controller = TextEditingController();
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    checkPermissionsAndConnect();
  }

  Future<void> checkPermissionsAndConnect() async {
    try {
      final statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse
      ].request();

      bool allGranted = statuses.values.every((status) => status.isGranted);

      if (!allGranted) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Permission Denied"),
              content: const Text(
                "Bluetooth and Location permissions are required. Please grant them in settings.",
              ),
              actions: [
                TextButton(
                  onPressed: () => openAppSettings(),
                  child: const Text("Go to Settings"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          );
        }
      } else {
        connectToDevice();
      }
    } catch (e) {
      print("Error checking permissions: $e");
    }
  }

  Future<void> connectToDevice() async {
    try {
      connection = await BluetoothConnection.toAddress(widget.device.address);
      print('✅ Connected to ${widget.device.name}');
      setState(() {
        isConnected = true;
      });
    } catch (e) {
      print('❌ Failed to connect: $e');
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Connection Failed"),
            content: Text(
              "Could not connect to ${widget.device.name}. Ensure the device is paired and powered on.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  void sendMessage(String message) {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList(message.codeUnits));
      connection!.output.allSent;
      print("📤 Sent: $message");
    }
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.name ?? 'ESP32 Device')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Enter temperature (°C)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConnected
                  ? () {
                      final msg = _controller.text.trim();
                      if (msg.isNotEmpty) {
                        sendMessage(msg);
                        FocusScope.of(context).unfocus();
                        _controller.clear();
                      }
                    }
                  : null,
              child: const Text("Send to ESP32"),
            ),
            const SizedBox(height: 20),
            Text(isConnected ? "✅ Connected to ESP32" : "🔌 Not Connected"),
          ],
        ),
      ),
    );
  }
}