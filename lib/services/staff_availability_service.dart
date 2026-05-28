import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff_availability.dart';

class StaffAvailabilityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _availability => _db.collection('staff_availability');

  Future<String> setAvailability(StaffAvailability availability) async {
    final doc = await _availability.add(availability.toFirestore());
    return doc.id;
  }

  Future<void> updateAvailability(StaffAvailability availability) async {
    await _availability.doc(availability.id).update(availability.toFirestore());
  }

  Stream<List<StaffAvailability>> getAvailabilityForStaff(String staffId, {DateTime? start, DateTime? end}) {
    Query q = _availability.where('staffId', isEqualTo: staffId);
    if (start != null) {
      q = q.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(start.year, start.month, start.day)));
    }
    if (end != null) {
      q = q.where('date', isLessThanOrEqualTo: Timestamp.fromDate(DateTime(end.year, end.month, end.day)));
    }
    return q.orderBy('date').snapshots().map((snap) => snap.docs.map(StaffAvailability.fromFirestore).toList());
  }

  Stream<List<StaffAvailability>> getAvailabilityForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return _availability
        .where('date', isEqualTo: Timestamp.fromDate(d))
        .snapshots()
        .map((snap) => snap.docs.map(StaffAvailability.fromFirestore).toList());
  }

  // Simple check: is staff available for entire shift window
  bool isAvailableDuring(StaffAvailability? a, DateTime start, DateTime end) {
    if (a == null) return true; // default available
    switch (a.status) {
      case AvailabilityStatus.unavailable:
      case AvailabilityStatus.onLeave:
        return false;
      case AvailabilityStatus.available:
        if (a.startTime == null || a.endTime == null) return true;
        return a.startTime!.isBefore(end) && a.endTime!.isAfter(start);
    }
  }
}

