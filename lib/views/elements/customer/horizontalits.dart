import 'package:flutter/material.dart';

class HorizontalScrollableList extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String) onCategorySelected;
  
  const HorizontalScrollableList({
    super.key, 
    required this.categories,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          // Add "All" category at the beginning
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextButton(
              onPressed: () => onCategorySelected(''),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  selectedCategory == null || selectedCategory!.isEmpty
                      ? const Color.fromARGB(255, 255, 122, 40)
                      : const Color.fromARGB(255, 152, 168, 184),
                ),
              ),
              child: const Text(
                'All',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          ...categories.map(
            (item) => Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextButton(
                onPressed: () => onCategorySelected(item),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    selectedCategory == item
                        ? const Color.fromARGB(255, 255, 122, 40)
                        : const Color.fromARGB(255, 152, 168, 184),
                  ),
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