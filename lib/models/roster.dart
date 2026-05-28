import 'package:cloud_firestore/cloud_firestore.dart';

class Roster {
  final String id;
  final DateTime weekStart; // Monday start
  final DateTime weekEnd; // Sunday end
  final bool isPublished;
  final List<String> shiftIds;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  Roster({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    this.isPublished = false,
    this.shiftIds = const [],
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory Roster.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Roster(
      id: doc.id,
      weekStart: (data['weekStart'] as Timestamp).toDate(),
      weekEnd: (data['weekEnd'] as Timestamp).toDate(),
      isPublished: data['isPublished'] ?? false,
      shiftIds: List<String>.from(data['shiftIds'] ?? const []),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'weekStart': Timestamp.fromDate(_startOfDay(weekStart)),
      'weekEnd': Timestamp.fromDate(_startOfDay(weekEnd)),
      'isPublished': isPublished,
      'shiftIds': shiftIds,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
    };
  }

  static DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
}

