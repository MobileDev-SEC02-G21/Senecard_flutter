import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';
import 'package:senecard/views/pages/customer/ads_detail_page.dart';

class AdvertisementElement extends StatefulWidget {
  final bool available;
  final String id;
  final String image;
  final String? endDate;
  final String startDate;
  final String storeId;
  final String title;
  final Map<dynamic, dynamic> storeSchedule;

  const AdvertisementElement(
      {super.key,
      required this.id,
      required this.image,
      required this.available,
      this.endDate,
      required this.startDate,
      required this.storeId,
      required this.title,
      required this.storeSchedule});

  @override
  State<StatefulWidget> createState() {
    return _AdvertisementElementState();
  }
}

class _AdvertisementElementState extends State<AdvertisementElement> {
  late Timer _timer;
  bool isStoreOpen = true;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkStoreStatus();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _checkStoreStatus();
        });
      }
    });
  }

  void _checkStoreStatus() {
    final now = DateTime.now();
    String currentDay = _getCurrentDay(now.weekday);
    isStoreOpen = _isOpen(now, currentDay);
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

  bool _isOpen(DateTime now, String currentDay) {
    if (!widget.storeSchedule.containsKey(currentDay)) return false;

    final List<dynamic> hours = widget.storeSchedule[currentDay];
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final mainViewModel =
            Provider.of<MainPageViewmodel>(context, listen: false);
        final store = mainViewModel.stores.firstWhere(
          (store) => store.id == widget.storeId,
          orElse: () => throw Exception('Store not found'),
        );
        final advertisement = mainViewModel.advertisements.firstWhere(
          (ad) => ad.id == widget.id,
          orElse: () => throw Exception('Advertisement not found'),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdvertisementDetailPage(
              advertisement: advertisement,
              store: store,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 200,
                  maxHeight: 200,
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error),
                    ),
                  ),
                  imageBuilder: (context, imageProvider) {
                    _isLoading = false;
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fill,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!isStoreOpen)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Text(
                        'Store Closed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Divider(
            thickness: 1.5,
            color: Color.fromARGB(255, 240, 245, 250),
            indent: 2,
            endIndent: 2,
          ),
        ],
      ),
    );
  }
}
