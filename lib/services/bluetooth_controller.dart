import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  var devices = <BluetoothDevice>[].obs;
  var isDiscovering = false.obs;

  // Start discovery of Bluetooth devices
  void startDiscovery() async {
    try {
      isDiscovering.value = true;

      // Get already paired devices
      List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();

      // Optionally filter for specific devices, e.g., ESP32
      devices.value = bondedDevices.where((device) => device.name?.contains("ESP32") ?? false).toList();

      // Once discovery finishes
      isDiscovering.value = false;
    } catch (e) {
      print("Error during discovery: $e");
      isDiscovering.value = false;
      // Handle any error during discovery (e.g., show a dialog to the user)
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Avoid automatic discovery on init if not needed.
    // You can trigger discovery manually in your UI.
  }
}
