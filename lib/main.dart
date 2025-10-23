// main.dart
import 'package:flutter/material.dart';
import 'screens/rummy_game_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thirteen',
      home: RummyGameScreen(), // or your main widget
    );
  }
}


