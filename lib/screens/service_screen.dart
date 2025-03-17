import 'package:flutter/material.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Serwis'),
      ),
      body: Center(
        child: Text('Ekran serwisu'),
      ),
    );
  }
}
