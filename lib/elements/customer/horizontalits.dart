import 'package:flutter/material.dart';

class HorizontalScrollableList extends StatelessWidget {
  final List<String> categories;
  const HorizontalScrollableList({super.key, required this.categories});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          ...categories.map(
            (item) => Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 152, 168, 184)),
                ),
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
