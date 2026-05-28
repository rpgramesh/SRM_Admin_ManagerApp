import 'package:flutter/foundation.dart';
import '../models/staff.dart';
import '../services/staff_service.dart';

class StaffProvider with ChangeNotifier {
  final StaffService _staffService = StaffService();
  
  List<Staff> _staffList = [];
  List<Staff> _filteredStaffList = [];
  Map<String, dynamic> _dashboardData = {};
  List<Map<String, dynamic>> _todayAttendance = [];
  List<Map<String, dynamic>> _scheduleList = [];
  Map<String, bool> _checkInStatus = {};
  
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  String _filterDepartment = '';

  // Getters
  List<Staff> get staffList => _filteredStaffList;
  List<Staff> get allStaff => _staffList;
  Map<String, dynamic> get dashboardData => _dashboardData;
  List<Map<String, dynamic>> get todayAttendance => _todayAttendance;
  List<Map<String, dynamic>> get scheduleList => _scheduleList;
  Map<String, bool> get checkInStatus => _checkInStatus;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;
  String get filterDepartment => _filterDepartment;

  // Initialize provider
  Future<void> initialize() async {
    await loadStaff();
    await loadDashboardData();
    await loadTodayAttendance();
    await loadCheckInStatus();
  }

  // Populate demo data
  Future<void> populateDemoData() async {
    _setLoading(true);
    try {
      await _staffService.populateDemoData();
      await loadStaff();
      await loadDashboardData();
      await loadTodayAttendance();
      await loadCheckInStatus();
      _setError('');
    } catch (e) {
      _setError('Failed to populate demo data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all staff
  Future<void> loadStaff() async {
    _setLoading(true);
    try {
      _staffService.getAllStaff().listen((staffList) {
        _staffList = staffList;
        _applyFilters();
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load staff: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load staff by department
  Future<void> loadStaffByDepartment(String department) async {
    _setLoading(true);
    try {
      _staffService.getStaffByDepartment(department).listen((staffList) {
        _staffList = staffList;
        _applyFilters();
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load staff: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load dashboard data - Real-time updates
  Future<void> loadDashboardData() async {
    try {
      _staffService.getStaffDashboardData().listen((data) {
        _dashboardData = data;
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load dashboard data: $e');
    }
  }

  // Load today's attendance
  Future<void> loadTodayAttendance() async {
    try {
      _staffService.getTodayAttendance().listen((attendance) {
        _todayAttendance = attendance;
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load attendance: $e');
    }
  }

  // Load check-in status for all staff - Real-time updates
  Future<void> loadCheckInStatus() async {
    try {
      _staffService.getAllCheckInStatus().listen((statusMap) {
        _checkInStatus = statusMap;
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load check-in status: $e');
    }
  }

  // Check-in staff
  Future<void> checkInStaff(String staffId) async {
    try {
      await _staffService.checkIn(staffId);
      _checkInStatus[staffId] = true;
      await loadTodayAttendance();
      await loadDashboardData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to check in: $e');
    }
  }

  // Check-out staff
  Future<void> checkOutStaff(String staffId) async {
    try {
      await _staffService.checkOut(staffId);
      _checkInStatus[staffId] = false;
      await loadTodayAttendance();
      await loadDashboardData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to check out: $e');
    }
  }

  // Add new staff
  Future<void> addStaff(Staff staff) async {
    _setLoading(true);
    try {
      await _staffService.addStaff(staff);
      await loadStaff();
      _setError('');
    } catch (e) {
      _setError('Failed to add staff: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update staff
  Future<void> updateStaff(Staff staff) async {
    _setLoading(true);
    try {
      await _staffService.updateStaff(staff);
      await loadStaff();
      _setError('');
    } catch (e) {
      _setError('Failed to update staff: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete staff
  Future<void> deleteStaff(String staffId) async {
    _setLoading(true);
    try {
      await _staffService.deleteStaff(staffId);
      await loadStaff();
      _setError('');
    } catch (e) {
      _setError('Failed to delete staff: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get staff by ID
  Future<Staff?> getStaff(String staffId) async {
    try {
      return await _staffService.getStaff(staffId);
    } catch (e) {
      _setError('Failed to get staff: $e');
      return null;
    }
  }

  // Get attendance history
  Future<List<Map<String, dynamic>>> getAttendanceHistory(
    String staffId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _staffService.getAttendanceHistory(
        staffId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _setError('Failed to get attendance history: $e');
      return [];
    }
  }

  // Schedule management
  Future<void> addSchedule({
    required String staffId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      await _staffService.addSchedule(
        staffId: staffId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );
      await loadScheduleForDate(date);
    } catch (e) {
      _setError('Failed to add schedule: $e');
    }
  }

  Future<void> loadScheduleForDate(DateTime date) async {
    try {
      _staffService.getScheduleForDate(date).listen((schedule) {
        _scheduleList = schedule;
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load schedule: $e');
    }
  }

  // Search and filter functionality
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setDepartmentFilter(String department) {
    _filterDepartment = department;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterDepartment = '';
    _applyFilters();
  }

  void _applyFilters() {
    _filteredStaffList = _staffList.where((staff) {
      final matchesSearch = _searchQuery.isEmpty ||
          staff.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          staff.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          staff.role.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesDepartment = _filterDepartment.isEmpty ||
          staff.department == _filterDepartment;

      return matchesSearch && matchesDepartment;
    }).toList();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Get departments list
  List<String> get departments {
    final departments = _staffList.map((staff) => staff.department).toSet();
    return departments.toList()..sort();
  }

  // Get roles list
  List<String> get roles {
    final roles = _staffList.map((staff) => staff.role).toSet();
    return roles.toList()..sort();
  }
}