import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff.dart';

class DemoStaffData {
  static final List<Staff> demoStaff = [
    Staff(
      id: '',
      name: 'John Smith',
      email: 'john.smith@restaurant.com',
      phone: '+1234567890',
      role: 'Manager',
      department: 'Management',
      hireDate: DateTime.now().subtract(const Duration(days: 365)),
      salary: 5000.0,
      hourlyRate: 25.0,
      emergencyContact: '+0987654321',
      address: '123 Main St, City',
      workHoursPerWeek: 40,
      shiftPreference: 'Morning',
    ),
    Staff(
      id: '',
      name: 'Sarah Johnson',
      email: 'sarah.johnson@restaurant.com',
      phone: '+1234567891',
      role: 'Chef',
      department: 'Kitchen',
      hireDate: DateTime.now().subtract(const Duration(days: 730)),
      salary: 4000.0,
      hourlyRate: 20.0,
      emergencyContact: '+0987654322',
      address: '456 Oak Ave, City',
      workHoursPerWeek: 45,
      shiftPreference: 'Evening',
    ),
    Staff(
      id: '',
      name: 'Mike Davis',
      email: 'mike.davis@restaurant.com',
      phone: '+1234567892',
      role: 'Waiter',
      department: 'Service',
      hireDate: DateTime.now().subtract(const Duration(days: 180)),
      salary: 2500.0,
      hourlyRate: 12.5,
      emergencyContact: '+0987654323',
      address: '789 Pine Rd, City',
      workHoursPerWeek: 35,
      shiftPreference: 'Flexible',
    ),
    Staff(
      id: '',
      name: 'Emma Wilson',
      email: 'emma.wilson@restaurant.com',
      phone: '+1234567893',
      role: 'Cashier',
      department: 'Front Desk',
      hireDate: DateTime.now().subtract(const Duration(days: 90)),
      salary: 2200.0,
      hourlyRate: 11.0,
      emergencyContact: '+0987654324',
      address: '321 Elm St, City',
      workHoursPerWeek: 30,
      shiftPreference: 'Morning',
    ),
    Staff(
      id: '',
      name: 'David Brown',
      email: 'david.brown@restaurant.com',
      phone: '+1234567894',
      role: 'Bartender',
      department: 'Bar',
      hireDate: DateTime.now().subtract(const Duration(days: 545)),
      salary: 2800.0,
      hourlyRate: 14.0,
      emergencyContact: '+0987654325',
      address: '654 Maple Dr, City',
      workHoursPerWeek: 35,
      shiftPreference: 'Evening',
    ),
    Staff(
      id: '',
      name: 'Lisa Anderson',
      email: 'lisa.anderson@restaurant.com',
      phone: '+1234567895',
      role: 'Hostess',
      department: 'Service',
      hireDate: DateTime.now().subtract(const Duration(days: 300)),
      salary: 2000.0,
      hourlyRate: 10.0,
      emergencyContact: '+0987654326',
      address: '987 Cedar Ln, City',
      workHoursPerWeek: 25,
      shiftPreference: 'Flexible',
    ),
  ];

  static Future<void> populateDemoData() async {
    final firestore = FirebaseFirestore.instance;
    final staffCollection = firestore.collection('staff');
    
    // Check if staff already exists
    final existingStaff = await staffCollection.limit(1).get();
    if (existingStaff.docs.isNotEmpty) {
      print('Staff data already exists, skipping demo data population');
      return;
    }

    print('Populating demo staff data...');
    
    for (final staff in demoStaff) {
      try {
        await staffCollection.add(staff.toFirestore());
        print('Added staff: ${staff.name}');
      } catch (e) {
        print('Error adding staff ${staff.name}: $e');
      }
    }
    
    print('Demo staff data populated successfully');
  }
}