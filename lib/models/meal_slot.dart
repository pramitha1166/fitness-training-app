import 'enums.dart';
import 'time_slot.dart';

/// A declared availability window tagged with which meal it's for
/// (FR-1.4: breakfast / lunch / dinner / snack windows).
class MealSlot {
  final MealType type;
  final TimeSlot slot;

  const MealSlot({required this.type, required this.slot});

  Map<String, dynamic> toJson() => {'type': type.name, 'slot': slot.toJson()};

  factory MealSlot.fromJson(Map<String, dynamic> json) => MealSlot(
    type: MealType.values.byName(json['type'] as String),
    slot: TimeSlot.fromJson(json['slot'] as Map<String, dynamic>),
  );

  MealSlot copyWith({MealType? type, TimeSlot? slot}) =>
      MealSlot(type: type ?? this.type, slot: slot ?? this.slot);
}
