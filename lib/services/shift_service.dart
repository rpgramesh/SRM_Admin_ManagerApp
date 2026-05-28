import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shift.dart';
import '../models/shift_swap_request.dart';

class ShiftService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _shifts => _db.collection('shifts');
  CollectionReference get _swapRequests =>
      _db.collection('shift_swap_requests');

  // Create shift
  Future<String> createShift(Shift shift) async {
    final doc = await _shifts.add(shift.toFirestore());
    return doc.id;
  }

  // Batch create shifts (chunks of <= 450 to stay below 500 op limit)
  Future<List<String>> createShiftsBatch(List<Shift> shifts) async {
    final ids = <String>[];
    const int maxOps = 450; // conservative buffer for potential extra ops
    for (var i = 0; i < shifts.length; i += maxOps) {
      final batch = _db.batch();
      final slice = shifts.sublist(
          i, i + maxOps > shifts.length ? shifts.length : i + maxOps);
      for (final s in slice) {
        final doc = _shifts.doc();
        ids.add(doc.id);
        batch.set(doc, s.toFirestore());
      }
      await batch.commit();
    }
    return ids;
  }

  // Update shift
  Future<void> updateShift(Shift shift) async {
    await _shifts.doc(shift.id).update(shift.toFirestore());
  }

  // Assign staff to shift (idempotent)
  Future<void> assignStaff(
      {required String shiftId, required String staffId}) async {
    await _shifts.doc(shiftId).update({
      'assignedStaffIds': FieldValue.arrayUnion([staffId]),
      'status': ShiftStatus.assigned.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unassignStaff(
      {required String shiftId, required String staffId}) async {
    await _shifts.doc(shiftId).update({
      'assignedStaffIds': FieldValue.arrayRemove([staffId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Batch assign staff to a single shift
  Future<void> assignStaffBatch(
      {required String shiftId, required Iterable<String> staffIds}) async {
    if (staffIds.isEmpty) return;
    await _shifts.doc(shiftId).update({
      'assignedStaffIds': FieldValue.arrayUnion(List<String>.from(staffIds)),
      'status': ShiftStatus.assigned.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Batch create and assign: map of shift -> staffIds
  Future<List<String>> createAndAssignBatch(
      Map<Shift, Iterable<String>> items) async {
    final ids = <String>[];
    // We perform in two phases to avoid arrayUnion on not-yet-existing docs in same batch
    final createdIds = await createShiftsBatch(items.keys.toList());
    int index = 0;
    for (final entry in items.entries) {
      final shiftId = createdIds[index++];
      if (entry.value.isNotEmpty) {
        await assignStaffBatch(shiftId: shiftId, staffIds: entry.value);
      }
      ids.add(shiftId);
    }
    return ids;
  }

  // Streams
  Stream<List<Shift>> getShiftsForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    // Remove orderBy to avoid composite index requirement; sort client-side.
    return _shifts
        .where('date', isEqualTo: Timestamp.fromDate(d))
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(Shift.fromFirestore).toList();
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
      return list;
    });
  }

  Stream<List<Shift>> getShiftsForRange(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return _shifts
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(s))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(e))
        .orderBy('date')
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs.map(Shift.fromFirestore).toList());
  }

  Stream<List<Shift>> getShiftsForStaff(String staffId,
      {DateTime? start, DateTime? end}) {
    Query q = _shifts.where('assignedStaffIds', arrayContains: staffId);
    if (start != null) {
      q = q.where('date',
          isGreaterThanOrEqualTo:
              Timestamp.fromDate(DateTime(start.year, start.month, start.day)));
    }
    if (end != null) {
      q = q.where('date',
          isLessThanOrEqualTo:
              Timestamp.fromDate(DateTime(end.year, end.month, end.day)));
    }
    return q
        .orderBy('date')
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs.map(Shift.fromFirestore).toList());
  }

  // Swap Requests
  Future<String> requestSwap(ShiftSwapRequest request) async {
    final doc = await _swapRequests.add(request.toFirestore());
    return doc.id;
  }

  Future<void> approveSwap(String requestId) async {
    await _swapRequests.doc(requestId).update({
      'status': SwapRequestStatus.approved.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Additional business rules handled externally (e.g., reassign staff)
  }

  Future<void> denySwap(String requestId, {String? comment}) async {
    await _swapRequests.doc(requestId).update({
      'status': SwapRequestStatus.denied.name,
      'managerComment': comment,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ShiftSwapRequest>> getSwapRequests({String? shiftId}) {
    Query q = _swapRequests;
    if (shiftId != null) q = q.where('shiftId', isEqualTo: shiftId);
    return q
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ShiftSwapRequest.fromFirestore).toList());
  }

  // Validation helpers (pure)
  bool hasConflict(Shift a, Shift b) {
    // Same date and overlapping time window
    if (DateTime(a.date.year, a.date.month, a.date.day) !=
        DateTime(b.date.year, b.date.month, b.date.day)) {
      return false;
    }
    return a.startTime.isBefore(b.endTime) && b.startTime.isBefore(a.endTime);
  }
}
