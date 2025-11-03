import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyShiftView extends StatefulWidget {
  const DailyShiftView({super.key});

  @override
  State<DailyShiftView> createState() => _DailyShiftViewState();
}

class _DailyShiftViewState extends State<DailyShiftView> {
  DateTime selectedDate = DateTime.now();

  // Example data by date
  final Map<String, List<Map<String, String>>> shiftsByDate = {
    '2025-11-03': [
      {'name': 'Alice', 'shift': 'leave'},
      {'name': 'John', 'shift': 'morning'},
      {'name': 'Bob', 'shift': 'morning'},
      {'name': 'Eve', 'shift': 'night'},
    ],
    '2025-11-04': [
      {'name': 'Bob', 'shift': 'day'},
      {'name': 'Alice', 'shift': 'morning'},
      {'name': 'John', 'shift': 'night'},
    ],
    '2025-11-05': [
      {'name': 'Alice', 'shift': 'off'},
      {'name': 'John', 'shift': 'day'},
      {'name': 'Eve', 'shift': 'morning'},
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
        return Colors.grey.shade300;
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

  void _changeDate(int delta) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: delta));
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEE, d MMM yyyy').format(selectedDate);
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

    final employees = shiftsByDate[dateKey] ?? [];
    employees.sort((a, b) => getShiftPriority(a['shift']!).compareTo(getShiftPriority(b['shift']!)));

    // Group employees by shift type
    final Map<String, List<String>> grouped = {};
    for (var emp in employees) {
      grouped.putIfAbsent(emp['shift']!, () => []).add(emp['name']!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Shift View'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top navigation bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 28),
                  onPressed: () => _changeDate(-1),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 28),
                  onPressed: () => _changeDate(1),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Shifts for the selected day
          Expanded(
            child: grouped.isEmpty
                ? const Center(
                    child: Text(
                      "No shift data for this date",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: grouped.entries.map((entry) {
                      final color = getShiftColor(entry.key);
                      final names = entry.value;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Shift header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.9),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: Text(
                                entry.key.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Employee names
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: names
                                    .map(
                                      (name) => Text(
                                        "• $name",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                    .toList(),
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
