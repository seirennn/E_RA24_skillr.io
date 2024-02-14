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
        colorSchemeSeed: Color.fromARGB(255, 46, 61, 96),
        scaffoldBackgroundColor: Color.fromARGB(255, 20, 20, 26),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 37, 52, 82))
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
