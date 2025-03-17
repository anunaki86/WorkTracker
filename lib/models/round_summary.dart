// import 'dart:convert';  // Unused import removed

class RoundSummary {
  final String label;
  final int count;
  final int totalMinutes;
  final int? totalWeight;

  const RoundSummary({
    required this.label,
    required this.count,
    required this.totalMinutes,
    this.totalWeight,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'count': count,
      'totalMinutes': totalMinutes,
      'totalWeight': totalWeight,
    };
  }

  factory RoundSummary.fromJson(Map<String, dynamic> json) {
    return RoundSummary(
      label: json['label'],
      count: json['count'],
      totalMinutes: json['totalMinutes'],
      totalWeight: json['totalWeight'],
    );
  }
}
