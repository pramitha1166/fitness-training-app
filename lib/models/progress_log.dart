/// A recurring body-metrics / photo check-in (FR-4.3, FR-4.4).
class ProgressLog {
  final String id;
  final DateTime date;
  final double? weightKg;
  final double? waistCm;
  final double? chestCm;
  final double? hipsCm;
  final double? armsCm;
  final String? photoPath;
  final String? notes;

  const ProgressLog({
    required this.id,
    required this.date,
    this.weightKg,
    this.waistCm,
    this.chestCm,
    this.hipsCm,
    this.armsCm,
    this.photoPath,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'weightKg': weightKg,
    'waistCm': waistCm,
    'chestCm': chestCm,
    'hipsCm': hipsCm,
    'armsCm': armsCm,
    'photoPath': photoPath,
    'notes': notes,
  };

  factory ProgressLog.fromJson(Map<String, dynamic> json) => ProgressLog(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    weightKg: (json['weightKg'] as num?)?.toDouble(),
    waistCm: (json['waistCm'] as num?)?.toDouble(),
    chestCm: (json['chestCm'] as num?)?.toDouble(),
    hipsCm: (json['hipsCm'] as num?)?.toDouble(),
    armsCm: (json['armsCm'] as num?)?.toDouble(),
    photoPath: json['photoPath'] as String?,
    notes: json['notes'] as String?,
  );
}
