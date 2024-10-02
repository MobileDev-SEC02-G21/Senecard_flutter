import 'package:flutter/material.dart';
import 'package:senecard/views/elements/customer/horizontaltextcustom.dart';
import 'package:senecard/views/elements/customer/searchbar/searchbar.dart';

import '../../elements/customer/searchbar/searchbar.dart';

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
    return const Column(
      children: [
        SizedBox(
          height: 20,
        ),
        SearchBarCustom(),
        SizedBox(
          height: 20,
        ),
        HorizontalTextCustom(
          title: "Stores",
          buttonText: "See All",
          icon: Icons.arrow_forward_ios_rounded,
        ),
        
        SizedBox(
          height: 10,
        ),
        HorizontalTextCustom(
          title: "Discounts",
          buttonText: "See All",
          icon: Icons.arrow_forward_ios_rounded,
        )
      ],
    );
  }
}
