import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/round_config.dart';
import '../providers/rounds_provider.dart';
import '../providers/work_provider.dart';
import '../widgets/dialogs/service_round_dialog.dart';
import '../utils/logger.dart'; // Poprawiony import dla AppLogger

class HomePage extends StatefulWidget {
  final VoidCallback onLogout;
  
  const HomePage({super.key, required this.onLogout});
  
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedSection = 0; 
  bool _isHistory = false; 
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() async {
    final currentContext = context;
    
    try {
      final roundsProvider = Provider.of<RoundsProvider>(currentContext, listen: false);
      final workProvider = Provider.of<WorkProvider>(currentContext, listen: false);

      await Future.wait([
        roundsProvider.loadRounds(),
        workProvider.loadData()
      ], eagerError: true).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          AppLogger.info('Timeout podczas ładowania danych'); // Replace print with AppLogger.info
          return [];
        }
      );

      if (currentContext.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.info('Błąd inicjalizacji: $e'); // Replace print with AppLogger.info
      if (currentContext.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Metoda do zmiany typu zmiany
  void _changeShiftType(String shiftType) {
    final roundsProvider = Provider.of<RoundsProvider>(context, listen: false);
    roundsProvider.setShiftType(shiftType);
  }

  // Metoda do wyświetlania dialogu z wyborem daty
  void _showDatePicker() async {
    final workProvider = Provider.of<WorkProvider>(context, listen: false);
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: workProvider.selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      locale: const Locale('pl', 'PL'),
    );
    
    if (pickedDate != null) {
      workProvider.setSelectedDate(pickedDate);
      setState(() {
        _isHistory = true;
        _selectedSection = 4;
      });
    }
  }
  
  // Metoda do dodawania rundy dla wybranej daty
  void _showAddRoundForDateDialog(DateTime date) {
    final roundsProvider = Provider.of<RoundsProvider>(context, listen: false);
    final rounds = roundsProvider.availableRounds;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Wybierz rodzaj wpisu do dodania'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.timer),
                title: Text('Runda standardowa'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showStandardRoundsDialog(date);
                },
              ),
              ListTile(
                leading: Icon(Icons.free_breakfast),
                title: Text('Przerwa'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  final breakRounds = rounds.where((r) => r.label.contains('Przerwa')).toList();
                  if (breakRounds.isNotEmpty) {
                    _showServiceRoundDialogWithDate(breakRounds.first, date);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.warning, color: Colors.red),
                title: Text('Awaria'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  final issueRounds = rounds.where((r) => r.label.contains('Awaria')).toList();
                  if (issueRounds.isNotEmpty) {
                    _showServiceRoundDialogWithDate(issueRounds.first, date);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.build, color: Colors.orange),
                title: Text('Serwis'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  final serviceRounds = rounds.where((r) => r.isServiceRound).toList();
                  if (serviceRounds.isNotEmpty) {
                    _showServiceRoundDialogWithDate(serviceRounds.first, date);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workProvider = Provider.of<WorkProvider>(context);
    final roundsProvider = Provider.of<RoundsProvider>(context);
    
    final isLoading = workProvider.isLoading || roundsProvider.isLoading || _isLoading;
    
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Ładowanie...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('RoundTracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.restore),
            onPressed: () {
              Provider.of<RoundsProvider>(context, listen: false).resetRounds();
            },
            tooltip: 'Resetuj rundy',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<RoundsProvider>(context, listen: false).loadRounds();
            },
            tooltip: 'Przeładuj dane',
          ),
          PopupMenuButton<String>(
            onSelected: _changeShiftType,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'morning',
                child: Text('Zmiana ranna'),
              ),
              PopupMenuItem<String>(
                value: 'afternoon',
                child: Text('Zmiana popołudniowa'),
              ),
              PopupMenuItem<String>(
                value: 'friday_afternoon',
                child: Text('Piątek popołudnie'),
              ),
            ],
            icon: Icon(Icons.schedule),
            tooltip: 'Wybierz typ zmiany',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildLossPercentageDialog(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: widget.onLogout,
            tooltip: 'Wyloguj',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProductivityWidget(),
          Expanded(
            child: _isHistory
                ? _buildRoundsForSelectedDay()
                : _buildCurrentRounds(),
          ),
        ],
      ),
      bottomNavigationBar: !_isHistory
          ? BottomNavigationBar(
              currentIndex: _selectedSection,
              onTap: (index) {
                setState(() {
                  _selectedSection = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.timer),
                  label: 'Rundy',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.free_breakfast),
                  label: 'Przerwa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.warning),
                  label: 'Awaria',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.build),
                  label: 'Serwis',
                ),
              ],
            )
          : null,
      floatingActionButton: IconButton(
        icon: Icon(_isHistory ? Icons.today : Icons.history, size: 32),
        onPressed: _toggleHistoryView,
        tooltip: _isHistory ? 'Dzisiejszy dzień' : 'Historia',
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  // Metoda do wyświetlania rund dla wybranej daty
  Widget _buildRoundsForSelectedDay() {
    final workProvider = Provider.of<WorkProvider>(context);
    final roundsProvider = Provider.of<RoundsProvider>(context);
    final selectedDate = workProvider.selectedDate;
    final rounds = workProvider.getActionsForDate(selectedDate);
    
    final dateFormat = DateFormat('dd.MM.yyyy');
    final dayFormat = DateFormat('EEEE', 'pl_PL');
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(selectedDate),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    dayFormat.format(selectedDate).capitalize(),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _showAddRoundForDateDialog(selectedDate),
                    tooltip: 'Dodaj rundę',
                  ),
                  IconButton(
                    icon: Icon(_isHistory ? Icons.today : Icons.history),
                    onPressed: _toggleHistoryView,
                    tooltip: _isHistory ? 'Dzisiejszy dzień' : 'Historia',
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _showDatePicker,
                    tooltip: 'Wybierz datę',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: rounds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Brak zarejestrowanych rund na ten dzień',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Dodaj pierwszą rundę'),
                        onPressed: () => _showAddRoundForDateDialog(selectedDate),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: rounds.length,
                  itemBuilder: (ctx, index) {
                    final action = rounds[index];
                    final round = roundsProvider.getRoundById(action.roundId);
                    
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  round?.label ?? 'Nieznana runda',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        if (round != null) {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => ServiceRoundDialog(
                                              config: round, 
                                              selectedDate: selectedDate,
                                              existingAction: action,
                                            ),
                                          );
                                        }
                                      },
                                      tooltip: 'Edytuj',
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text('Potwierdzenie'),
                                            content: Text('Czy na pewno chcesz usunąć tę rundę?'),
                                            actions: [
                                              TextButton(
                                                child: Text('Anuluj'),
                                                onPressed: () => Navigator.of(ctx).pop(),
                                              ),
                                              TextButton(
                                                child: Text('Usuń'),
                                                onPressed: () {
                                                  workProvider.removeAction(action.id); 
                                                  Navigator.of(ctx).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      tooltip: 'Usuń',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Czas: ${DateFormat('HH:mm').format(action.timestamp)}',
                              style: TextStyle(fontSize: 16),
                            ),
                            if (action.notes.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text(
                                'Notatki: ${action.notes}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  // Metoda do wyświetlania dostępnych rund
  Widget _buildCurrentRounds() {
    final roundsProvider = Provider.of<RoundsProvider>(context);
    
    switch (_selectedSection) {
      case 0: 
        final standardRounds = roundsProvider.availableRounds
            .where((r) => !r.label.contains('Przerwa') && 
                         !r.isServiceRound && 
                         !r.label.contains('Awaria'))
            .toList();
        return _buildRoundsList(standardRounds);
      case 1: 
        final breakRounds = roundsProvider.availableRounds
            .where((r) => r.label.contains('Przerwa'))
            .toList();
        return _buildRoundsList(breakRounds);
      case 2: 
        final issueRounds = roundsProvider.availableRounds
            .where((r) => r.label.contains('Awaria'))
            .toList();
        return _buildRoundsList(issueRounds);
      case 3: 
        final serviceRounds = roundsProvider.availableRounds
            .where((r) => r.isServiceRound)
            .toList();
        return _buildRoundsList(serviceRounds);
      default:
        return Center(child: Text('Nieznana sekcja'));
    }
  }
  
  // Metoda do wyświetlania listy rund
  Widget _buildRoundsList(List<RoundConfig> rounds) {
    if (rounds.isNotEmpty) {
    }
    
    return rounds.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Brak dostępnych rund dla tej kategorii',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text('Odśwież dane'),
                  onPressed: () {
                    Provider.of<RoundsProvider>(context, listen: false).loadRounds();
                  },
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: rounds.length,
            itemBuilder: (ctx, index) {
              final round = rounds[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    round.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    round.description ?? '', 
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => ServiceRoundDialog(
                        config: round, 
                        selectedDate: DateTime.now(),
                      ),
                    );
                  },
                ),
              );
            },
          );
  }
  
  // Metoda do wyświetlania standardowych rund
  void _showStandardRoundsDialog(DateTime date) {
    final roundsProvider = Provider.of<RoundsProvider>(context, listen: false);
    final standardRounds = roundsProvider.availableRounds
        .where((r) => !r.label.contains('Przerwa') && 
                       !r.isServiceRound && 
                       !r.label.contains('Awaria'))
        .toList();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Wybierz rundę'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: standardRounds.length,
            itemBuilder: (context, index) {
              final round = standardRounds[index];
              return ListTile(
                title: Text(round.label),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showServiceRoundDialogWithDate(round, date);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Metoda do wyświetlania dialogu z wyborem rundy serwisowej
  void _showServiceRoundDialogWithDate(RoundConfig round, DateTime date) {
    final currentContext = context;
    
    showDialog(
      context: currentContext,
      builder: (ctx) => ServiceRoundDialog(
        config: round, 
        selectedDate: date,
      ),
    ).then((result) {
      if (result != null) {
        final workProvider = Provider.of<WorkProvider>(currentContext, listen: false);
        
        // Przygotuj dane
        String roundId = round.label;
        String label = round.label;
        int minutes = round.minutes;
        int? weightValue;
        if (result['weight'] != null) {
          try {
            weightValue = int.parse(result['weight'].toString());
            AppLogger.info('Przekonwertowana waga: ${weightValue}');
          } catch (e) {
            AppLogger.info('Błąd konwersji wagi: ${e}');
          }
        }
        String notes = result['notes'] == null ? '' : (result['notes'] is String ? result['notes'].toUpperCase() : result['notes'].join(', ').toUpperCase());
        bool isService = result['isService'] ?? false;
        
        // Jeśli to awaria z niestandardowym czasem
        if (round.label.contains('Awaria') && result['customMinutes'] != null) {
          minutes = result['customMinutes'];
        }
        
        // Dodaj akcję z datą
        workProvider.addActionWithDate(
          roundId,
          label,
          minutes,
          weight: weightValue,
          notes: notes,
          date: date,
          isService: isService
        );
      }
    });
  }

  // Metoda do wyświetlania widgetu produktywności
  Widget _buildProductivityWidget() {
    final workProvider = Provider.of<WorkProvider>(context);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.2 * 255).round()),
            spreadRadius: 2,
            blurRadius: 5,
          )
        ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Aktualna produktywność',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Aktualna waga: ${workProvider.totalWeight.toStringAsFixed(1)} kg',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Waga netto: ${workProvider.calculateNetWeight(workProvider.totalWeight).toStringAsFixed(1)} kg',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Norma 1', '${workProvider.hourlyNorm1.toStringAsFixed(1)} kg/h'),
              _buildStatItem('Norma 2', '${workProvider.hourlyNorm2.toStringAsFixed(1)} kg/h'),
            ],
          )
        ],
      ),
    );
  }

  // Metoda do wyświetlania statystyki
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        )
      ],
    );
  }

  // Metoda do przełączania widoku historii
  void _toggleHistoryView() {
    setState(() {
      _isHistory = !_isHistory;
      if (_isHistory) {
        _selectedSection = 4; 
      } else {
        _selectedSection = 0; 
      }
    });
  }

  // Metoda do wyświetlania dialogu z ustawieniami ubytku
  Widget _buildLossPercentageDialog() {
    final workProvider = Provider.of<WorkProvider>(context, listen: false);
    
    return AlertDialog(
      title: Text('Ustaw procent ubytku'),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Aktualny ubytek: ${workProvider.lossPercentage.toStringAsFixed(1)}%'),
              Slider(
                value: workProvider.lossPercentage,
                min: 10,
                max: 21,
                divisions: 110,
                label: workProvider.lossPercentage.toStringAsFixed(1),
                onChanged: (double value) {
                  setState(() {
                    workProvider.setLossPercentage(value);
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          child: Text('Zamknij'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

// Rozszerzenie do kapitalizacji pierwszej litery stringa
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}