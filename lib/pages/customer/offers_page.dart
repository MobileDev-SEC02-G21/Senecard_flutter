import 'package:flutter/material.dart';
import 'package:senecard/elements/customer/horizontalits.dart';
import 'package:senecard/elements/customer/horizontaltextcustom.dart';
import 'package:senecard/elements/customer/searchbar/searchbar.dart';

class OffersPage extends StatefulWidget {
  final List<String> categories;
  const OffersPage({super.key, required this.categories});
  @override
  State<StatefulWidget> createState() {
    return _OffersPageState();
  }
}

class _OffersPageState extends State<OffersPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Welcome back!",
          style: TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 20,
        ),
        const SearchBarCustom(),
        const SizedBox(
          height: 20,
        ),
        const HorizontalTextCustom(
          title: "Categories",
          buttonText: "See All",
          icon: Icons.arrow_forward_ios_rounded,
        ),
        HorizontalScrollableList(categories: widget.categories),
        const SizedBox(
          height: 10,
        ),
        const HorizontalTextCustom(
          title: "Best Offers",
          buttonText: "See All",
          icon: Icons.arrow_forward_ios_rounded,
        )
      ],
    );
  }
}
