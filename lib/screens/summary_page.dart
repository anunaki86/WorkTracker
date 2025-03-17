import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/round_summary.dart';
import '../models/work_summary.dart';
import '../providers/work_provider.dart';
import '../utils/logger.dart'; // Import AppLogger

class SummaryPage extends StatelessWidget {
  final WorkSummary summary;
  
  const SummaryPage({
    super.key,
    required this.summary,
  });
  
  @override
  Widget build(BuildContext context) {
    AppLogger.info('Summary page built.'); // Add AppLogger.info call
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(
          'Podsumowanie dnia',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data: ${summary.date.day}.${summary.date.month}.${summary.date.year}',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Całkowity czas: ${summary.totalMinutes} minut',
              style: const TextStyle(fontSize: 16),
            ),
            if (summary.totalWeight != null && summary.totalWeight! > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Całkowita waga: ${summary.totalWeight} kg',
                style: const TextStyle(fontSize: 16),
              ),
              Consumer<WorkProvider>(
                builder: (context, workProvider, _) {
                  final netWeight = summary.totalWeight! * (1 - workProvider.lossPercentage / 100);
                  return Text(
                    'Waga netto: ${netWeight.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 16),
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Podsumowanie rund:',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...summary.roundSummaries.map((rs) => _buildRoundSummaryCard(rs)),
            const SizedBox(height: 24),
            Center(
              child: NeumorphicButton(
                style: NeumorphicStyle(
                  color: Theme.of(context).primaryColor,
                ),
                child: const Text(
                  'Eksportuj dane',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  // Funkcja eksportu danych
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funkcja eksportu w przygotowaniu')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRoundSummaryCard(RoundSummary roundSummary) {
    return Neumorphic(
      margin: const EdgeInsets.symmetric(vertical: 8),
      style: const NeumorphicStyle(
        depth: 2,
        intensity: 0.7,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              roundSummary.label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text('Ilość: ${roundSummary.count}'),
            Text('Czas: ${roundSummary.totalMinutes} minut'),
            if (roundSummary.totalWeight != null && roundSummary.totalWeight! > 0)
              Text('Waga: ${roundSummary.totalWeight} kg'),
          ],
        ),
      ),
    );
  }
}
