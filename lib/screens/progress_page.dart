import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/daily_stats.dart';
import '../utils/logger.dart'; // Import AppLogger

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  Future<List<DailyStats>> _loadDailyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('daily_stats') ?? '[]';
    final List<dynamic> statsList = jsonDecode(statsJson);
    return statsList.map((json) => DailyStats.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.info('Progress page loaded.'); // Add AppLogger.info call
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progres'),
      ),
      body: FutureBuilder<List<DailyStats>>(
        future: _loadDailyStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak danych do wyświetlenia'));
          }

          final dailyStats = snapshot.data!;
          final averageEfficiency = dailyStats.isEmpty 
              ? 0.0 
              : dailyStats.map((s) => s.efficiencyPerHour).reduce((a, b) => a + b) / dailyStats.length;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  'Progres dzienny',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Średnia wydajność: ${averageEfficiency.toStringAsFixed(2)} kg/h',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProgressIcon(Icons.trending_up, 'Dobry', Colors.green),
                    _buildProgressIcon(Icons.trending_flat, 'Średni', Colors.orange),
                    _buildProgressIcon(Icons.trending_down, 'Słaby', Colors.red),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 48, color: color),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
