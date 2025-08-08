import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doctorbooking/screens/splash_screen.dart';
// import 'package:doctorbooking/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Si-Sehat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Ubah background jadi putih
        textTheme: GoogleFonts.manropeTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SplashScreen(), // ganti dengan halaman pertama
    );
  }
}
