import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:senecard/utils/app_localizations.dart';
import 'package:senecard/view_models/customer/settings_viewmodel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, child) {
        final l10n = AppLocalizations.of(context);

        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          key: ValueKey('settings_${viewModel.selectedLanguage}'),
          children: [
            if (viewModel.showNotificationsSetting) ...[
              _buildSwitchTile(
                title: l10n.notifications,
                subtitle: l10n.notificationsDescription,
                value: viewModel.notificationsEnabled,
                onChanged: viewModel.setNotificationsEnabled,
                icon: Icons.notifications,
              ),
              const Divider(),
            ],
            _buildLanguageTile(
              title: l10n.language,
              subtitle: l10n.languageDescription,
              selectedLanguage: viewModel.selectedLanguage,
              onChanged: viewModel.setLanguage,
              l10n: l10n,
            ),
            const Divider(),
            _buildSwitchTile(
              title: l10n.theme,
              subtitle: l10n.themeDescription,
              value: viewModel.darkThemeEnabled,
              onChanged: viewModel.setDarkThemeEnabled,
              icon: Icons.dark_mode,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 122, 40),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  // Usar el servicio del SettingsViewModel
                  await viewModel.saveNavigationState();
                  Phoenix.rebirth(context);
                },
                child: const Text('Apply Changes'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color.fromARGB(255, 255, 122, 40),
      ),
    );
  }

  Widget _buildLanguageTile({
    required String title,
    required String subtitle,
    required String selectedLanguage,
    required ValueChanged<String> onChanged,
    required AppLocalizations l10n,
  }) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: selectedLanguage,
        items: [
          DropdownMenuItem(
            value: 'en',
            child: Text(l10n.english),
          ),
          DropdownMenuItem(
            value: 'es',
            child: Text(l10n.spanish),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}
