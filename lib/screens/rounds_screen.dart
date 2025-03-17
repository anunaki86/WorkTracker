import 'package:flutter/material.dart';

class RoundsScreen extends StatelessWidget {
  const RoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rundy'),
      ),
      body: Center(
        child: Text('Ekran rund'),
      ),
    );
  }
}
