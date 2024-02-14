// ignore_for_file: prefer_const_constructors


import 'start_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Color.fromARGB(255, 213, 216, 222),
        scaffoldBackgroundColor: Color.fromARGB(255, 18, 19, 24),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 157, 168, 189))
            .onPrimaryContainer
            
            .withOpacity(0.3),
            
        
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: StartScreen(),
            
          ),
          
        ),
        
      ),
    );
    
  }
}
