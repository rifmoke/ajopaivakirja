enum ReminderType {
  inspection, // Katsastus
  service, // Huolto
  insurance, // Vakuutus
  tax, // Vero
  tireChange, // Rengasvaihto
  other, // Muu
}

enum ReminderTrigger {
  date, // Päivämäärä
  mileage, // Kilometrimäärä
  both, // Molemmat
}

class Reminder {
  final int? id;
  final int vehicleId;
  final String title;
  final String? description;
  final ReminderType type;
  final ReminderTrigger trigger;
  final DateTime? targetDate;
  final int? targetMileage;
  final int? notifyDaysBefore;
  final int? notifyMileageBefore;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  Reminder({
    this.id,
    required this.vehicleId,
    required this.title,
    this.description,
    required this.type,
    required this.trigger,
    this.targetDate,
    this.targetMileage,
    this.notifyDaysBefore,
    this.notifyMileageBefore,
    this.isCompleted = false,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'title': title,
      'description': description,
      'type': type.name,
      'trigger': trigger.name,
      'targetDate': targetDate?.toIso8601String(),
      'targetMileage': targetMileage,
      'notifyDaysBefore': notifyDaysBefore,
      'notifyMileageBefore': notifyMileageBefore,
      'isCompleted': isCompleted ? 1 : 0,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      vehicleId: map['vehicleId'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      type: ReminderType.values.firstWhere((e) => e.name == map['type']),
      trigger: ReminderTrigger.values.firstWhere((e) => e.name == map['trigger']),
      targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate'] as String) : null,
      targetMileage: map['targetMileage'] as int?,
      notifyDaysBefore: map['notifyDaysBefore'] as int?,
      notifyMileageBefore: map['notifyMileageBefore'] as int?,
      isCompleted: (map['isCompleted'] as int) == 1,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Reminder copyWith({
    int? id,
    int? vehicleId,
    String? title,
    String? description,
    ReminderType? type,
    ReminderTrigger? trigger,
    DateTime? targetDate,
    int? targetMileage,
    int? notifyDaysBefore,
    int? notifyMileageBefore,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      trigger: trigger ?? this.trigger,
      targetDate: targetDate ?? this.targetDate,
      targetMileage: targetMileage ?? this.targetMileage,
      notifyDaysBefore: notifyDaysBefore ?? this.notifyDaysBefore,
      notifyMileageBefore: notifyMileageBefore ?? this.notifyMileageBefore,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static String getTypeLabel(ReminderType type) {
    switch (type) {
      case ReminderType.inspection:
        return 'Katsastus';
      case ReminderType.service:
        return 'Huolto';
      case ReminderType.insurance:
        return 'Vakuutus';
      case ReminderType.tax:
        return 'Vero';
      case ReminderType.tireChange:
        return 'Rengasvaihto';
      case ReminderType.other:
        return 'Muu';
    }
  }

  static String getTriggerLabel(ReminderTrigger trigger) {
    switch (trigger) {
      case ReminderTrigger.date:
        return 'Päivämäärä';
      case ReminderTrigger.mileage:
        return 'Kilometrit';
      case ReminderTrigger.both:
        return 'Molemmat';
    }
  }
}
