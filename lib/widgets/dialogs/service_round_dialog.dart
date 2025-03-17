import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/round_config.dart';
import '../../models/work_action.dart';
import '../../providers/rounds_provider.dart';

class ServiceRoundDialog extends StatefulWidget {
  final RoundConfig config;
  final DateTime selectedDate;
  final WorkAction? existingAction;

  const ServiceRoundDialog({
    super.key,
    required this.config,
    required this.selectedDate,
    this.existingAction,
  });

  @override
  State<ServiceRoundDialog> createState() => _ServiceRoundDialogState();
}

class _ServiceRoundDialogState extends State<ServiceRoundDialog> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  bool _isWeightValid = true;
  bool _isServiceMode = false;
  RoundConfig? _selectedRound;
  int? _customMinutes;
  
  @override
  void initState() {
    super.initState();
    _isServiceMode = widget.config.isServiceRound;
    _selectedRound = widget.config;
    
    // Wypełnij pola, jeśli edytujemy istniejącą akcję
    if (widget.existingAction != null) {
      if (widget.existingAction!.weight != null) {
        _weightController.text = widget.existingAction!.weight.toString();
      }
      _detailsController.text = widget.existingAction!.notes; // Używamy 'notes' a nie 'details'
      
      if (widget.config.label.contains('Awaria') || widget.config.customDuration != null) {
        _minutesController.text = widget.existingAction!.minutes.toString();
        _customMinutes = widget.existingAction!.minutes;
      }
    } else if (widget.config.minutes > 0) {
      _minutesController.text = widget.config.minutes.toString();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _detailsController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isServiceMode ? 'Dodaj serwis' : 'Dodaj rundę: ${widget.config.label}',
        style: GoogleFonts.lato(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isServiceMode) ...[
              // Jeśli to serwis, pokaż dropdown do wyboru rundy
              Text('Wybierz rundę do oznaczenia jako serwis:'),
              SizedBox(height: 10),
              Consumer<RoundsProvider>(
                builder: (context, provider, child) {
                  final rounds = provider.availableRounds
                      .where((r) => r.requiresWeight && !r.isServiceRound)
                      .toList();
                  
                  return DropdownButton<RoundConfig>(
                    isExpanded: true,
                    value: _selectedRound!.isServiceRound ? null : _selectedRound,
                    hint: Text('Wybierz rundę'),
                    items: rounds.map((round) {
                      return DropdownMenuItem<RoundConfig>(
                        value: round,
                        child: Text(round.label),
                      );
                    }).toList(),
                    onChanged: (RoundConfig? newValue) {
                      setState(() {
                        _selectedRound = newValue;
                      });
                    },
                  );
                },
              ),
            ] else if (widget.config.label.contains('Awaria')) ...[
              // Dla awarii, pokaż pole do wprowadzania czasu
              TextField(
                controller: _minutesController,
                decoration: InputDecoration(
                  labelText: 'Czas trwania (minuty)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  try {
                    _customMinutes = int.parse(value);
                  } catch (e) {
                    // Ignoruj błędny format
                  }
                },
              ),
            ] else ...[
              // Jeśli to normalna runda, pokaż jej czas
              Text(
                'Czas trwania: ${widget.config.minutes} minut',
                style: GoogleFonts.lato(),
              ),
            ],
            
            SizedBox(height: 16),
            
            if ((widget.config.requiresWeight && !_isServiceMode) || 
                (_isServiceMode && _selectedRound != null && _selectedRound!.requiresWeight)) ...[
              // Pole wagi - opcjonalne dla serwisu
              TextField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: _isServiceMode ? 'Waga (opcjonalnie)' : 'Waga (kg)',
                  errorText: _isWeightValid ? null : 'Wprowadź poprawną wagę',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16),
            ],
            
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(
                labelText: 'Szczegóły (opcjonalnie)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Anuluj',
            style: GoogleFonts.lato(),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final config = _isServiceMode ? _selectedRound ?? widget.config : widget.config;
            
            if (config.requiresWeight && !_isServiceMode) {
              // Dla normalnych rund wymagana jest waga
              try {
                final weight = double.parse(_weightController.text.replaceAll(',', '.'));
                if (weight <= 0) {
                  setState(() {
                    _isWeightValid = false;
                  });
                  return;
                }
                
                // Upewnij się, że waga jest prawidłowo konwertowana z formularza na liczbę całkowitą przed przekazaniem jej do addActionWithDate.
                Navigator.of(context).pop({
                  'weight': weight.toInt(),
                  'notes': _detailsController.text, // Zmienione z 'details' na 'notes'
                  'isService': false,
                  'selectedRound': config,
                  'customMinutes': widget.config.label.contains('Awaria') ? _customMinutes : null,
                });
              } catch (e) {
                setState(() {
                  _isWeightValid = false;
                });
              }
            } else {
              // Dla serwisu waga jest opcjonalna
              int? weight;
              
              if (_weightController.text.isNotEmpty) {
                try {
                  weight = double.parse(_weightController.text.replaceAll(',', '.')).toInt();
                } catch (e) {
                  // Ignoruj błędny format wagi dla serwisu
                }
              }
              
              Navigator.of(context).pop({
                'weight': weight,
                'notes': _detailsController.text, // Zmienione z 'details' na 'notes'
                'isService': _isServiceMode,
                'selectedRound': config,
                'customMinutes': widget.config.label.contains('Awaria') ? _customMinutes : null,
              });
            }
          },
          child: Text(
            widget.existingAction != null ? 'Zapisz' : 'Dodaj',
            style: GoogleFonts.lato(),
          ),
        ),
      ],
    );
  }
}