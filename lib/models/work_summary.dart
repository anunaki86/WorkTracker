// import 'dart:convert';  // Unused import removed
import 'round_summary.dart';

class WorkSummary {
  final DateTime date;
  final List<RoundSummary> roundSummaries;
  final int totalMinutes;
  final int? totalWeight;

  WorkSummary({
    required this.date,
    List<RoundSummary>? roundSummaries,
    this.totalMinutes = 0,
    this.totalWeight,
  }) : roundSummaries = roundSummaries ?? [];

  void addRoundSummary(RoundSummary roundSummary) {
    roundSummaries.add(roundSummary);
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'roundSummaries': roundSummaries.map((rs) => rs.toJson()).toList(),
      'totalMinutes': totalMinutes,
      'totalWeight': totalWeight,
    };
  }

  factory WorkSummary.fromJson(Map<String, dynamic> json) {
    return WorkSummary(
      date: DateTime.parse(json['date']),
      roundSummaries: (json['roundSummaries'] as List)
          .map((rs) => RoundSummary.fromJson(rs))
          .toList(),
      totalMinutes: json['totalMinutes'],
      totalWeight: json['totalWeight'],
    );
  }
}
