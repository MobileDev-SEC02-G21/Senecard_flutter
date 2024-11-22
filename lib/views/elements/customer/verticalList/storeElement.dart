import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'dart:async';

import 'package:senecard/views/pages/customer/store_detail_page.dart'; // Para usar Timer

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

  double get effectiveRating => double.parse((widget.rating ?? 0.0).toStringAsFixed(1));

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final mainViewmodel =
            Provider.of<MainPageViewmodel>(context, listen: false);
        final store = mainViewmodel.stores.firstWhere(
          (store) => store.id == widget.storeId,
          orElse: () => throw Exception('Store not found.'),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreDetailPage(store: store),
          ),
        );
      },
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: isOpen ? null : Colors.grey,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    imageUrl: widget.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.store, color: Colors.grey),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
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
                        effectiveRating.toStringAsFixed(1),
                        style: TextStyle(
                          color: isOpen ? Colors.black : Colors.grey,
                        ),
                      ),
                      if (!isOpen) ...[
                        const SizedBox(width: 10),
                        const Text(
                          'Closed',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
      ),
    );
  }
}
