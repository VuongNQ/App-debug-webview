import 'package:flutter/material.dart';
import 'screens/config_screen.dart';

void main() {
  runApp(const WebViewDebugApp());
}

class WebViewDebugApp extends StatelessWidget {
  const WebViewDebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Debugger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90E2)),
        useMaterial3: true,
      ),
      home: const ConfigScreen(),
    );
  }
}
