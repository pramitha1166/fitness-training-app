import 'enums.dart';

/// A single available window on a given day, used both for workout
/// availability and meal availability (FR-1.3, FR-1.4).
class TimeSlot {
  final WeekDay day;
  final int startHour;
  final int startMinute;
  final int durationMinutes;

  const TimeSlot({
    required this.day,
    required this.startHour,
    required this.startMinute,
    required this.durationMinutes,
  });

  int get startMinutesOfDay => startHour * 60 + startMinute;

  String get startTimeLabel {
    final h = startHour % 24;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    final minute = startMinute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }

  Map<String, dynamic> toJson() => {
    'day': day.name,
    'startHour': startHour,
    'startMinute': startMinute,
    'durationMinutes': durationMinutes,
  };

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
    day: WeekDay.values.byName(json['day'] as String),
    startHour: json['startHour'] as int,
    startMinute: json['startMinute'] as int,
    durationMinutes: json['durationMinutes'] as int,
  );

  TimeSlot copyWith({
    WeekDay? day,
    int? startHour,
    int? startMinute,
    int? durationMinutes,
  }) {
    return TimeSlot(
      day: day ?? this.day,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}
