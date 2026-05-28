import 'package:cloud_firestore/cloud_firestore.dart';

enum AvailabilityStatus { available, unavailable, onLeave }

class StaffAvailability {
  final String id;
  final String staffId;
  final DateTime date; // per-day entry
  final DateTime? startTime; // optional range
  final DateTime? endTime;
  final AvailabilityStatus status;
  final String? notes;

  StaffAvailability({
    required this.id,
    required this.staffId,
    required this.date,
    this.startTime,
    this.endTime,
    this.status = AvailabilityStatus.available,
    this.notes,
  });

  factory StaffAvailability.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StaffAvailability(
      id: doc.id,
      staffId: data['staffId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      status: _statusFromString(data['status'] as String?),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'staffId': staffId,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'status': status.name,
      'notes': notes,
    };
  }

  static AvailabilityStatus _statusFromString(String? s) {
    switch (s) {
      case 'unavailable':
        return AvailabilityStatus.unavailable;
      case 'onLeave':
        return AvailabilityStatus.onLeave;
      case 'available':
      default:
        return AvailabilityStatus.available;
    }
  }
}

