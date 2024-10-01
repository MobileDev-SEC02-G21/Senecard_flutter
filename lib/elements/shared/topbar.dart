import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final Icon icon;
  final List<Widget>? trailing;
  final double height;
  final Color backgroundColor;
  final String title;
  final String message;

  const TopBar({
    super.key,
    this.trailing,
    this.height = 60.0,
    this.backgroundColor = Colors.white,
    required this.message,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: Padding(
        padding: const EdgeInsets.only(left: 10,right: 10),
        child: AppBar(
          title: Text(title),
          centerTitle: true,
          titleTextStyle: const TextStyle(fontSize: 16, color: Colors.black),
          leading: IconButton(
            onPressed: Scaffold.of(context).openDrawer,
            icon: icon,
            color: Colors.white,
            style: const ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(Color.fromARGB(255, 255, 122, 40))),
          ),
          elevation: 0,
          backgroundColor: backgroundColor,
          bottom: PreferredSize(preferredSize: preferredSize, child: Text(message, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)),
          actions: trailing,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
