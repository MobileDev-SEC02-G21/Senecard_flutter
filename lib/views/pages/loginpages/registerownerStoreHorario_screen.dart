import 'package:flutter/material.dart';
import 'package:senecard/views/pages/Owner/owner_page.dart';
import 'package:senecard/views/pages/loginpages/registerownerStore_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreSchedulePage extends StatefulWidget {
  final String storeId; // Recibe el ID de la tienda

  const StoreSchedulePage({super.key, required this.storeId});

  @override
  State<StoreSchedulePage> createState() => _StoreSchedulePageState();
}

void _navigateToRegisterownerStorePage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const RegisterownerStorePage()),
  );
}

class _StoreSchedulePageState extends State<StoreSchedulePage> {
  final Map<String, TimeOfDay?> _openingTimes = {
    "Monday": const TimeOfDay(hour: 0, minute: 0),
    "Tuesday": const TimeOfDay(hour: 0, minute: 0),
    "Wednesday": const TimeOfDay(hour: 0, minute: 0),
    "Thursday": const TimeOfDay(hour: 0, minute: 0),
    "Friday": const TimeOfDay(hour: 0, minute: 0),
    "Saturday": const TimeOfDay(hour: 0, minute: 0),
    "Sunday": const TimeOfDay(hour: 0, minute: 0),
  };

  late final Map<String, TimeOfDay?> _closingTimes;

  @override
  void initState() {
    super.initState();
    _closingTimes = Map.fromEntries(_openingTimes.entries.map((entry) => MapEntry(entry.key, entry.value)));
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.orange),
                const SizedBox(height: 20),
                const Text(
                  "Loading",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please wait one moment while processing the information",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showErrorConectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                const Text(
                  "Error",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 10),
                const Text(
                  "No Se pudo completar la acción, porque no existe conexión a la base de datos,\n conectesé a la red e intenté de nuevo.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el popup de error
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Aceptar", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context, String day, bool isOpening) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? _openingTimes[day]! : _closingTimes[day]!,
    );

    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTimes[day] = picked;
        } else {
          _closingTimes[day] = picked;
        }
      });
    }
  }

  Future<void> _saveSchedule() async {
    Map<String, List<int>> schedule = {};

    _openingTimes.forEach((day, openingTime) {
      final closingTime = _closingTimes[day];
      schedule[day.toLowerCase()] = [
        openingTime!.hour,
        closingTime!.hour,
      ];
    });
    showLoadingDialog(context);

    try {
      await FirebaseFirestore.instance.collection('stores').doc(widget.storeId).update({
        'schedule': schedule,
      });
      print('Horario actualizado');

      // Navigate to OwnerPage with the storeId passed to this widget
      Navigator.pop(context); // Close the loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OwnerPage(storeId: widget.storeId)),
      );
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog
      showErrorConectionDialog(context);
      print('Error al actualizar el horario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.orange),
                onPressed: () {
                  _navigateToRegisterownerStorePage(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Store Owner',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter the schedule of the store',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ..._openingTimes.keys.map((day) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(day.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  _timeButton(context, day, true),
                  const Text('-'),
                  _timeButton(context, day, false),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('REGISTER'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeButton(BuildContext context, String day, bool isOpening) {
    final time = isOpening ? _openingTimes[day] : _closingTimes[day];
    final timeString = time!.format(context);

    return ElevatedButton(
      onPressed: () => _selectTime(context, day, isOpening),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        timeString,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}