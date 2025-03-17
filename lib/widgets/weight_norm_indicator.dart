import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/work_provider.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class WeightNormIndicator extends StatelessWidget {
  final double targetWeight;
  final double currentWeight;
  final double lossPercentage;
  
  const WeightNormIndicator({
    super.key,
    required this.targetWeight,
    required this.currentWeight,
    required this.lossPercentage,
  });
  
  @override
  Widget build(BuildContext context) {
    final progress = (currentWeight / targetWeight).clamp(0.0, 1.0);
    final netWeight = currentWeight * (1 - lossPercentage / 100);
    final netProgress = (netWeight / targetWeight).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Norma wagowa:',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cel: ${targetWeight.toStringAsFixed(1)} kg'),
                    Text('Aktualna waga: ${currentWeight.toStringAsFixed(1)} kg'),
                    Text('Waga netto: ${netWeight.toStringAsFixed(1)} kg'),
                    Text('Straty: ${lossPercentage.toStringAsFixed(1)}%'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: netProgress,
                        strokeWidth: 4,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          netProgress >= 1.0 ? Colors.green : Colors.blue,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Text(
            'Postęp: ${(progress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 12),
          ),
          Consumer<WorkProvider>(
            builder: (context, workProvider, _) {
              return NeumorphicSlider(
                min: 0,
                max: 30,
                value: workProvider.lossPercentage,
                onChanged: (value) {
                  workProvider.setLossPercentage(value);
                },
                style: const SliderStyle(
                  accent: Colors.blue,
                  variant: Colors.blueGrey,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Procent strat',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}