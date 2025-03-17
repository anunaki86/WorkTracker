class DailyStats {
  final DateTime date;
  final int totalWeight;
  final double netWeight;
  final int workingMinutes;
  final double efficiencyPerHour;

  DailyStats({
    required this.date,
    required this.totalWeight,
    required this.netWeight,
    required this.workingMinutes,
    required this.efficiencyPerHour,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date']),
      totalWeight: json['totalWeight'],
      netWeight: json['netWeight'],
      workingMinutes: json['workingMinutes'],
      efficiencyPerHour: json['efficiencyPerHour'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalWeight': totalWeight,
      'netWeight': netWeight,
      'workingMinutes': workingMinutes,
      'efficiencyPerHour': efficiencyPerHour,
    };
  }
}