import 'package:flutter/material.dart';
import 'pages/main_shell.dart';

class AutonoticApp extends StatelessWidget {
  const AutonoticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autonotic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const MainShell(),
    );
  }
}

