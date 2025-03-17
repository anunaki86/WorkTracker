import 'package:flutter/material.dart';
// import '../utils/logger.dart'; // Usunięcie nieużywanego importu

class NeumorphicBox extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color color;
  final Offset offset;
  final double blur;
  final bool isPressed;

  const NeumorphicBox({
    super.key,
    required this.child,
    this.borderRadius = 15.0,
    this.color = const Color(0xFFE0E0E0),
    this.offset = const Offset(5, 5),
    this.blur = 15.0,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                // Wewnętrzny cień dla efektu wciśnięcia
                BoxShadow(
                  color: Colors.white.withAlpha(150),
                  offset: -offset,
                  blurRadius: blur,
                  spreadRadius: 1.0,
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  offset: offset,
                  blurRadius: blur,
                  spreadRadius: 1.0,
                ),
              ]
            : [
                // Zewnętrzny cień dla efektu wypukłości
                BoxShadow(
                  color: Colors.white.withAlpha(150),
                  offset: -offset,
                  blurRadius: blur,
                  spreadRadius: 1.0,
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  offset: offset,
                  blurRadius: blur,
                  spreadRadius: 1.0,
                ),
              ],
      ),
      child: child,
    );
  }
}

// Neumorficzny przycisk z efektem wciśnięcia
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color color;
  final double borderRadius;

  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color = const Color(0xFFE0E0E0),
    this.borderRadius = 15.0,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: NeumorphicBox(
        color: widget.color,
        borderRadius: widget.borderRadius,
        isPressed: _isPressed,
        child: widget.child,
      ),
    );
  }
}

class RoundConfig {
  final String label;
  final int minutes;
  final bool requiresWeight;
  final int maxUses;
  final bool customDuration;
  final bool isServiceRound;

  RoundConfig({
    required this.label,
    required this.minutes,
    this.requiresWeight = false,
    this.maxUses = 1,
    this.customDuration = false,
    this.isServiceRound = false,
  });
}

class RoundConfigs {
  final List<RoundConfig> dayRoundConfigs = [
    RoundConfig(label: 'Runda 1 (D)', minutes: 90, requiresWeight: true, maxUses: 1),
    RoundConfig(label: 'Runda 2 (D)', minutes: 90, requiresWeight: true, maxUses: 1),
    RoundConfig(label: 'Runda 3 (D)', minutes: 90, requiresWeight: true, maxUses: 1),
    RoundConfig(label: 'Runda 4 (D)', minutes: 90, requiresWeight: true, maxUses: 1),
    RoundConfig(label: 'Runda 5 (D)', minutes: 66, requiresWeight: true, maxUses: 1),
  ];

  final List<RoundConfig> nightRoundConfigs = [
    RoundConfig(label: 'Runda 1 (N)', minutes: 90, requiresWeight: true, maxUses: 1),
    RoundConfig(label: 'Runda 2 (N)', minutes: 90, requiresWeight: true, maxUses: 1),
    RoundConfig(label: 'Runda 3 (N)', minutes: 95, requiresWeight: true, maxUses: 1),
    RoundConfig(label: 'Runda 4 (N)', minutes: 95, requiresWeight: true, maxUses: 1),
    RoundConfig(label: 'Runda 5 (N)', minutes: 90, requiresWeight: true, maxUses: 1),
  ];

  final List<RoundConfig> fridayRoundConfigs = [
    RoundConfig(label: 'Runda 1 (PT)', minutes: 90, requiresWeight: true, maxUses: 1),
    RoundConfig(label: 'Runda 2 (PT)', minutes: 90, requiresWeight: true, maxUses: 1),
    RoundConfig(label: 'Runda 3 (PT)', minutes: 65, requiresWeight: true, maxUses: 1),
  ];

  final List<RoundConfig> commonConfigs = [
    RoundConfig(label: 'Przerwa', minutes: 15, maxUses: 2), // Dwie przerwy po 15 minut
    RoundConfig(label: 'Awaria', minutes: 0, customDuration: true),
    RoundConfig(label: 'Serwis', minutes: 0, customDuration: true, isServiceRound: true),
  ];

  RoundConfigs() {
    print("Inicjalizacja rund: ${dayRoundConfigs.length}"); // Logowanie liczby rund
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RoundConfigs roundConfigs = RoundConfigs();

  @override
  Widget build(BuildContext context) {
    print("Liczba rund: ${roundConfigs.dayRoundConfigs.length}"); // Logowanie liczby rund
    roundConfigs.dayRoundConfigs.forEach((round) {
      print("Runda: ${round.label}, Czas: ${round.minutes}"); // Logowanie szczegółów rund
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Śledzenie czasu pracy'),
        leading: IconButton(
          icon: Icon(Icons.settings), // Ikona ustawień
          onPressed: () {
            // Logika do obsługi kliknięcia w ikonę ustawień
            print("Ikona ustawień kliknięta");
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: roundConfigs.dayRoundConfigs.length,
              itemBuilder: (context, index) {
                final round = roundConfigs.dayRoundConfigs[index];
                return ListTile(
                  title: Text(round.label),
                  subtitle: Text('Czas: ${round.minutes} min'),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: roundConfigs.commonConfigs.length,
              itemBuilder: (context, index) {
                final breakConfig = roundConfigs.commonConfigs[index];
                return ListTile(
                  title: Text(breakConfig.label),
                  subtitle: Text('Czas: ${breakConfig.minutes} min'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
