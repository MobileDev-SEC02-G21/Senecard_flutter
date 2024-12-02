import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:senecard/view_models/customer/main_page_viewmodel.dart';

class StoreList extends StatefulWidget {
  final List<Widget> displayItems;
  final bool shorter;
  final bool isAdvertisement;

  const StoreList(
      {super.key, 
      required this.displayItems, 
      this.shorter = false,
      this.isAdvertisement = false,
      });

  @override
  State<StatefulWidget> createState() => _StoreListState();
}

class _StoreListState extends State<StoreList> {
  late List<Widget> displayItems;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    print('StoreList initState called. Is Advertisement: ${widget.isAdvertisement}');
    _updateDisplayItems();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          print('StoreList periodic setState called');
          _updateDisplayItems();
        });
      }
    });
  }

  @override
  void didUpdateWidget(StoreList oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('StoreList didUpdateWidget called');
    if (oldWidget.displayItems != widget.displayItems) {
      _updateDisplayItems();
    }
  }

  void _updateDisplayItems() {
    int listLength = widget.shorter && widget.displayItems.length > 3
        ? 3
        : widget.displayItems.length;
    displayItems = widget.displayItems.take(listLength).toList();
    print('Updated displayItems. Length: ${displayItems.length}');
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainViewModel = Provider.of<MainPageViewmodel>(context, listen: true);
    print('StoreList build called. DisplayItems length: ${displayItems.length}');
    
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          ...displayItems.map((widget) {
            print('Rendering widget in StoreList: ${widget.runtimeType}');
            return widget;
          }),
        ],
      ),
    );
  }
}
