class Employee {
  final String id;
  final String name;
  final String position;
  final String employeeNumber;
  final List<WorkHistory> workHistory;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.employeeNumber,
    this.workHistory = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position,
    'employeeNumber': employeeNumber,
    'workHistory': workHistory.map((h) => h.toJson()).toList(),
  };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['id'],
    name: json['name'],
    position: json['position'],
    employeeNumber: json['employeeNumber'],
    workHistory: (json['workHistory'] as List?)
        ?.map((h) => WorkHistory.fromJson(h))
        .toList() ?? [],
  );
}

class WorkHistory {
  final DateTime date;
  final String shiftType;
  final int workingMinutes;
  final double netWeight;
  final double grossWeight;
  final String notes;

  WorkHistory({
    required this.date,
    required this.shiftType,
    required this.workingMinutes,
    required this.netWeight,
    required this.grossWeight,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'shiftType': shiftType,
    'workingMinutes': workingMinutes, 
    'netWeight': netWeight,
    'grossWeight': grossWeight,
    'notes': notes,
  };

  factory WorkHistory.fromJson(Map<String, dynamic> json) => WorkHistory(
    date: DateTime.parse(json['date']),
    shiftType: json['shiftType'],
    workingMinutes: json['workingMinutes'],
    netWeight: json['netWeight'],
    grossWeight: json['grossWeight'],
    notes: json['notes'] ?? '',
  );
}
