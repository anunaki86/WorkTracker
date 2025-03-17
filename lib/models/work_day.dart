// lib/models/work_day.dart
class WorkDay {
  final DateTime date;
  final int hoursWorked;
  final bool wasNightShift;

  WorkDay({
    required this.date,
    required this.hoursWorked,
    this.wasNightShift = false,
  });
}