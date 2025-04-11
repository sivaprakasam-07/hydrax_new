// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// import '../widgets/battery_status.dart';
// import '../widgets/hydration_chart.dart';
// import '../widgets/water_bottle.dart';
// import '../widgets/temperature_chart.dart';
// import 'settings_screen.dart';
// import 'device_screen.dart';

// import '../../providers/theme_provider.dart';
// import '../../services/firebase_service.dart';
// import '../../services/location_service.dart';
// import '../../services/weather_service.dart';
// import '../../models/weather_model.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//   final double _batteryLevel = 15.0;
//   double _currentTemperature = 25.0;
//   bool _isCharging = false;
//   final double _waterFillLevel = 0.5;
//   late AnimationController _waveController;
//   int _selectedIndex = 0;
//   bool _environmentalAdaptationEnabled = false;

//   @override
//   void initState() {
//     super.initState();
//     _waveController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 2),
//     )..repeat(reverse: true);

//     _loadEnvironmentalAdaptationPreference();
//     _checkAndUpdateTemperature();
//     _getCurrentLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         print('❌ Location services are disabled.');
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           print('❌ Location permission denied.');
//           return;
//         }
//       }

//       var position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       WeatherModel? weather = await WeatherService()
//           .getWeather(position.latitude, position.longitude);
//       if (weather != null) {
//         print("✅ Weather Data: ${weather.temperature}°C");
//       } else {
//         print("⚠️ No Weather Data Retrieved!");
//       }
//     } catch (e) {
//       print('⚠️ Error fetching location: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _waveController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadEnvironmentalAdaptationPreference() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool savedValue = prefs.getBool("environmentalAdaptation") ?? false;
//     setState(() {
//       _environmentalAdaptationEnabled = savedValue;
//     });
//   }

//   Future<void> _toggleEnvironmentalAdaptation(bool value) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool("environmentalAdaptation", value);
//     setState(() {
//       _environmentalAdaptationEnabled = value;
//     });

//     if (value) {
//       _checkAndUpdateTemperature();
//     }
//   }

//   Future<void> _checkAndUpdateTemperature() async {
//     if (_environmentalAdaptationEnabled) {
//       try {
//         var position = await LocationService().getCurrentLocation();
//         if (position != null) {
//           WeatherModel? weather =
//               await WeatherService().getWeather(position.latitude, position.longitude);
//           if (weather != null) {
//             double adaptedTemp = weather.temperature > 25
//                 ? weather.temperature - 5
//                 : weather.temperature + 5;
//             adaptedTemp = adaptedTemp.clamp(10.0, 50.0);

//             setState(() {
//               _currentTemperature = adaptedTemp;
//             });
//             print("✅ Adapted Temp: ${_currentTemperature.round()}°C");
//           }
//         }
//       } catch (e) {
//         print('⚠️ Error updating temperature: $e');
//       }
//     }
//   }

//   void _onNavBarTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   void _toggleCharging() {
//     setState(() {
//       _isCharging = !_isCharging;
//     });
//   }

//   void _changeTemperature(bool increase) {
//     setState(() {
//       if (increase) {
//         _currentTemperature = (_currentTemperature + 1.0).clamp(10.0, 50.0);
//       } else {
//         _currentTemperature = (_currentTemperature - 1.0).clamp(10.0, 50.0);
//       }
//     });
//   }

//   Future<void> _fixTemperature() async {
//     try {
//       await FirebaseService().logTemperature(_currentTemperature.round().toDouble());
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('✅ Temperature logged successfully!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ Failed to log temperature!')),
//       );
//     }
//   }

//   Future<void> _connectToBluetoothDevice() async {
//     BluetoothDevice? selectedDevice = await FlutterBluetoothSerial.instance
//         .getBondedDevices()
//         .then((devices) => devices.isNotEmpty ? devices.first : null);

//     if (selectedDevice != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => DeviceScreen(device: selectedDevice),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ No paired Bluetooth device found.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var themeProvider = Provider.of<ThemeProvider>(context);
//     bool isDarkMode = themeProvider.isDarkMode;

//     List<Widget> screens = [
//       _buildHomeScreen(),
//       Padding(padding: EdgeInsets.all(10), child: HydrationChart()),
//       WaterBottle(fillPercentage: _waterFillLevel),
//       Padding(
//         padding: EdgeInsets.all(10),
//         child: TemperatureChart(
//           temperatureValues: [25, 24, 26, 23, 27, 22, 28],
//           maxTemperatureValues: [30, 30, 30, 30, 30, 30, 30],
//         ),
//       ),
//       SettingsScreen(),
//     ];

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: Text('HydraX', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
//         backgroundColor: Theme.of(context).primaryColor,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.settings, color: isDarkMode ? Colors.white : Colors.black),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => SettingsScreen()),
//               );
//             },
//           ),
//           Switch(
//             value: isDarkMode,
//             onChanged: (value) => themeProvider.toggleTheme(),
//           ),
//         ],
//       ),
//       body: screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Theme.of(context).primaryColor,
//         selectedItemColor: isDarkMode ? Colors.cyanAccent : Colors.blueAccent,
//         unselectedItemColor: isDarkMode ? Colors.grey : Colors.black,
//         currentIndex: _selectedIndex,
//         onTap: _onNavBarTapped,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Analysis"),
//           BottomNavigationBarItem(icon: Icon(Icons.local_drink), label: "Hydration"),
//           BottomNavigationBarItem(icon: Icon(Icons.thermostat), label: "Temp Log"),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
//         ],
//       ),
//     );
//   }

//   Widget _buildHomeScreen() {
//     bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text('HydraX', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//           SizedBox(height: 20),
//           BatteryStatus(
//             batteryLevel: _batteryLevel,
//             isCharging: _isCharging,
//             waveController: _waveController,
//             textColor: isDarkMode ? Colors.white : Colors.black,
//           ),
//           SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: _toggleCharging,
//             icon: Icon(_isCharging ? Icons.flash_off : Icons.flash_on),
//             label: Text(_isCharging ? "Stop Charging" : "Start Charging"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _isCharging ? Colors.orange : Colors.green,
//             ),
//           ),
//           SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.remove_circle, color: Colors.blue, size: 32),
//                 onPressed: () => _changeTemperature(false),
//               ),
//               Text(
//                 "${_currentTemperature.round()}°C",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               IconButton(
//                 icon: Icon(Icons.add_circle, color: Colors.red, size: 32),
//                 onPressed: () => _changeTemperature(true),
//               ),
//             ],
//           ),
//           SizedBox(height: 10),
//           ElevatedButton(
//             onPressed: _fixTemperature,
//             child: Text('Fix Temperature'),
//           ),
//           SizedBox(height: 20),
//           SwitchListTile(
//             title: Text("Environmental Adaptation"),
//             value: _environmentalAdaptationEnabled,
//             onChanged: (value) {
//               _toggleEnvironmentalAdaptation(value);
//             },
//           ),
//           SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: _connectToBluetoothDevice,
//             icon: Icon(Icons.bluetooth),
//             label: Text("Connect Device"),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart'; // <== ADDED

import '../widgets/battery_status.dart';
import '../widgets/hydration_chart.dart';
import '../widgets/water_bottle.dart';
import '../widgets/temperature_chart.dart';
import 'settings_screen.dart';
import 'device_screen.dart';

import '../../providers/theme_provider.dart';
import '../../services/firebase_service.dart';
import '../../services/location_service.dart';
import '../../services/weather_service.dart';
import '../../models/weather_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final double _batteryLevel = 15.0;
  double _currentTemperature = 25.0;
  bool _isCharging = false;
  final double _waterFillLevel = 0.5;
  late AnimationController _waveController;
  int _selectedIndex = 0;
  bool _environmentalAdaptationEnabled = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _loadEnvironmentalAdaptationPreference();
    _checkAndUpdateTemperature();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permission denied.');
          return;
        }
      }

      var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      WeatherModel? weather = await WeatherService()
          .getWeather(position.latitude, position.longitude);
      if (weather != null) {
        print("✅ Weather Data: ${weather.temperature}°C");
      } else {
        print("⚠️ No Weather Data Retrieved!");
      }
    } catch (e) {
      print('⚠️ Error fetching location: $e');
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _loadEnvironmentalAdaptationPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedValue = prefs.getBool("environmentalAdaptation") ?? false;
    setState(() {
      _environmentalAdaptationEnabled = savedValue;
    });
  }

  Future<void> _toggleEnvironmentalAdaptation(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("environmentalAdaptation", value);
    setState(() {
      _environmentalAdaptationEnabled = value;
    });

    if (value) {
      _checkAndUpdateTemperature();
    }
  }

  Future<void> _checkAndUpdateTemperature() async {
    if (_environmentalAdaptationEnabled) {
      try {
        var position = await LocationService().getCurrentLocation();
        if (position != null) {
          WeatherModel? weather =
              await WeatherService().getWeather(position.latitude, position.longitude);
          if (weather != null) {
            double adaptedTemp = weather.temperature > 25
                ? weather.temperature - 5
                : weather.temperature + 5;
            adaptedTemp = adaptedTemp.clamp(10.0, 50.0);

            setState(() {
              _currentTemperature = adaptedTemp;
            });
            print("✅ Adapted Temp: ${_currentTemperature.round()}°C");
          }
        }
      } catch (e) {
        print('⚠️ Error updating temperature: $e');
      }
    }
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleCharging() {
    setState(() {
      _isCharging = !_isCharging;
    });
  }

  void _changeTemperature(bool increase) {
    setState(() {
      if (increase) {
        _currentTemperature = (_currentTemperature + 1.0).clamp(10.0, 50.0);
      } else {
        _currentTemperature = (_currentTemperature - 1.0).clamp(10.0, 50.0);
      }
    });
  }

  Future<void> _fixTemperature() async {
    try {
      await FirebaseService().logTemperature(_currentTemperature.round().toDouble());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Temperature logged successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to log temperature!')),
      );
    }
  }

  Future<void> _requestBluetoothPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothConnect]?.isDenied ?? true) {
      print("❌ Bluetooth Connect Permission Denied");
    }
    if (statuses[Permission.location]?.isDenied ?? true) {
      print("❌ Location Permission Denied");
    }
  }

  Future<void> _connectToBluetoothDevice() async {
    await _requestBluetoothPermissions(); // ✅ NEW: Request permissions

    BluetoothDevice? selectedDevice = await FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((devices) => devices.isNotEmpty ? devices.first : null);

    if (selectedDevice != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeviceScreen(device: selectedDevice),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ No paired Bluetooth device found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    List<Widget> screens = [
      _buildHomeScreen(),
      Padding(padding: EdgeInsets.all(10), child: HydrationChart()),
      WaterBottle(fillPercentage: _waterFillLevel),
      Padding(
        padding: EdgeInsets.all(10),
        child: TemperatureChart(
          temperatureValues: [25, 24, 26, 23, 27, 22, 28],
          maxTemperatureValues: [30, 30, 30, 30, 30, 30, 30],
        ),
      ),
      SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('HydraX', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          Switch(
            value: isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: isDarkMode ? Colors.cyanAccent : Colors.blueAccent,
        unselectedItemColor: isDarkMode ? Colors.grey : Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Analysis"),
          BottomNavigationBarItem(icon: Icon(Icons.local_drink), label: "Hydration"),
          BottomNavigationBarItem(icon: Icon(Icons.thermostat), label: "Temp Log"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('HydraX', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          BatteryStatus(
            batteryLevel: _batteryLevel,
            isCharging: _isCharging,
            waveController: _waveController,
            textColor: isDarkMode ? Colors.white : Colors.black,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _toggleCharging,
            icon: Icon(_isCharging ? Icons.flash_off : Icons.flash_on),
            label: Text(_isCharging ? "Stop Charging" : "Start Charging"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCharging ? Colors.orange : Colors.green,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.blue, size: 32),
                onPressed: () => _changeTemperature(false),
              ),
              Text(
                "${_currentTemperature.round()}°C",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.red, size: 32),
                onPressed: () => _changeTemperature(true),
              ),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _fixTemperature,
            child: Text('Fix Temperature'),
          ),
          SizedBox(height: 20),
          SwitchListTile(
            title: Text("Environmental Adaptation"),
            value: _environmentalAdaptationEnabled,
            onChanged: (value) {
              _toggleEnvironmentalAdaptation(value);
            },
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _connectToBluetoothDevice,
            icon: Icon(Icons.bluetooth),
            label: Text("Connect Device"),
          ),
        ],
      ),
    );
  }
}
