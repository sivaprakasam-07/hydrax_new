import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  var devices = <BluetoothDevice>[].obs; // List of discovered devices
  var isDiscovering = false.obs; // Discovery state

  void startDiscovery() async {
    try {
      isDiscovering.value = true;
      devices.clear(); // Clear the list before starting a new scan

      // Start scanning for devices
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      // Listen to scan results and update the devices list
      FlutterBluePlus.scanResults.listen((results) {
        devices.value = results.map((result) => result.device).toList();
      });

      // Stop discovery after the timeout
      FlutterBluePlus.isScanning.listen((scanning) {
        if (!scanning) {
          isDiscovering.value = false;
        }
      });
    } catch (e) {
      print("Error during discovery: $e");
      isDiscovering.value = false;
    }
  }

  void stopDiscovery() {
    try {
      FlutterBluePlus.stopScan(); // Stop scanning
      isDiscovering.value = false;
    } catch (e) {
      print("Error stopping discovery: $e");
    }
  }
}
