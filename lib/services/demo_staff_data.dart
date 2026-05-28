import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff.dart';

class DemoStaffData {
  static Future<void> populateDemoData() async {
    final firestore = FirebaseFirestore.instance;
    
    // Demo staff data
    final demoStaff = [
      Staff(
        id: 'staff_001',
        name: 'John Smith',
        email: 'john.smith@restaurant.com',
        phone: '+1-555-0101',
        role: 'Manager',
        department: 'Management',
        hourlyRate: 36.0,
        salary: 75000.0,
        hireDate: DateTime(2022, 3, 15),
        isActive: true,
        profileImage: '',
        emergencyContact: '+1-555-0102',
        address: '123 Main St, City, State 12345',
        workHoursPerWeek: 40,
        shiftPreference: 'Morning',
      ),
      Staff(
        id: 'staff_002',
        name: 'Sarah Johnson',
        email: 'sarah.johnson@restaurant.com',
        phone: '+1-555-0201',
        role: 'Chef',
        department: 'Kitchen',
        hourlyRate: 31.25,
        salary: 65000.0,
        hireDate: DateTime(2023, 1, 10),
        isActive: true,
        profileImage: '',
        emergencyContact: '+1-555-0202',
        address: '456 Oak Ave, City, State 12346',
        workHoursPerWeek: 45,
        shiftPreference: 'Evening',
      ),
      Staff(
        id: 'staff_003',
        name: 'Mike Davis',
        email: 'mike.davis@restaurant.com',
        phone: '+1-555-0301',
        role: 'Waiter',
        department: 'Service',
        hourlyRate: 16.83,
        salary: 35000.0,
        hireDate: DateTime(2023, 6, 1),
        isActive: true,
        profileImage: '',
        emergencyContact: '+1-555-0302',
        address: '789 Pine Rd, City, State 12347',
        workHoursPerWeek: 30,
        shiftPreference: 'Flexible',
      ),
      Staff(
        id: 'staff_004',
        name: 'Emily Wilson',
        email: 'emily.wilson@restaurant.com',
        phone: '+1-555-0401',
        role: 'Hostess',
        department: 'Front Desk',
        hourlyRate: 14.42,
        salary: 30000.0,
        hireDate: DateTime(2023, 9, 15),
        isActive: true,
        profileImage: '',
        emergencyContact: '+1-555-0402',
        address: '321 Elm St, City, State 12348',
        workHoursPerWeek: 25,
        shiftPreference: 'Morning',
      ),
      Staff(
        id: 'staff_005',
        name: 'David Brown',
        email: 'david.brown@restaurant.com',
        phone: '+1-555-0501',
        role: 'Dishwasher',
        department: 'Kitchen',
        hourlyRate: 13.46,
        salary: 28000.0,
        hireDate: DateTime(2023, 11, 20),
        isActive: true,
        profileImage: '',
        emergencyContact: '+1-555-0502',
        address: '654 Maple Dr, City, State 12349',
        workHoursPerWeek: 35,
        shiftPreference: 'Evening',
      ),
    ];

    // Add demo staff to Firestore
    for (final staff in demoStaff) {
      await firestore
          .collection('staff')
          .doc(staff.id)
          .set(staff.toFirestore());
    }

    // Add demo attendance records
    final now = DateTime.now();
    for (final staff in demoStaff) {
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final checkIn = DateTime(date.year, date.month, date.day, 8 + i, 0);
        final checkOut = DateTime(date.year, date.month, date.day, 17 + i, 0);
        
        await firestore
            .collection('attendance')
            .doc('${staff.id}_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}')
            .set({
          'staffId': staff.id,
          'date': Timestamp.fromDate(date),
          'checkIn': Timestamp.fromDate(checkIn),
          'checkOut': Timestamp.fromDate(checkOut),
          'hoursWorked': 8.0,
          'status': 'Present',
          'notes': 'Regular shift',
        });
      }
    }

    // Add demo schedules
    for (final staff in demoStaff) {
      final schedule = {
        'staffId': staff.id,
        'weekStart': Timestamp.fromDate(now.subtract(Duration(days: now.weekday - 1))),
        'monday': {'start': '09:00', 'end': '17:00', 'status': 'Scheduled'},
        'tuesday': {'start': '09:00', 'end': '17:00', 'status': 'Scheduled'},
        'wednesday': {'start': '09:00', 'end': '17:00', 'status': 'Scheduled'},
        'thursday': {'start': '09:00', 'end': '17:00', 'status': 'Scheduled'},
        'friday': {'start': '09:00', 'end': '17:00', 'status': 'Scheduled'},
        'saturday': {'start': '10:00', 'end': '18:00', 'status': 'Scheduled'},
        'sunday': {'start': '10:00', 'end': '16:00', 'status': 'Scheduled'},
      };
      
      await firestore
          .collection('schedules')
          .doc('${staff.id}_${now.year}_${(now.weekday / 7).ceil()}')
          .set(schedule);
    }

    print('Demo staff data populated successfully!');
  }
}