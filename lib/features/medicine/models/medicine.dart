import 'package:flutter/material.dart';

enum MedicineType {
  capsule,
  syrup,
  injection,
}

extension MedicineTypeX on MedicineType {
  String get label {
    switch (this) {
      case MedicineType.capsule:
        return 'Capsule';
      case MedicineType.syrup:
        return 'Syrup';
      case MedicineType.injection:
        return 'Injection';
    }
  }

  IconData get icon {
    switch (this) {
      case MedicineType.capsule:
        return Icons.medication_rounded;
      case MedicineType.syrup:
        return Icons.local_drink_rounded;
      case MedicineType.injection:
        return Icons.vaccines_rounded;
    }
  }

  static MedicineType fromName(String value) {
    return MedicineType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => MedicineType.capsule,
    );
  }
}

class Medicine {
  const Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.type,
    required this.hour,
    required this.minute,
    required this.days,
    this.isDone = false,
    this.isSkipped = false,
  });

  final String id;
  final String name;
  final String dosage;
  final MedicineType type;
  final int hour;
  final int minute;
  final List<String> days;
  final bool isDone;
  final bool isSkipped;

  static const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'dosage': dosage,
      'type': type.name,
      'hour': hour,
      'minute': minute,
      'days': days,
      'isDone': isDone,
      'isSkipped': isSkipped,
    };
  }

  factory Medicine.fromFirestore(String id, Map<String, dynamic> data) {
    return Medicine(
      id: id,
      name: data['name'] as String? ?? '',
      dosage: data['dosage'] as String? ?? '',
      type: MedicineTypeX.fromName(data['type'] as String? ?? ''),
      hour: (data['hour'] as num?)?.toInt() ?? 9,
      minute: (data['minute'] as num?)?.toInt() ?? 0,
      days: List<String>.from(data['days'] as List? ?? const []),
      isDone: data['isDone'] as bool? ?? false,
      isSkipped: data['isSkipped'] as bool? ?? false,
    );
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    MedicineType? type,
    int? hour,
    int? minute,
    List<String>? days,
    bool? isDone,
    bool? isSkipped,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      type: type ?? this.type,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      days: days ?? this.days,
      isDone: isDone ?? this.isDone,
      isSkipped: isSkipped ?? this.isSkipped,
    );
  }

  static int dayNumber(String day) {
    switch (day) {
      case 'Mon':
        return DateTime.monday;
      case 'Tue':
        return DateTime.tuesday;
      case 'Wed':
        return DateTime.wednesday;
      case 'Thu':
        return DateTime.thursday;
      case 'Fri':
        return DateTime.friday;
      case 'Sat':
        return DateTime.saturday;
      case 'Sun':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }
}
