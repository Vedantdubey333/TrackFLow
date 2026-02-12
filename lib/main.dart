import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';

=======
import 'package:firebase_core/firebase_core.dart';
>>>>>>> 07dc16f09303f866d484008f2d0a1d1f77c23c10
import 'screens/front_page.dart';
import 'theme/theme_provider.dart';

<<<<<<< HEAD
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
=======
void main() async {
  // Ensure Flutter bindings are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const MyApp());
>>>>>>> 07dc16f09303f866d484008f2d0a1d1f77c23c10
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔥 THEME CONTROL
      themeMode: themeProvider.themeMode,

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),

      // 👈 FIRST SCREEN
      home: const FrontPage(),
    );
  }
}
