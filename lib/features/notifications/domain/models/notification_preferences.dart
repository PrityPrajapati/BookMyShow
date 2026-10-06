import 'dart:convert';

/// User preferences for booking notifications and smart transit alerts
class NotificationPreferences {
  final bool remind24h;
  final bool remind3h;
  final bool remind45m;
  final bool smartLeaveNow;
  final bool fcmPromotions;

  const NotificationPreferences({
    this.remind24h = true,
    this.remind3h = true,
    this.remind45m = true,
    this.smartLeaveNow = true,
    this.fcmPromotions = true,
  });

  NotificationPreferences copyWith({
    bool? remind24h,
    bool? remind3h,
    bool? remind45m,
    bool? smartLeaveNow,
    bool? fcmPromotions,
  }) {
    return NotificationPreferences(
      remind24h: remind24h ?? this.remind24h,
      remind3h: remind3h ?? this.remind3h,
      remind45m: remind45m ?? this.remind45m,
      smartLeaveNow: smartLeaveNow ?? this.smartLeaveNow,
      fcmPromotions: fcmPromotions ?? this.fcmPromotions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'remind24h': remind24h,
      'remind3h': remind3h,
      'remind45m': remind45m,
      'smartLeaveNow': smartLeaveNow,
      'fcmPromotions': fcmPromotions,
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      remind24h: map['remind24h'] as bool? ?? true,
      remind3h: map['remind3h'] as bool? ?? true,
      remind45m: map['remind45m'] as bool? ?? true,
      smartLeaveNow: map['smartLeaveNow'] as bool? ?? true,
      fcmPromotions: map['fcmPromotions'] as bool? ?? true,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory NotificationPreferences.fromJson(String source) =>
      NotificationPreferences.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferences &&
          runtimeType == other.runtimeType &&
          remind24h == other.remind24h &&
          remind3h == other.remind3h &&
          remind45m == other.remind45m &&
          smartLeaveNow == other.smartLeaveNow &&
          fcmPromotions == other.fcmPromotions;

  @override
  int get hashCode =>
      remind24h.hashCode ^
      remind3h.hashCode ^
      remind45m.hashCode ^
      smartLeaveNow.hashCode ^
      fcmPromotions.hashCode;
}
