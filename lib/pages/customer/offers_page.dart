import 'package:flutter/material.dart';
import 'package:senecard/elements/customer/horizontaltextcustom.dart';
import 'package:senecard/elements/customer/verticalList/advertisementElement.dart';
import 'package:senecard/elements/customer/verticalList/storeElement.dart';
import 'package:senecard/elements/customer/verticalList/verticallist.dart';

class OffersPage extends StatefulWidget {
  final List<StoreElement> stores;
  final List<AdvertisementElement> advertisementes;
  const OffersPage(
      {super.key, required this.stores, required this.advertisementes});
  @override
  State<StatefulWidget> createState() {
    return _OffersPageState();
  }
}

class _OffersPageState extends State<OffersPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
          children: [
            const HorizontalTextCustom(
              title: "Stores",
              buttonText: "See All",
              icon: Icons.arrow_forward_ios_rounded,
            ),
            StoreList(
              displayItems: widget.stores,
              shorter: true,
            ),
            const SizedBox(
              height: 10,
            ),
            const HorizontalTextCustom(
              title: "Advertisements",
              buttonText: "See All",
              icon: Icons.arrow_forward_ios_rounded,
            ),
            StoreList(
              displayItems: widget.advertisementes,
              shorter: true,
            ),
            const SizedBox(
              height: 20,
            ),
          ],
      ),
    );
  }
}
