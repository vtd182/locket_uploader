import 'package:flutter/material.dart';
import 'package:locket_uploader/constants/constants.dart';
import 'package:locket_uploader/ui/login_screen.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // image: 1mb
  // video: 10mb
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locket Uploader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(Constants.yellowColor)),
        useMaterial3: true,
        fontFamily: 'Netto',
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
