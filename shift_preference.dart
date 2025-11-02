import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftPreferencePage extends StatefulWidget {
  const ShiftPreferencePage({Key? key}) : super(key: key);

  @override
  State<ShiftPreferencePage> createState() => _ShiftPreferencePageState();
}

class _ShiftPreferencePageState extends State<ShiftPreferencePage> {
  // --- Data Structures ---
  final List<String> allShifts = ['Morning', 'Day', 'Night'];
  final List<String> weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  List<String> generalPrefs = [];
  Map<String, List<String>> dayWisePrefs = {};
  Map<String, List<String>> dateWisePrefs = {};

  // --- Helpers ---
  void _toggleShift(List<String> selected, String shift) {
    setState(() {
      if (selected.contains(shift)) {
        selected.remove(shift);
      } else {
        selected.add(shift);
      }
    });
  }

  Future<void> _addDatePreference() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, 1),
      lastDate: DateTime(now.year, now.month + 1, 0),
    );

    if (picked != null) {
      String key = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        dateWisePrefs.putIfAbsent(key, () => []);
      });
    }
  }

  void _savePreferences() {
    // Example: print to console or send to backend
    debugPrint('General: $generalPrefs');
    debugPrint('Day-wise: $dayWisePrefs');
    debugPrint('Date-wise: $dateWisePrefs');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Preferences Saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shift Preferences')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1️⃣ General Preferences
            const Text("General Shift Preference", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...allShifts.map((shift) => CheckboxListTile(
              title: Text(shift),
              value: generalPrefs.contains(shift),
              onChanged: (_) => _toggleShift(generalPrefs, shift),
            )),

            const Divider(height: 32),

            // 2️⃣ Day-wise Preferences
            const Text("Day-wise Shift Preference", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...weekDays.map((day) => ExpansionTile(
              title: Text(day),
              children: allShifts.map((shift) => CheckboxListTile(
                title: Text(shift),
                value: dayWisePrefs[day]?.contains(shift) ?? false,
                onChanged: (_) {
                  setState(() {
                    dayWisePrefs.putIfAbsent(day, () => []);
                    _toggleShift(dayWisePrefs[day]!, shift);
                  });
                },
              )).toList(),
            )),

            const Divider(height: 32),

            // 3️⃣ Date-wise Preferences
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Date-wise Shift Preference", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _addDatePreference,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Date"),
                )
              ],
            ),
            const SizedBox(height: 8),
            ...dateWisePrefs.entries.map((entry) => Card(
              child: ExpansionTile(
                title: Text(entry.key),
                children: allShifts.map((shift) => CheckboxListTile(
                  title: Text(shift),
                  value: entry.value.contains(shift),
                  onChanged: (_) {
                    setState(() {
                      _toggleShift(entry.value, shift);
                    });
                  },
                )).toList(),
              ),
            )),

            const SizedBox(height: 20),

            // Save button
            Center(
              child: ElevatedButton.icon(
                onPressed: _savePreferences,
                icon: const Icon(Icons.save),
                label: const Text("Save Preferences"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
