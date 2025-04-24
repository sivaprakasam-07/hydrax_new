import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import '../../services/bluetooth_controller.dart';

class DeviceScreen extends StatelessWidget {
  final BluetoothController bluetoothController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Bluetooth Devices")),
      body: Obx(() {
        if (bluetoothController.isDiscovering.value) {
          return const LinearProgressIndicator();
        }

        if (bluetoothController.devices.isEmpty) {
          return const Center(child: Text("No devices found"));
        }

        return ListView.builder(
          itemCount: bluetoothController.devices.length,
          itemBuilder: (context, index) {
            final device = bluetoothController.devices[index];
            return ListTile(
              title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
              subtitle: Text(device.id.toString()),
              trailing: Icon(Icons.bluetooth),
              onTap: () {
                bluetoothController.stopDiscovery(); // Correctly call stopDiscovery
                Navigator.pop(context, device); // Return selected device
              },
            );
          },
        );
      }),
    );
  }
}