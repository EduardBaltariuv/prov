import 'package:flutter/material.dart';

class AppTheme extends StatelessWidget {
  const AppTheme({super.key});
  
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(
        primaryTextTheme: TextTheme()
      ),
    );
  }
}