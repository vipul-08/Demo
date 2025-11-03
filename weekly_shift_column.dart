import 'package:flutter/material.dart';

class WeeklyShiftColumnView extends StatelessWidget {
  WeeklyShiftColumnView({super.key});

  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Example structure for each day: a list of employees with shift type
  final Map<String, List<Map<String, String>>> shiftsByDay = {
    'Mon': [
      {'name': 'Alice', 'shift': 'leave'},
      {'name': 'Bob', 'shift': 'morning'},
      {'name': 'John', 'shift': 'day'},
      {'name': 'Eve', 'shift': 'night'},
    ],
    'Tue': [
      {'name': 'Bob', 'shift': 'morning'},
      {'name': 'John', 'shift': 'night'},
      {'name': 'Alice', 'shift': 'day'},
    ],
    'Wed': [
      {'name': 'Alice', 'shift': 'off'},
      {'name': 'John', 'shift': 'day'},
      {'name': 'Bob', 'shift': 'morning'},
    ],
    'Thu': [
      {'name': 'Alice', 'shift': 'day'},
      {'name': 'Bob', 'shift': 'night'},
      {'name': 'John', 'shift': 'morning'},
    ],
    'Fri': [
      {'name': 'John', 'shift': 'off'},
      {'name': 'Alice', 'shift': 'morning'},
      {'name': 'Bob', 'shift': 'day'},
    ],
    'Sat': [
      {'name': 'John', 'shift': 'night'},
      {'name': 'Alice', 'shift': 'day'},
      {'name': 'Bob', 'shift': 'off'},
    ],
    'Sun': [
      {'name': 'Alice', 'shift': 'off'},
      {'name': 'Bob', 'shift': 'morning'},
      {'name': 'John', 'shift': 'day'},
    ],
  };

  /// Color mapping for each shift
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
        return Colors.grey.shade300;
    }
  }

  /// Sort order: leave/off → morning → day → night
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
    return Scaffold(
      appBar: AppBar(title: const Text("Weekly Shift Overview"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: weekDays.map((day) {
                    final employees = List<Map<String, String>>.from(shiftsByDay[day] ?? []);
                    employees.sort((a, b) => getShiftPriority(a['shift']!).compareTo(getShiftPriority(b['shift']!)));
                    return _buildDayColumn(day, employees);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayColumn(String day, List<Map<String, String>> employees) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          // Day header
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                day,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Employee tiles
          ...employees.map((emp) {
            final shift = emp['shift'] ?? '';
            final color = getShiftColor(shift);
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                emp['name'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
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
