import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import '../../services/bluetooth_controller.dart';

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
import '../../services/ai_service.dart';
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
  bool _userAdoptionEnabled = false;
  bool _smartTemperatureEnabled = false;
  final BluetoothController bluetoothController = Get.put(BluetoothController());
  BluetoothDevice? connectedDevice;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _loadEnvironmentalAdaptationPreference();
    _loadSmartTemperaturePreference();
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

            // Send weather data and adapted temperature to ESP32
            if (connectedDevice != null) {
              final List<BluetoothService> services = await connectedDevice!.discoverServices();
              for (var service in services) {
                for (var characteristic in service.characteristics) {
                  if (characteristic.properties.write) {
                    // Prepare data to send
                    final weatherData = "Weather Data:${weather.temperature}°C,Adapted:${_currentTemperature.round()}°C";
                    final weatherBytes = weatherData.codeUnits;

                    // Send data to ESP32
                    await characteristic.write(weatherBytes, withoutResponse: true);
                    print("✅ Weather data sent to ESP32: $weatherData");
                    return;
                  }
                }
              }
              print("❌ No writable characteristic found on ESP32.");
            } else {
              print("❌ No connected device to send weather data.");
            }
          }
        }
      } catch (e) {
        print('⚠️ Error updating temperature: $e');
      }
    }
  }

  Future<void> _toggleUserAdoption(bool value) async {
    setState(() {
      _userAdoptionEnabled = value;
    });

    if (value) {
      // Reduce temperature by 5
      setState(() {
        _currentTemperature = (_currentTemperature - 5).clamp(10.0, 50.0);
      });

      // Send the updated temperature to ESP32
      if (connectedDevice != null) {
        try {
          final List<BluetoothService> services = await connectedDevice!.discoverServices();
          for (var service in services) {
            for (var characteristic in service.characteristics) {
              if (characteristic.properties.write) {
                // Convert temperature to bytes and send
                final tempBytes = _currentTemperature.round().toString().codeUnits;
                await characteristic.write(tempBytes, withoutResponse: true);
                print("✅ User Adoption Temp sent to ESP32: ${_currentTemperature.round()}°C");
                return;
              }
            }
          }
          print("❌ No writable characteristic found on ESP32.");
        } catch (e) {
          print("⚠️ Failed to send User Adoption Temp: $e");
        }
      } else {
        print("❌ No connected device to send User Adoption Temp.");
      }
    }
  }

  // 🤖 Smart Temperature Control using Linear Regression
  Future<void> _toggleSmartTemperature(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("smartTemperatureEnabled", value);
    
    setState(() {
      _smartTemperatureEnabled = value;
    });

    if (value) {
      await _applySmartTemperatureControl();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🔄 Smart Temperature Control disabled')),
      );
    }
  }

  // Apply AI-powered temperature prediction
  Future<void> _applySmartTemperatureControl() async {
    try {
      // Get current location for ambient temperature
      var position = await LocationService().getCurrentLocation();
      double ambientTemp = 25.0; // Default fallback
      
      if (position != null) {
        WeatherModel? weather = await WeatherService().getWeather(position.latitude, position.longitude);
        if (weather != null) {
          ambientTemp = weather.temperature;
        }
      }

      // Get AI recommendation using Linear Regression model
      final recommendation = await AIService().getSmartTemperatureRecommendation(
        currentTemp: _currentTemperature,
        ambientTemp: ambientTemp,
        userPreference: _currentTemperature, // Use current as preference
      );

      double averageTemp = recommendation['averageUserTemperature'];
      String reason = recommendation['reason'];
      double confidence = recommendation['confidence'];

      // Update temperature to the average from 75 users (as per requirement)
      setState(() {
        _currentTemperature = averageTemp;
      });

      // Send to ESP32
      if (connectedDevice != null) {
        try {
          final List<BluetoothService> services = await connectedDevice!.discoverServices();
          for (var service in services) {
            for (var characteristic in service.characteristics) {
              if (characteristic.properties.write) {
                final tempBytes = averageTemp.round().toString().codeUnits;
                await characteristic.write(tempBytes, withoutResponse: true);
                print("✅ Smart Temperature sent to ESP32: ${averageTemp.round()}°C");
                break;
              }
            }
          }
        } catch (e) {
          print("⚠️ Failed to send Smart Temperature: $e");
        }
      }

      // Show detailed feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🤖 Smart Temperature Applied: ${averageTemp.round()}°C'),
              Text('📊 Based on 75 users\' preferences'),
              Text('🎯 Confidence: ${(confidence * 100).round()}%'),
              Text('💡 $reason'),
            ],
          ),
          duration: Duration(seconds: 4),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Smart Temperature Error: $e')),
      );
    }
  }

  Future<void> _loadSmartTemperaturePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedValue = prefs.getBool("smartTemperatureEnabled") ?? false;
    setState(() {
      _smartTemperatureEnabled = savedValue;
    });
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
      // Log temperature to Firebase
      await FirebaseService().logTemperature(_currentTemperature.round().toDouble());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Temperature logged successfully!')),
      );

      // Send temperature to ESP32
      if (connectedDevice != null) {
        final List<BluetoothService> services = await connectedDevice!.discoverServices();
        for (var service in services) {
          for (var characteristic in service.characteristics) {
            if (characteristic.properties.write) {
              // Convert temperature to bytes and send
              final tempBytes = _currentTemperature.round().toString().codeUnits;
              await characteristic.write(tempBytes, withoutResponse: true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ Temperature sent to ESP32!')),
              );
              return;
            }
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ No writable characteristic found on ESP32.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ No connected device to send temperature.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to send temperature: $e')),
      );
    }
  }

  Future<void> _connectToBluetoothDevice() async {
    bluetoothController.startDiscovery();
    final selectedDevice = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DeviceScreen()),
    );

    if (selectedDevice != null && selectedDevice is BluetoothDevice) {
      try {
        await selectedDevice.connect();
        setState(() {
          connectedDevice = selectedDevice;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Connected to ${selectedDevice.name}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to connect to ${selectedDevice.name}')),
        );
      }
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
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20),
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
          SizedBox(height: 15),
          // Control Switches Section
          Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text("Environmental Adaptation", style: TextStyle(fontSize: 14)),
                    dense: true,
                    value: _environmentalAdaptationEnabled,
                    onChanged: (value) {
                      _toggleEnvironmentalAdaptation(value);
                    },
                  ),
                  Divider(height: 1),
                  SwitchListTile(
                    title: Text("User Adoption", style: TextStyle(fontSize: 14)),
                    dense: true,
                    value: _userAdoptionEnabled,
                    onChanged: (value) {
                      _toggleUserAdoption(value);
                    },
                  ),
                  Divider(height: 1),
                  SwitchListTile(
                    title: Text("🤖 Smart Temperature Control", style: TextStyle(fontSize: 14)),
                    subtitle: Text("AI-powered using 75 users' data", style: TextStyle(fontSize: 12)),
                    dense: true,
                    value: _smartTemperatureEnabled,
                    onChanged: (value) {
                      _toggleSmartTemperature(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: _connectToBluetoothDevice,
            icon: Icon(Icons.bluetooth),
            label: Text("Connect Device"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
