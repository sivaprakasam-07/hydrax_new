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
  bool isDiscovering = false;
  List<BluetoothDiscoveryResult> discoveredDevices = [];

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
        Permission.locationWhenInUse,
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
        startDiscovery(); // Start scanning for devices
      }
    } catch (e) {
      print("Error checking permissions: $e");
    }
  }

  Future<void> startDiscovery() async {
    try {
      setState(() {
        isDiscovering = true;
      });

      print("🔍 Scanning for devices...");
      discoveredDevices = [];

      FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
        setState(() {
          // Avoid duplicates
          if (!discoveredDevices.any((device) => device.device.address == result.device.address)) {
            discoveredDevices.add(result);
          }
        });
      }).onDone(() {
        setState(() {
          isDiscovering = false;
        });
      });

      print("✅ Found devices: ${discoveredDevices.map((d) => d.device.name).join(', ')}");
    } catch (e) {
      print("Error during discovery: $e");
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      print("📡 Attempting to connect to ${device.name}...");
      connection = await BluetoothConnection.toAddress(device.address);
      print('✅ Connected to ${device.name}');
      setState(() {
        isConnected = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Connected to ${device.name}')),
      );
    } catch (e) {
      print('❌ Failed to connect: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to connect to ${device.name}')),
      );
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
      appBar: AppBar(
        title: const Text("Nearby Bluetooth Devices"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: isDiscovering ? null : startDiscovery,
          ),
        ],
      ),
      body: Column(
        children: [
          isDiscovering
              ? const LinearProgressIndicator() // Show progress bar while discovering
              : const SizedBox.shrink(),
          Expanded(
            child: ListView.builder(
              itemCount: discoveredDevices.length,
              itemBuilder: (context, index) {
                final device = discoveredDevices[index].device;
                return ListTile(
                  title: Text(device.name ?? "Unknown Device"),
                  subtitle: Text(device.address),
                  trailing: Icon(Icons.bluetooth),
                  onTap: () => connectToDevice(device), // Connect on tap
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}