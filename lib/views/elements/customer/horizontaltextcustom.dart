import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/services/connectivity_service.dart';
import 'package:senecard/view_models/customer/offers_page_viewmodel.dart';

class HorizontalTextCustom extends StatelessWidget {
  final String title;
  final String buttonText;
  final IconData icon;

  const HorizontalTextCustom({
    super.key,
    required this.title,
    required this.buttonText,
    required this.icon,
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

  void _handleButtonPress(BuildContext context, OffersPageViewModel viewModel) async {
    // Verificar conexión a internet antes de intentar refrescar
    if (!viewModel.isOnline) {
      _showNoInternetToast(context);
      return;
    }

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Intentar refrescar los datos
      await viewModel.refreshData();
      // Cerrar el indicador de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Si hay un error, cerrar el indicador de carga y mostrar el mensaje de error
      if (context.mounted) {
        Navigator.of(context).pop();
        _showNoInternetToast(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OffersPageViewModel>(
      builder: (context, viewModel, child) {
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
                    onPressed: viewModel.isLoading 
                      ? null 
                      : () => _handleButtonPress(context, viewModel),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 16,
                        color: viewModel.isLoading 
                          ? Colors.grey 
                          : const Color.fromARGB(255, 0, 0, 0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: viewModel.isLoading 
                      ? null 
                      : () => _handleButtonPress(context, viewModel),
                    icon: Icon(
                      icon,
                      size: 24,
                      color: viewModel.isLoading 
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
