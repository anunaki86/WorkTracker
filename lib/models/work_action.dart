class WorkAction {
  String id; 
  String roundId; 
  String label; 
  int minutes; 
  int? weight; 
  String notes; 
  DateTime timestamp; 
  bool isService; 

  WorkAction({
    required this.id,
    required this.roundId,
    required this.label,
    required this.minutes,
    this.weight,
    this.notes = '',
    this.isService = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  String get details => notes;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roundId': roundId,
      'label': label,
      'minutes': minutes,
      'weight': weight,
      'notes': notes,
      'isService': isService,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WorkAction.fromJson(Map<String, dynamic> json) {
    // Wymuszamy konwersję weight na int?
    int? weightValue;
    if (json['weight'] != null) {
      try {
        weightValue = int.parse(json['weight'].toString());
      } catch (e) {
        // W przypadku błędu konwersji, zachowaj null
        weightValue = null;
      }
    }

    return WorkAction(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      roundId: json['roundId'] ?? '',
      label: json['label'] ?? '',
      minutes: json['minutes'] ?? 0,
      weight: weightValue,
      notes: json['notes'] ?? json['details'] ?? '',
      isService: json['isService'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
  
  WorkAction copyWith({
    String? id,
    String? roundId,
    String? label,
    int? minutes,
    int? weight,
    String? notes,
    bool? isService,
    DateTime? timestamp,
  }) {
    return WorkAction(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      label: label ?? this.label,
      minutes: minutes ?? this.minutes,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      isService: isService ?? this.isService,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

double calculateNetWeight(int grossWeight, double lossPercentage) {
 return grossWeight * (1 - lossPercentage / 100);
}