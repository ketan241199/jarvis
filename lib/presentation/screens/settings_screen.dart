import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Settings screen for app configuration.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Schedule section
          _buildSectionHeader(theme, 'Schedule'),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Work Schedule'),
            subtitle: const Text('Configure your work hours'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/schedule'),
          ),
          const Divider(),

          // Notifications section
          _buildSectionHeader(theme, 'Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Task Reminders'),
            subtitle: const Text('Get notified about upcoming tasks'),
            value: true,
            onChanged: (value) {
              // TODO: Implement notification toggle
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.warning_amber),
            title: const Text('Overdue Alerts'),
            subtitle: const Text('Get notified about overdue tasks'),
            value: true,
            onChanged: (value) {
              // TODO: Implement overdue alert toggle
            },
          ),
          const Divider(),

          // About section
          _buildSectionHeader(theme, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Jarvis'),
            subtitle: const Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
