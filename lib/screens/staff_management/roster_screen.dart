import 'package:flutter/material.dart';
import '../../services/shift_service.dart';
import '../../models/shift.dart';
import '../../theme/design_tokens.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final ShiftService _shiftService = ShiftService();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDateSelector(),
        Expanded(
          child: StreamBuilder<List<Shift>>(
            stream: _shiftService.getShiftsForDate(_selectedDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading shifts: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red)),
                );
              }

              final shifts = snapshot.data ?? [];

              if (shifts.isEmpty) {
                return const Center(
                  child: Text(
                    'No shifts scheduled for this date.',
                    style: TextStyle(
                      fontSize: 16,
                      color: DesignTokens.neutralGrey500,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(DesignTokens.space16),
                itemCount: shifts.length,
                itemBuilder: (context, index) {
                  final shift = shifts[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: DesignTokens.space12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                    ),
                    child: ListTile(
                      title: Text(shift.role, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${_formatTime(shift.startTime)} - ${_formatTime(shift.endTime)}\nAssignees: ${shift.assignedStaffIds.isNotEmpty ? shift.assignedStaffIds.length : 'None'}',
                      ),
                      trailing: _buildStatusChip(shift.status),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.space16, horizontal: DesignTokens.space16),
      decoration: const BoxDecoration(
        color: DesignTokens.neutralWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            child: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusChip(ShiftStatus status) {
    Color bgColor;
    Color textColor = Colors.white;
    switch (status) {
      case ShiftStatus.draft:
        bgColor = Colors.grey;
        break;
      case ShiftStatus.scheduled:
        bgColor = Colors.blue;
        break;
      case ShiftStatus.assigned:
        bgColor = Colors.orange;
        break;
      case ShiftStatus.inProgress:
        bgColor = Colors.green;
        break;
      case ShiftStatus.completed:
        bgColor = Colors.black45;
        break;
      case ShiftStatus.cancelled:
        bgColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
