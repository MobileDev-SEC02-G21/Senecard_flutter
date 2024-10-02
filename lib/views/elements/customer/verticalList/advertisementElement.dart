import 'package:flutter/material.dart';

class AdvertisementElement extends StatefulWidget {
  final String image;
  const AdvertisementElement({super.key, required this.image});

  @override
  State<StatefulWidget> createState() {
    return _AdvertisementElementState();
  }
}

class _AdvertisementElementState extends State<AdvertisementElement> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 360,
          height: 230,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.image),
              fit: BoxFit.fill
            ),
          ),
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
