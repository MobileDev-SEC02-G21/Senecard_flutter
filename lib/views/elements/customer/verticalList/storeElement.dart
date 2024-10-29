import 'package:flutter/material.dart';
import 'dart:async'; // Para usar Timer

class StoreElement extends StatefulWidget {
  final String storeId;
  final String image;
  final String storeName;
  final double? rating;
  final Map schedule;

  const StoreElement({
    super.key,
    this.image =
        "https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o=",
    required this.storeName,
    required this.rating,
    required this.schedule,
    required this.storeId,
  });

  @override
  State<StatefulWidget> createState() {
    return _StoreElementState();
  }
}

class _StoreElementState extends State<StoreElement> {
  late Timer _timer;
  bool isOpen = true;

  @override
  void initState() {
    super.initState();
    _isStoreOpen();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _isStoreOpen();
      });
    });
  }

  void _isStoreOpen() {
    final now = DateTime.now();
    String currentDay = _getCurrentDay(now.weekday);
    isOpen = _checkStoreStatus(now, currentDay);
  }

  String _getCurrentDay(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  bool _checkStoreStatus(DateTime now, String currentDay) {
    if (!widget.schedule.containsKey(currentDay)) return false;

    final List<dynamic> hours = widget.schedule[currentDay];
    if (hours.length != 2) return false;

    final int openHour = hours[0];
    final int closeHour = hours[1];
    final int currentHour = now.hour;

    return currentHour >= openHour && currentHour < closeHour;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  double get effectiveRating => widget.rating ?? 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.image),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(100),
                color: isOpen ? null : Colors.grey,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.storeName,
                  style: TextStyle(
                    fontSize: 18,
                    color: isOpen ? Colors.black : Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star_border,
                      color: Color.fromARGB(255, 255, 122, 40),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      effectiveRating.toString(),
                      style: TextStyle(
                        color: isOpen ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const Divider(
          thickness: 1.5,
          color: Color.fromARGB(255, 240, 245, 250),
          indent: 2,
          endIndent: 2,
        )
      ],
    );
  }
}
