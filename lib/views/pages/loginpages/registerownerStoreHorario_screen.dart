import 'package:flutter/material.dart';
import 'package:senecard/views/pages/Owner/owner_page.dart';
import 'package:senecard/views/pages/loginpages/registerownerStore_screen.dart';
import 'package:senecard/views/pages/customer/main_page.dart';
import 'package:senecard/views/pages/Owner/business_info.dart';
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
    MaterialPageRoute(builder: (context) => RegisterownerStorePage()),
  );
}

void _navigateToBusinessInfoPage(BuildContext context, String storeId) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => OwnerPage(storeId: storeId)),
  );
}


class _StoreSchedulePageState extends State<StoreSchedulePage> {
  final Map<String, TimeOfDay?> _openingTimes = {
    "Monday": TimeOfDay(hour: 0, minute: 0),
    "Tuesday": TimeOfDay(hour: 0, minute: 0),
    "Wednesday": TimeOfDay(hour: 0, minute: 0),
    "Thursday": TimeOfDay(hour: 0, minute: 0),
    "Friday": TimeOfDay(hour: 0, minute: 0),
    "Saturday": TimeOfDay(hour: 0, minute: 0),
    "Sunday": TimeOfDay(hour: 0, minute: 0),
  };

  late final Map<String, TimeOfDay?> _closingTimes;

  @override
  void initState() {
    super.initState();
    _closingTimes = Map.fromEntries(_openingTimes.entries.map((entry) => MapEntry(entry.key, entry.value)));
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
      ]; // Guarda el horario en formato [apertura, cierre]
    });

    try {
      await FirebaseFirestore.instance.collection('stores').doc(widget.storeId).update({
        'schedule': schedule,
      });
      print('Horario actualizado');

      // Navegar a BusinessInfoPage después de actualizar el horario
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OwnerPage(storeId: widget.storeId)),
      );

    } catch (e) {
      print('Error al actualizar el horario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.orange),
                onPressed: () {
                  _navigateToRegisterownerStorePage(context);
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Store Owner',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            'Enter the schedule of the store',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ..._openingTimes.keys.map((day) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(day.toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  _timeButton(context, day, true),
                  Text('-'),
                  _timeButton(context, day, false),
                ],
              ),
            );
          }).toList(),
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _saveSchedule(); // Guardar el horario
              },
              child: Text('REGISTER'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        timeString,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}