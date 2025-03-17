import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/round_config.dart';

class RoundsProvider with ChangeNotifier {
  final List<RoundConfig> _availableRounds = [];
  String _currentShiftType = 'morning'; 
  bool _isLoading = true;
  
  List<RoundConfig> get availableRounds => _filterRoundsByShiftType();
  String get currentShiftType => _currentShiftType;
  bool get isLoading => _isLoading;
  
  bool get isFriday {
    return DateTime.now().weekday == DateTime.friday;
  }
  
  List<RoundConfig> _filterRoundsByShiftType() {
    final filtered = _availableRounds.where((round) => 
      round.shiftType == _currentShiftType || round.shiftType == 'common'
    ).toList();
    
    return filtered;
  }
  
  void setShiftType(String shiftType) {
    if (shiftType != _currentShiftType) {
      _currentShiftType = shiftType;
      _saveCurrentShiftType();
      notifyListeners();
    }
  }
  
  RoundConfig? getRoundByLabel(String label) {
    try {
      return _availableRounds.firstWhere((round) => round.label == label);
    } catch (e) {
      return null;
    }
  }
  
  RoundConfig? getRoundById(String id) {
    try {
      return _availableRounds.firstWhere((round) => round.label == id);
    } catch (e) {
      return null;
    }
  }
  
  void addRound(RoundConfig round) {
    _availableRounds.add(round);
    _saveRounds();
    notifyListeners();
  }
  
  void removeRound(String label) {
    _availableRounds.removeWhere((round) => round.label == label);
    _saveRounds();
    notifyListeners();
  }
  
  void updateRound(String oldLabel, RoundConfig newRound) {
    final index = _availableRounds.indexWhere((round) => round.label == oldLabel);
    if (index != -1) {
      _availableRounds[index] = newRound;
      _saveRounds();
      notifyListeners();
    }
  }
  
  Future<void> _saveRounds() async {
    final prefs = await SharedPreferences.getInstance();
    final roundsJson = jsonEncode(_availableRounds.map((round) => round.toJson()).toList());
    await prefs.setString('availableRounds', roundsJson);
  }
  
  Future<void> _saveCurrentShiftType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentShiftType', _currentShiftType);
  }
   
  Future<void> loadRounds() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      
      // Wczytaj typ zmiany
      _currentShiftType = prefs.getString('currentShiftType') ?? 'morning';
      
      final roundsJson = prefs.getString('availableRounds');
      
      if (roundsJson != null && roundsJson.isNotEmpty) {
        try {
          final List<dynamic> decodedRounds = jsonDecode(roundsJson);
          
          // Dodatkowe zabezpieczenie
          if (decodedRounds.isEmpty) {
            throw FormatException('Brak rund w danych');
          }
          
          _availableRounds.clear();
          _availableRounds.addAll(
            decodedRounds.map((round) => RoundConfig.fromJson(round)).toList()
          );
        } catch (e) {
          print('Błąd podczas parsowania rund: $e');
          _createDefaultRounds();
        }
      } else {
        _createDefaultRounds();
      }
      
      // Sprawdź, czy mamy wystarczającą liczbę rund
      if (_availableRounds.length <= 1) {
        _createDefaultRounds();
      }
    } catch (e) {
      print('Nieoczekiwany błąd podczas ładowania rund: $e');
      _createDefaultRounds();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _createDefaultRounds() {
    _availableRounds.clear();
    
    // Rundy poranne (5 rund)
    _availableRounds.add(RoundConfig(
      label: 'Runda 1 (Rano)', 
      description: 'Standardowa runda poranna',
      minutes: 90, 
      requiresWeight: true, 
      shiftType: 'morning'
    ));
    _availableRounds.add(RoundConfig(
      label: 'Runda 2 (Rano)', 
      description: 'Standardowa runda poranna',
      minutes: 90, 
      requiresWeight: true, 
      shiftType: 'morning'
    ));
    _availableRounds.add(RoundConfig(
      label: 'Runda 3 (Rano)', 
      description: 'Standardowa runda poranna',
      minutes: 90, 
      requiresWeight: true, 
      shiftType: 'morning'
    ));
    _availableRounds.add(RoundConfig(
      label: 'Runda 4 (Rano)', 
      description: 'Standardowa runda poranna',
      minutes: 90, 
      requiresWeight: true, 
      shiftType: 'morning'
    ));
    _availableRounds.add(RoundConfig(
      label: 'Runda 5 (Rano)', 
      description: 'Ostatnia runda poranna (krótsza)',
      minutes: 66, 
      requiresWeight: true, 
      shiftType: 'morning'
    ));
    
    // Rundy popołudniowe (5 rund po 95 minut każda)
    _availableRounds.add(RoundConfig(
      label: 'Runda 1 (Popołudnie)', 
      description: 'Standardowa runda popołudniowa',
      minutes: 95, 
      requiresWeight: true, 
      shiftType: 'afternoon'
    ));
    _availableRounds.add(RoundConfig(
      label: 'Runda 2 (Popołudnie)', 
      description: 'Standardowa runda popołudniowa',
      minutes: 95, 
      requiresWeight: true, 
      shiftType: 'afternoon'
    ));
    _availableRounds.add(RoundConfig(
      label: 'Runda 3 (Popołudnie)', 
      description: 'Standardowa runda popołudniowa',
      minutes: 95, 
      requiresWeight: true, 
      shiftType: 'afternoon'
    ));
    _availableRounds.add(RoundConfig(
      label: 'Runda 4 (Popołudnie)', 
      description: 'Standardowa runda popołudniowa',
      minutes: 95, 
      requiresWeight: true, 
      shiftType: 'afternoon'
    ));
    _availableRounds.add(RoundConfig(
      label: 'Runda 5 (Popołudnie)', 
      description: 'Standardowa runda popołudniowa',
      minutes: 95, 
      requiresWeight: true, 
      shiftType: 'afternoon'
    ));
    
    // Rundy piątkowe popołudniowe (2 rundy po 95 minut + 1 runda 64 minuty)
    _availableRounds.add(RoundConfig(
      label: 'Runda 1 (Piątek)', 
      description: 'Piątkowa runda popołudniowa',
      minutes: 95, 
      requiresWeight: true, 
      shiftType: 'friday_afternoon'
    ));
    _availableRounds.add(RoundConfig(
      label: 'Runda 2 (Piątek)', 
      description: 'Piątkowa runda popołudniowa',
      minutes: 95, 
      requiresWeight: true, 
      shiftType: 'friday_afternoon'
    ));
    _availableRounds.add(RoundConfig(
      label: 'Runda 3 (Piątek)', 
      description: 'Ostatnia piątkowa runda (krótsza)',
      minutes: 64, 
      requiresWeight: true, 
      shiftType: 'friday_afternoon'
    ));
    
    // Rundy wspólne (przerwy, awarie, serwis)
    _availableRounds.add(RoundConfig(
      label: 'Przerwa', 
      description: 'Przerwa standardowa',
      minutes: 15, 
      maxUses: 2, 
      shiftType: 'common'
    ));
    _availableRounds.add(RoundConfig(
      label: 'Awaria', 
      description: 'Zgłoszenie awarii',
      minutes: 0, 
      customDuration: 0, 
      maxUses: 3, 
      shiftType: 'common'
    ));
    _availableRounds.add(RoundConfig(
      label: 'Serwis', 
      description: 'Serwis urządzeń',
      minutes: 0, 
      customDuration: 0, 
      requiresWeight: true, 
      isServiceRound: true, 
      shiftType: 'common'
    ));
    
    _saveRounds();
  }
  
  void resetRounds() {
    // Zachowaj identyfikatory istniejących podstawowych typów rund
    List<RoundConfig> awarie = _availableRounds.where((r) => r.label.contains('Awaria')).toList();
    List<RoundConfig> serwisy = _availableRounds.where((r) => r.isServiceRound).toList();
    List<RoundConfig> przerwy = _availableRounds.where((r) => r.label.contains('Przerwa')).toList();
    
    // Wyczyść tylko rundy, które nie są podstawowymi typami
    _availableRounds.removeWhere((r) => 
      !r.label.contains('Awaria') && 
      !r.isServiceRound && 
      !r.label.contains('Przerwa')
    );
    
    // Dodaj domyślne rundy
    _createDefaultRounds();
    
    // Dodaj podstawowe typy, jeśli nie istnieją
    if (awarie.isEmpty) {
      _availableRounds.add(RoundConfig(
        label: 'Awaria', 
        description: 'Zgłoszenie awarii',
        minutes: 0, 
        customDuration: 0, 
        maxUses: 3, 
        shiftType: 'common'
      ));
    }
    if (serwisy.isEmpty) {
      _availableRounds.add(RoundConfig(
        label: 'Serwis', 
        description: 'Serwis urządzeń',
        minutes: 0, 
        customDuration: 0, 
        requiresWeight: true, 
        isServiceRound: true, 
        shiftType: 'common'
      ));
    }
    if (przerwy.isEmpty) {
      _availableRounds.add(RoundConfig(
        label: 'Przerwa', 
        description: 'Przerwa standardowa',
        minutes: 15, 
        maxUses: 2, 
        shiftType: 'common'
      ));
    }
    
    _saveRounds();
    notifyListeners();
  }
}