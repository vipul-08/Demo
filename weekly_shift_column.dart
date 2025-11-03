import 'package:flutter/material.dart';

class WeeklyShiftCompactView extends StatelessWidget {
  WeeklyShiftCompactView({super.key});

  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  final Map<String, List<Map<String, String>>> shiftsByDay = {
    'Mon': [
      {'name': 'Alice', 'shift': 'leave'},
      {'name': 'Bob', 'shift': 'morning'},
      {'name': 'John', 'shift': 'day'},
      {'name': 'Eve', 'shift': 'night'},
    ],
    'Tue': [
      {'name': 'Eve', 'shift': 'leave'},
      {'name': 'Bob', 'shift': 'morning'},
      {'name': 'Alice', 'shift': 'day'},
      {'name': 'John', 'shift': 'night'},
    ],
    'Wed': [
      {'name': 'John', 'shift': 'morning'},
      {'name': 'Alice', 'shift': 'day'},
      {'name': 'Bob', 'shift': 'night'},
    ],
    'Thu': [
      {'name': 'Alice', 'shift': 'leave'},
      {'name': 'John', 'shift': 'day'},
      {'name': 'Bob', 'shift': 'night'},
    ],
    'Fri': [
      {'name': 'John', 'shift': 'off'},
      {'name': 'Alice', 'shift': 'morning'},
      {'name': 'Bob', 'shift': 'day'},
    ],
  };

  Color getShiftColor(String shift) {
    switch (shift.toLowerCase()) {
      case 'morning':
        return Colors.amber.shade400;
      case 'day':
        return Colors.green.shade400;
      case 'night':
        return Colors.blue.shade400;
      case 'off':
      case 'leave':
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  int getShiftPriority(String shift) {
    switch (shift.toLowerCase()) {
      case 'off':
      case 'leave':
        return 1;
      case 'morning':
        return 2;
      case 'day':
        return 3;
      case 'night':
        return 4;
      default:
        return 99;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dayWidth = screenWidth / weekDays.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Shift View'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: weekDays.map((day) {
                final employees = shiftsByDay[day] ?? [];
                employees.sort((a, b) => getShiftPriority(a['shift']!).compareTo(getShiftPriority(b['shift']!)));

                // Group employees by shift type
                final Map<String, List<String>> grouped = {};
                for (var emp in employees) {
                  grouped.putIfAbsent(emp['shift']!, () => []).add(emp['name']!);
                }

                return Container(
                  width: dayWidth,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: grouped.entries.map((entry) {
                              final color = getShiftColor(entry.key);
                              final names = entry.value;
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: names
                                      .map(
                                        (name) => Text(
                                          name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          _buildLegend(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final legends = {
      'Leave/Off': Colors.red.shade400,
      'Morning': Colors.amber.shade400,
      'Day': Colors.green.shade400,
      'Night': Colors.blue.shade400,
    };

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      children: legends.entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 14, color: e.value),
            const SizedBox(width: 4),
            Text(e.key, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }
}
