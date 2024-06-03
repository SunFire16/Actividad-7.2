import 'package:flutter/material.dart';
import 'package:prueba_application_9/widgets/chat.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Demo',
      home: ChatScreen(),
    );
  }
}
