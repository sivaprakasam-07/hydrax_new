import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'ui/screens/home_screen.dart';
import 'providers/theme_provider.dart'; // ✅ Import ThemeProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase with correct options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully!');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // ✅ Add other providers if needed in future
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Apply ThemeProvider for Dark/Light mode
    var themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'HydraX',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData, // ✅ Apply selected theme
      home: HomeScreen(), // ✅ Load the correct HomeScreen
    );
  }
}
