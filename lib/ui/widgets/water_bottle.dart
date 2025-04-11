import 'package:flutter/material.dart';
import 'dart:math';
import 'package:hydrax/services/firebase_service.dart';

class WaterBottle extends StatefulWidget {
  final double fillPercentage; // Water fill level (0 to 1)

  const WaterBottle({super.key, required this.fillPercentage});

  @override
  _WaterBottleState createState() => _WaterBottleState();
}

class _WaterBottleState extends State<WaterBottle> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  int refillCount = 0; // Counter for refill button clicks
  final int bottleCapacity = 750; // Bottle capacity in ml

  @override
  void initState() {
    super.initState();

    // 🌊 Wave Animation Controller
    _waveController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(); // Loops continuously
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  /// ✅ **Log Total Litres to Firestore**
  Future<void> _logDailyWaterIntake() async {
    // Calculate total water intake in liters
    double totalLitres = (refillCount * bottleCapacity) / 1000.0;

    try {
      await FirebaseService().logHydration(totalLitres);
      // ✅ Success Message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Water intake logged: ${totalLitres.toStringAsFixed(1)}L')),
      );
    } catch (e) {
      // ❌ Error Message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to log water intake!')),
      );
    }
  }

  /// ✅ **Show Total Litres Dialog and Log to Firestore**
  void _showTotalLitres() {
    // Calculate total water intake in liters
    double totalLitres = (refillCount * bottleCapacity) / 1000.0;

    // Show a dialog with the total water intake
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Daily Water Intake"),
          content: Text("You drank ${totalLitres.toStringAsFixed(1)}L today!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logDailyWaterIntake(); // ✅ Log to Firestore
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double bottleHeight = 280; // Increased bottle height

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 💧 Water Level Text
          Text(
            "${(widget.fillPercentage * 5).toStringAsFixed(1)} L",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 15),

          // 🛑 Refill Button
          ElevatedButton(
            onPressed: () {
              setState(() {
                refillCount++; // Increment the refill count
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Refill: $refillCount",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 15),

          // 🍼 Water Bottle Container
          Container(
            width: 120,
            height: bottleHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade700, width: 4),
              color: Colors.transparent,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(3, 5),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return ClipPath(
                  clipper: WaterClipper(widget.fillPercentage, _waveController.value),
                  child: Container(
                    width: double.infinity,
                    height: bottleHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.withOpacity(0.5),
                          Colors.blueAccent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 15),

          // 🌊 Litres Button
          ElevatedButton(
            onPressed: _showTotalLitres, // ✅ Show and log litres
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Litres",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// 🌊 Custom Wave Clipper for Realistic Floating Water
class WaterClipper extends CustomClipper<Path> {
  final double fillPercentage;
  final double waveValue;

  WaterClipper(this.fillPercentage, this.waveValue);

  @override
  Path getClip(Size size) {
    Path path = Path();
    double waveHeight = 10.0;
    double waveWidth = size.width / 1.5;
    double waterLevel = size.height * (1 - fillPercentage);

    path.moveTo(0, waterLevel);

    for (double i = 0; i < size.width; i += waveWidth) {
      path.quadraticBezierTo(
        i + waveWidth / 4,
        waterLevel - sin((i + waveValue * size.width) * pi / waveWidth) * waveHeight,
        i + waveWidth / 2,
        waterLevel,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(WaterClipper oldClipper) => true;
}
