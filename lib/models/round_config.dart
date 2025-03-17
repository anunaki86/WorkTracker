class RoundConfig {
  final String label;
  final String? description; // Dodane pole description
  final int minutes;
  final bool requiresWeight;
  final int maxUses;
  final bool isServiceRound;
  final int? customDuration;
  final String shiftType; // 'morning', 'afternoon', 'friday_afternoon', 'common'
  int usesCount;
  
  RoundConfig({
    required this.label,
    this.description,
    required this.minutes,
    this.requiresWeight = false,
    this.maxUses = 1,
    this.isServiceRound = false,
    this.customDuration,
    this.shiftType = 'common',
    this.usesCount = 0,
  });

  RoundConfig copyWith({
    String? label,
    String? description,
    int? minutes,
    bool? requiresWeight,
    int? maxUses,
    bool? isServiceRound,
    int? customDuration,
    String? shiftType,
    int? usesCount,
  }) {
    return RoundConfig(
      label: label ?? this.label,
      description: description ?? this.description,
      minutes: minutes ?? this.minutes,
      requiresWeight: requiresWeight ?? this.requiresWeight,
      maxUses: maxUses ?? this.maxUses,
      isServiceRound: isServiceRound ?? this.isServiceRound,
      customDuration: customDuration ?? this.customDuration,
      shiftType: shiftType ?? this.shiftType,
      usesCount: usesCount ?? this.usesCount,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'description': description,
      'minutes': minutes,
      'requiresWeight': requiresWeight,
      'maxUses': maxUses,
      'isServiceRound': isServiceRound,
      'customDuration': customDuration,
      'shiftType': shiftType,
      'usesCount': usesCount,
    };
  }
  
  factory RoundConfig.fromJson(Map<String, dynamic> json) {
    return RoundConfig(
      label: json['label'],
      description: json['description'],
      minutes: json['minutes'],
      requiresWeight: json['requiresWeight'] ?? false,
      maxUses: json['maxUses'] ?? 1,
      isServiceRound: json['isServiceRound'] ?? false,
      customDuration: json['customDuration'],
      shiftType: json['shiftType'] ?? 'common',
      usesCount: json['usesCount'] ?? 0,
    );
  }
}