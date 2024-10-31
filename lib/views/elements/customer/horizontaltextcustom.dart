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

  void _showNoInternetToast(BuildContext context) {
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Text(
                'No internet connection available',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    Future.delayed(const Duration(seconds: 3), () {
      overlay.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainPageViewmodel>(
      builder: (context, viewModel, child) {
        void handlePress() {
          if (!viewModel.isOnline) {
            _showNoInternetToast(context);
            return;
          }

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
                  TextButton(
                    onPressed: (isLoading || viewModel.isLoading) ? null : handlePress,
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 16,
                        color: (isLoading || viewModel.isLoading)
                            ? Colors.grey
                            : const Color.fromARGB(255, 0, 0, 0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: (isLoading || viewModel.isLoading) ? null : handlePress,
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