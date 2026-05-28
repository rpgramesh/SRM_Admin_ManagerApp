import 'package:cloud_firestore/cloud_firestore.dart';

enum ShiftStatus { draft, scheduled, assigned, inProgress, completed, cancelled }

class Shift {
  final String id;
  final DateTime date; // normalized to start of day
  final DateTime startTime;
  final DateTime endTime;
  final String role; // e.g., Chef, Waiter
  final String? location; // section or station
  final String? notes;
  final ShiftStatus status;
  final List<String> assignedStaffIds;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Shift({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.role,
    this.location,
    this.notes,
    this.status = ShiftStatus.draft,
    this.assignedStaffIds = const [],
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Shift.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Shift(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      role: data['role'] ?? '',
      location: data['location'],
      notes: data['notes'],
      status: _statusFromString(data['status'] as String?),
      assignedStaffIds: List<String>.from(data['assignedStaffIds'] ?? const []),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'role': role,
      'location': location,
      'notes': notes,
      'status': status.name,
      'assignedStaffIds': assignedStaffIds,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static ShiftStatus _statusFromString(String? s) {
    switch (s) {
      case 'scheduled':
        return ShiftStatus.scheduled;
      case 'assigned':
        return ShiftStatus.assigned;
      case 'inProgress':
        return ShiftStatus.inProgress;
      case 'completed':
        return ShiftStatus.completed;
      case 'cancelled':
        return ShiftStatus.cancelled;
      case 'draft':
      default:
        return ShiftStatus.draft;
    }
  }
}

