import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/models/shift.dart';
import 'package:restaurant_app/services/shift_service.dart';

void main() {
  group('Shift conflict detection', () {
    final service = ShiftService();
    final date = DateTime(2025, 1, 1);

    Shift s(DateTime start, DateTime end) => Shift(
          id: 'x',
          date: date,
          startTime: start,
          endTime: end,
          role: 'Waiter',
          createdBy: 'manager',
          createdAt: date,
          updatedAt: date,
        );

    test('Non-overlapping shifts', () {
      final a = s(DateTime(2025, 1, 1, 8), DateTime(2025, 1, 1, 12));
      final b = s(DateTime(2025, 1, 1, 12), DateTime(2025, 1, 1, 16));
      expect(service.hasConflict(a, b), false);
    });

    test('Overlapping shifts', () {
      final a = s(DateTime(2025, 1, 1, 8), DateTime(2025, 1, 1, 12));
      final b = s(DateTime(2025, 1, 1, 11), DateTime(2025, 1, 1, 15));
      expect(service.hasConflict(a, b), true);
    });

    test('Different dates no conflict', () {
      final a = s(DateTime(2025, 1, 1, 8), DateTime(2025, 1, 1, 12));
      final b = Shift(
        id: 'y',
        date: DateTime(2025, 1, 2),
        startTime: DateTime(2025, 1, 2, 8),
        endTime: DateTime(2025, 1, 2, 12),
        role: 'Waiter',
        createdBy: 'manager',
        createdAt: date,
        updatedAt: date,
      );
      expect(service.hasConflict(a, b), false);
    });
  });
}

