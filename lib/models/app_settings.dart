/// User-configurable notification preferences (FR-5.3).
class AppSettings {
  final bool workoutRemindersEnabled;
  final bool mealRemindersEnabled;
  final int workoutLeadMinutes;
  final int mealLeadMinutes;
  final bool missedActivityReengagementEnabled;
  final bool darkMode;

  const AppSettings({
    this.workoutRemindersEnabled = true,
    this.mealRemindersEnabled = true,
    this.workoutLeadMinutes = 10,
    this.mealLeadMinutes = 5,
    this.missedActivityReengagementEnabled = true,
    this.darkMode = false,
  });

  AppSettings copyWith({
    bool? workoutRemindersEnabled,
    bool? mealRemindersEnabled,
    int? workoutLeadMinutes,
    int? mealLeadMinutes,
    bool? missedActivityReengagementEnabled,
    bool? darkMode,
  }) {
    return AppSettings(
      workoutRemindersEnabled:
          workoutRemindersEnabled ?? this.workoutRemindersEnabled,
      mealRemindersEnabled: mealRemindersEnabled ?? this.mealRemindersEnabled,
      workoutLeadMinutes: workoutLeadMinutes ?? this.workoutLeadMinutes,
      mealLeadMinutes: mealLeadMinutes ?? this.mealLeadMinutes,
      missedActivityReengagementEnabled:
          missedActivityReengagementEnabled ??
          this.missedActivityReengagementEnabled,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  Map<String, dynamic> toJson() => {
    'workoutRemindersEnabled': workoutRemindersEnabled,
    'mealRemindersEnabled': mealRemindersEnabled,
    'workoutLeadMinutes': workoutLeadMinutes,
    'mealLeadMinutes': mealLeadMinutes,
    'missedActivityReengagementEnabled': missedActivityReengagementEnabled,
    'darkMode': darkMode,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    workoutRemindersEnabled: json['workoutRemindersEnabled'] as bool? ?? true,
    mealRemindersEnabled: json['mealRemindersEnabled'] as bool? ?? true,
    workoutLeadMinutes: json['workoutLeadMinutes'] as int? ?? 10,
    mealLeadMinutes: json['mealLeadMinutes'] as int? ?? 5,
    missedActivityReengagementEnabled:
        json['missedActivityReengagementEnabled'] as bool? ?? true,
    darkMode: json['darkMode'] as bool? ?? false,
  );
}
