import 'package:flutter/material.dart';
// import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/round_config.dart';

class RoundListItem extends StatelessWidget {
  final RoundConfig config;
  final VoidCallback onTap;
  final int index;
  
  const RoundListItem({
    super.key,
    required this.config,
    required this.onTap,
    required this.index,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(10),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: onTap,
          child: ListTile(
            title: Text(config.label),
            subtitle: Text('Czas: ${config.minutes} minut'),
            trailing: config.requiresWeight 
                ? const Icon(Icons.scale, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}
