import 'package:flutter/material.dart';
import 'dart:async'; // Para poder usar Timer

class StoreList extends StatefulWidget {
  final List<Widget> displayItems;
  final bool shorter;
  const StoreList(
      {super.key, required this.displayItems, this.shorter = false});

  @override
  State<StatefulWidget> createState() {
    return _StoreListState();
  }
}

class _StoreListState extends State<StoreList> {
  late List<Widget> displayItems;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    var listLenght =
        widget.displayItems.length > 3 ? 3 : widget.displayItems.length;
    displayItems = widget.shorter
        ? widget.displayItems.take(listLenght).toList()
        : widget.displayItems;

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 10),
      child: Column(
        children: displayItems,
      ),
      
    );
  }
}
