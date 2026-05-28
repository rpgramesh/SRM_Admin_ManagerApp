import 'package:flutter/material.dart';
import '../../models/shift.dart';
import '../../models/staff.dart';
import '../../services/shift_service.dart';
import '../../services/staff_service.dart';
import '../../theme/design_tokens.dart';

class AddShiftScreen extends StatefulWidget {
  final DateTime initialDate;

  const AddShiftScreen({super.key, required this.initialDate});

  @override
  State<AddShiftScreen> createState() => _AddShiftScreenState();
}

class _AddShiftScreenState extends State<AddShiftScreen> {
  final _formKey = GlobalKey<FormState>();
  final ShiftService _shiftService = ShiftService();
  final StaffService _staffService = StaffService();

  late DateTime _startDate;
  late DateTime _endDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  String _role = 'Waitstaff';
  String? _selectedStaffId;

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _roles = ['Waitstaff', 'Chef', 'Manager', 'Bartender', 'Cleaner'];
  List<Staff> _staffList = [];
  bool _isLoadingStaff = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Normalize to midnight to avoid time diff issues when adding days
    _startDate = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day);
    _endDate = _startDate;
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    _staffService.getAllStaff().listen((staff) {
      if (mounted) {
        setState(() {
          _staffList = staff;
          _isLoadingStaff = false;
        });
      }
    }, onError: (e) {
      if (mounted) {
        setState(() => _isLoadingStaff = false);
      }
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveShift() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate.isAfter(_endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start Date cannot be after End Date'),
          backgroundColor: DesignTokens.warningOrange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Calculate how many days we are scheduling for
      int days = DateTime.utc(_endDate.year, _endDate.month, _endDate.day)
          .difference(DateTime.utc(_startDate.year, _startDate.month, _startDate.day))
          .inDays;

      for (int i = 0; i <= days; i++) {
        DateTime currentDay = _startDate.add(Duration(days: i));

        DateTime startDateTime = DateTime(
          currentDay.year,
          currentDay.month,
          currentDay.day,
          _startTime.hour,
          _startTime.minute,
        );

        DateTime endDateTime = DateTime(
          currentDay.year,
          currentDay.month,
          currentDay.day,
          _endTime.hour,
          _endTime.minute,
        );

        // Handle overnight shifts
        if (_endTime.hour < _startTime.hour || (_endTime.hour == _startTime.hour && _endTime.minute < _startTime.minute)) {
          endDateTime = endDateTime.add(const Duration(days: 1));
        }

        final shift = Shift(
          id: '',
          date: currentDay,
          startTime: startDateTime,
          endTime: endDateTime,
          role: _role,
          location: _locationController.text.isNotEmpty ? _locationController.text : null,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          assignedStaffIds: _selectedStaffId != null ? [_selectedStaffId!] : [],
          status: _selectedStaffId != null ? ShiftStatus.assigned : ShiftStatus.draft,
          createdBy: 'manager', 
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _shiftService.createShift(shift);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shift(s) created successfully'),
            backgroundColor: DesignTokens.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating shift: $e'),
            backgroundColor: DesignTokens.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Shift', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: DesignTokens.managerBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assign Staff (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: DesignTokens.space8),
                    _isLoadingStaff
                        ? const CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            value: _selectedStaffId,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            hint: const Text('Select a staff member...'),
                            items: [
                              const DropdownMenuItem<String>(value: null, child: Text('Unassigned / Open Shift')),
                              for (var staff in _staffList)
                                DropdownMenuItem<String>(value: staff.id, child: Text('${staff.name} (${staff.role})')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedStaffId = val;
                                // Automatically pick role if possible
                                if (val != null) {
                                  final selectedStaff = _staffList.firstWhere((s) => s.id == val);
                                  if (_roles.contains(selectedStaff.role)) {
                                    _role = selectedStaff.role;
                                  }
                                }
                              });
                            },
                          ),
                    const SizedBox(height: DesignTokens.space16),

                    const Text('Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: DesignTokens.space8),
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: [
                        for (var r in _roles)
                          DropdownMenuItem<String>(value: r, child: Text(r)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _role = val);
                      },
                    ),
                    const SizedBox(height: DesignTokens.space16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: DesignTokens.space8),
                              InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate,
                                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _startDate = date;
                                      if (_endDate.isBefore(_startDate)) {
                                        _endDate = _startDate;
                                      }
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                                      const Icon(Icons.calendar_today, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: DesignTokens.space8),
                              InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate,
                                    firstDate: _startDate,
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (date != null) setState(() => _endDate = date);
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                                      const Icon(Icons.calendar_today, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: DesignTokens.space8),
                              InkWell(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: _startTime,
                                  );
                                  if (time != null) setState(() => _startTime = time);
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}'),
                                      const Icon(Icons.access_time, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: DesignTokens.space8),
                              InkWell(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: _endTime,
                                  );
                                  if (time != null) setState(() => _endTime = time);
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}'),
                                      const Icon(Icons.access_time, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space16),

                    const Text('Location / Station (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: DesignTokens.space8),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g. Front Desk, Grill',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space16),

                    const Text('Notes (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: DesignTokens.space8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Any special instructions...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveShift,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignTokens.managerBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                          ),
                        ),
                        child: const Text('Save Shift(s)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
