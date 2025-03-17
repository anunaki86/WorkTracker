import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/work_action.dart';
import '../utils/logger.dart'; // Corrected import for AppLogger

class WorkProvider with ChangeNotifier {
  List<WorkAction> _actions = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  double _lossPercentage = 14.5; // Domyślny procent ubytku
  double _hourlyNorm1 = 330.0; // Domyślna norma godzinowa (kg)
  double _hourlyNorm2 = 380.0; // Domyślna norma godzinowa (kg)
  
  // Gettery
  List<WorkAction> get actions => _actions;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  double get lossPercentage => _lossPercentage;
  double get hourlyNorm1 => _hourlyNorm1;
  double get hourlyNorm2 => _hourlyNorm2;
  
  // Getter do pobierania akcji na dzisiaj
  List<WorkAction> get todayActions {
    final now = DateTime.now();
    return getActionsForDate(now);
  }
  
  // Getter do obliczania łącznego czasu pracy (z wyłączeniem przerw)
  int get totalWorkMinutes {
    return todayActions
        .where((action) => !action.label.contains('Przerwa'))
        .fold(0, (sum, action) => sum + action.minutes);
  }
  
  // Getter do obliczania łącznego czasu przerw
  int get totalBreakMinutes {
    return todayActions
        .where((action) => action.label.contains('Przerwa'))
        .fold(0, (sum, action) => sum + action.minutes);
  }
  
  // Getter do obliczania wagi netto (po odjęciu ubytku)
  double get netWeight {
    return getTotalWeightForDate(_selectedDate) * (1 - lossPercentage / 100);
  }
  
  // Getter do obliczania bieżącej produktywności (kg/h)
  double get currentProductivity {
    final workHours = totalWorkMinutes / 60;
    if (workHours <= 0) return 0;
    return currentWeight / workHours;
  }
  
  // Getter do obliczania procentu realizacji normy
  double get normCompletionPercentage {
    if (hourlyNorm1 <= 0) return 0;
    return (currentProductivity / hourlyNorm1) * 100;
  }
  
  // Getter do obliczania łącznej wagi
  double get totalWeight {
    return _actions
        .where((action) => action.weight != null)
        .fold(0.0, (sum, action) => sum + (action.weight ?? 0));
  }
  
  // Getter do obliczania sumy wag dla dzisiejszego dnia
  double get todayTotalWeight {
    final now = DateTime.now();
    return getTotalWeightForDate(now);
  }
  
  // Getter do sprawdzenia, czy wybrana data to dzisiaj
  bool get isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
           _selectedDate.month == now.month &&
           _selectedDate.day == now.day;
  }
  
  // Getter do obliczania łącznej wagi akcji na dzisiaj
  double get currentWeight {
    return getTotalWeightForDate(DateTime.now());
  }
  
  // Ustawienie wybranej daty
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  
  // Ustawienie procentu ubytku
  void setLossPercentage(double percentage) {
    _lossPercentage = percentage;
    _saveLossPercentage();
    notifyListeners();
  }
  
  // Ustawienie normy godzinowej
  void setHourlyNorm1(double norm) {
    _hourlyNorm1 = norm;
    _saveHourlyNorm1();
    notifyListeners();
  }
  
  void setHourlyNorm2(double norm) {
    _hourlyNorm2 = norm;
    _saveHourlyNorm2();
    notifyListeners();
  }
  
  // Pobranie akcji dla wybranej daty
  List<WorkAction> getActionsForDate(DateTime date) {
    return _actions
        .where((action) => 
            action.timestamp.year == date.year &&
            action.timestamp.month == date.month &&
            action.timestamp.day == date.day)
        .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  
  // Dodawanie nowej akcji
  void addAction(WorkAction action) {
    _actions.add(action);
    _saveData();
    notifyListeners();
  }
  
  // Dodawanie akcji dla wybranej daty
  void addActionWithDate(String roundId, String label, int minutes, {
    int? weight, 
    String notes = '', 
    DateTime? date,
    bool isService = false
  }) {
    final action = WorkAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roundId: roundId,
      label: label,
      minutes: minutes,
      weight: weight,
      notes: notes,
      timestamp: date ?? DateTime.now(),
      isService: isService,
    );
    _actions.add(action);
    notifyListeners();
    AppLogger.info('Dodano akcję: ${label}, waga: ${weight}, suma dzisiaj: ${getTotalWeightForDate(DateTime.now())}');
  }
  
  // Aktualizacja istniejącej akcji
  void updateAction(WorkAction updatedAction) {
    final index = _actions.indexWhere((action) => action.id == updatedAction.id);
    if (index != -1) {
      _actions[index] = updatedAction;
      _saveData();
      notifyListeners();
    }
  }
  
  // Usuwanie akcji
  void removeAction(String id) {
    _actions.removeWhere((action) => action.id == id);
    _saveData();
    notifyListeners();
  }
  
  // Zachowanie oryginalnej metody deleteAction dla kompatybilności
  void deleteAction(String id) {
    removeAction(id);
  }
  
  // Zapisywanie danych do SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final actionsJson = jsonEncode(_actions.map((action) => action.toJson()).toList());
    AppLogger.info('Zapisywanie danych: ${actionsJson}');
    await prefs.setString('workActions', actionsJson);
  }
  
  // Zapisywanie procentu ubytku
  Future<void> _saveLossPercentage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lossPercentage', _lossPercentage);
  }
  
  // Zapisywanie normy godzinowej
  Future<void> _saveHourlyNorm1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('hourlyNorm1', _hourlyNorm1);
  }
  
  Future<void> _saveHourlyNorm2() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('hourlyNorm2', _hourlyNorm2);
  }

  // Ładowanie danych z SharedPreferences
  Future<void> loadData() async {
    final startTime = DateTime.now();
    _isLoading = true;
    notifyListeners();

    AppLogger.info('Starting data loading at ${startTime}');
    final prefs = await SharedPreferences.getInstance();
    
    // Wczytaj procent ubytku
    _lossPercentage = prefs.getDouble('lossPercentage') ?? 14.5;
    
    // Wczytaj normę godzinową
    _hourlyNorm1 = prefs.getDouble('hourlyNorm1') ?? 330.0;
    _hourlyNorm2 = prefs.getDouble('hourlyNorm2') ?? 380.0;
    
    final actionsJson = prefs.getString('workActions');
    
    if (actionsJson != null) {
      AppLogger.info('Found saved actions: $actionsJson');
      try {
        final List<dynamic> decodedActions = jsonDecode(actionsJson);
        _actions = decodedActions.map((action) => WorkAction.fromJson(action)).toList();
        AppLogger.info('Loaded ${_actions.length} actions');
      } catch (e) {
        AppLogger.info('Error parsing actions: $e');
        _actions = [];
      }
    } else {
      AppLogger.info('No saved actions found.');
      _actions = [];
    }
    
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    AppLogger.info('Data loading completed in ${duration.inSeconds} seconds');

    _isLoading = false;
    notifyListeners();
  }
  
  // Czyszczenie wszystkich danych
  void clearAllData() {
    _actions = [];
    _saveData();
    notifyListeners();
  }
  
  // Filtrowanie akcji po typie (np. standardowe, przerwy, awarie)
  List<WorkAction> getActionsByType(String type) {
    return _actions.where((action) => action.label.contains(type)).toList();
  }
  
  // Pobieranie akcji dla zakresu dat
  List<WorkAction> getActionsForDateRange(DateTime startDate, DateTime endDate) {
    return _actions
        .where((action) => 
            action.timestamp.isAfter(startDate.subtract(Duration(days: 1))) &&
            action.timestamp.isBefore(endDate.add(Duration(days: 1))))
        .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  
  // Grupowanie akcji po miesiącach - przydatne do statystyk
  Map<String, List<WorkAction>> getActionsByMonth() {
    final Map<String, List<WorkAction>> result = {};
    
    for (var action in _actions) {
      final key = '${action.timestamp.year}-${action.timestamp.month.toString().padLeft(2, '0')}';
      
      if (!result.containsKey(key)) {
        result[key] = [];
      }
      
      result[key]!.add(action);
    }
    
    return result;
  }
  
  // Obliczanie sumy wag dla danego dnia
  double getTotalWeightForDate(DateTime date) {
    return _actions
        .where((action) => action.timestamp.year == date.year &&
                      action.timestamp.month == date.month &&
                      action.timestamp.day == date.day)
        .fold(0.0, (sum, action) => sum + (action.weight ?? 0));
  }
  
  // Obliczanie łącznego czasu trwania dla danego dnia
  int getTotalMinutesForDate(DateTime date) {
    return getActionsForDate(date)
        .fold(0, (sum, action) => sum + action.minutes);
  }
  
  // Metoda do liczenia wagi netto
  double calculateNetWeight(double grossWeight) {
    return grossWeight * (1 - _lossPercentage / 100);
  }

  // Aktualizacja metody updateTotalWeight w klasie WorkProvider
  void updateTotalWeight(String actionId, int newWeight) {
    final index = _actions.indexWhere((action) => action.id == actionId);
    if (index != -1) {
      // Utwórz nową akcję z zaktualizowaną wagą
      final updatedAction = _actions[index].copyWith(weight: newWeight);
      _actions[index] = updatedAction;
      _saveData();
      notifyListeners();
    }
  }

  // Nowa metoda getCurrentWeight
  double getCurrentWeight() {
    double total = 0;
    final now = DateTime.now();
    
    for (var action in _actions) {
      if (action.weight != null && 
          action.timestamp.year == now.year &&
          action.timestamp.month == now.month &&
          action.timestamp.day == now.day) {
        total += action.weight!;
      }
    }
    
    return total;
  }
}