import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // ✅ Import debugPrint


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Add Temperature Log to Firestore
  Future<void> logTemperature(double temperature) async {
    try {
      debugPrint("Attempting to log temperature: $temperature");
      await _firestore.collection('temperatureLogs').add({
        'temperature': temperature,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("✅ Temperature log added successfully!");
    } catch (e) {
      print("❌ Error adding temperature log: $e");
    }
  }

  // ✅ Get Temperature Logs from Firestore
  Future<List<Map<String, dynamic>>> getTemperatureLogs() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('temperatureLogs')
          .orderBy('timestamp', descending: true)
          .get();

      // Map Firestore documents to a list of maps safely
      List<Map<String, dynamic>> logs = querySnapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'temperature': data['temperature'],
          'timestamp': (data['timestamp'] != null)
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now(), // Fallback for null timestamp
        };
      }).toList();

      print("✅ Fetched ${logs.length} temperature logs.");
      return logs;
    } catch (e) {
      print("❌ Error fetching temperature logs: $e");
      return [];
    }
  }

  // ✅ Add Hydration Log to Firestore
Future<void> logHydration(double litres) async {
  try {
    await _firestore.collection('hydrationLogs').add({
      'litres': litres,
      'timestamp': FieldValue.serverTimestamp(),
    });
    debugPrint("✅ Hydration log added successfully!");
  } catch (e) {
    debugPrint("❌ Error adding hydration log: $e");
  }
}


  // ✅ Get Hydration Logs from Firestore (Optional)
  Future<List<Map<String, dynamic>>> getHydrationLogs() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('hydrationLogs')
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> logs = querySnapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'litersDrank': data['litersDrank'],
          'timestamp': (data['timestamp'] != null)
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
        };
      }).toList();

      print("✅ Fetched ${logs.length} hydration logs.");
      return logs;
    } catch (e) {
      print("❌ Error fetching hydration logs: $e");
      return [];
    }
  }
}
