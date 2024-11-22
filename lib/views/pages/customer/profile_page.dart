import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senecard/services/profile_storage_service.dart';
import 'package:senecard/view_models/customer/profile_viewmodel.dart';
import 'package:senecard/view_models/customer/main_page_viewmodel.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainPageViewmodel>(
      builder: (context, mainViewModel, child) {
        return FutureBuilder<ProfileStorageService>(
          future: ProfileStorageService.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Error initializing profile service',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final userId = mainViewModel.userId; // Obtener userId aquí
            if (userId.isEmpty) {
              print('Warning: Empty userId in ProfilePage');
              return const Center(
                child: Text('No user session found'),
              );
            }

            return ChangeNotifierProvider(
              create: (_) => ProfileViewModel(
                userId: userId, // Usar el userId obtenido
                storageService: snapshot.data!,
              ),
              child: const ProfileContent(),
            );
          },
        );
      },
    );
  }
}

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showNoInternetSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No internet connection available'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.orange.shade100,
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline mode - Showing cached profile data',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!viewModel.isOnline && !viewModel.isEditing) {
          return Column(
            children: [
              _buildOfflineBanner(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'This is you (Offline)',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoItem(
                          'NAME', viewModel.name, Icons.person_outline),
                      _buildInfoItem(
                          'EMAIL', viewModel.email, Icons.email_outlined),
                      _buildInfoItem('PHONE NUMBER', viewModel.phone,
                          Icons.phone_outlined),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: null, // Deshabilitado en modo offline
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('EDIT (Disabled in offline mode)'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // Si estamos editando y perdemos conexión, mostrar el modo actual
        if (!viewModel.isOnline && viewModel.isEditing) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No internet connection',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: viewModel.retryLoading,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 122, 40),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!viewModel.isEditing) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'This is you',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoItem('NAME', viewModel.name, Icons.person_outline),
                _buildInfoItem('EMAIL', viewModel.email, Icons.email_outlined),
                _buildInfoItem(
                    'PHONE NUMBER', viewModel.phone, Icons.phone_outlined),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: viewModel.isOnline
                        ? () {
                            viewModel.startEditing();
                            _nameController.text = viewModel.name;
                            _emailController.text = viewModel.email;
                            _phoneController.text = viewModel.phone;
                          }
                        : () => _showNoInternetSnackBar(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 122, 40),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('EDIT'),
                  ),
                ),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Enter the information',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'NAME',
                  _nameController,
                  errorText: viewModel.nameError,
                  onChanged: viewModel.validateName,
                ),
                _buildTextField(
                  'EMAIL',
                  _emailController,
                  errorText: viewModel.emailError,
                  onChanged: viewModel.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildTextField(
                  'PHONE NUMBER',
                  _phoneController,
                  errorText: viewModel.phoneError,
                  onChanged: viewModel.validatePhone,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          viewModel.cancelEditing();
                          _nameController.clear();
                          _emailController.clear();
                          _phoneController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('CANCEL'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: viewModel.isFormValid
                            ? () async {
                                final success = await viewModel.updateProfile();
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Profile updated successfully')),
                                  );
                                  _nameController.clear();
                                  _emailController.clear();
                                  _phoneController.clear();
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 255, 122, 40),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: const Text('SAVE'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 10),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? errorText,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: (value) {
              if (label == 'NAME' && value.contains(RegExp(r'\s{2,}'))) {
                final cursorPos = controller.selection;
                final cleanedValue = value.replaceAll(RegExp(r'\s{2,}'), ' ');

                if (cleanedValue != value) {
                  controller.text = cleanedValue;
                  final newCursorPos = cursorPos.baseOffset -
                      (value.length - cleanedValue.length);
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(
                        offset: newCursorPos.clamp(0, cleanedValue.length)),
                  );
                }
              }

              if (onChanged != null) {
                onChanged(controller.text);
              }
            },
            decoration: InputDecoration(
              fillColor: const Color(0xFFF5F8FF),
              filled: true,
              border: InputBorder.none,
              errorText: errorText,
              errorStyle: TextStyle(
                color: errorText == null && controller.text.isNotEmpty
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
          if (errorText == null && controller.text.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Looks good!',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
