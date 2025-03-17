import 'package:flutter/material.dart';

class IssuesScreen extends StatelessWidget {
  const IssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Awaria'),
      ),
      body: Center(
        child: Text('Ekran awarii'),
      ),
    );
  }
}
