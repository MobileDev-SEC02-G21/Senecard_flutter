import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';

class HorizontalTextCustom extends StatelessWidget {
  final String title;
  final String buttonText;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const HorizontalTextCustom({
    super.key,
    required this.title,
    required this.buttonText,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MainPageViewmodel>(
      builder: (context, viewModel, child) {
        void handlePress() {
          if (onPressed != null) {
            onPressed!();
          }
        }

        return Padding(
          padding: const EdgeInsets.only(left: 25, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed:
                        (isLoading || viewModel.isLoading) ? null : handlePress,
                    label: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 16,
                        color: (isLoading || viewModel.isLoading)
                            ? Colors.grey
                            : const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    icon: Icon(
                      icon,
                      size: 24,
                      color: (isLoading || viewModel.isLoading)
                          ? Colors.grey
                          : const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
