import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/roster.dart';

class RosterService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _rosters => _db.collection('rosters');

  Future<String> createRoster(Roster roster) async {
    final doc = await _rosters.add(roster.toFirestore());
    return doc.id;
  }

  Future<void> updateRoster(Roster roster) async {
    await _rosters.doc(roster.id).update(roster.toFirestore());
  }

  Future<void> publishRoster(String rosterId) async {
    await _rosters.doc(rosterId).update({
      'isPublished': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<Roster?> getRosterForWeek(DateTime weekStart) {
    final start = _mondayOfWeek(weekStart);
    final end = start.add(const Duration(days: 6));
    return _rosters
        .where('weekStart', isEqualTo: Timestamp.fromDate(start))
        .where('weekEnd', isEqualTo: Timestamp.fromDate(end))
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty ? Roster.fromFirestore(snap.docs.first) : null);
  }

  Stream<List<Roster>> getMonthlyRosters(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    return _rosters
        .where('weekStart', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('weekStart', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('weekStart')
        .snapshots()
        .map((snap) => snap.docs.map(Roster.fromFirestore).toList());
  }

  static DateTime _mondayOfWeek(DateTime d) {
    final wd = d.weekday; // 1..7
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: wd - 1));
  }
}

