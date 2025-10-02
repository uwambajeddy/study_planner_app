import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();

  Future<void> _clearAllTasks() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Tasks', style: TextStyle(color: Colors.black)),
        content: const Text(
          'Are you sure you want to delete all tasks? This action cannot be undone.',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.saveTasks([]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All tasks cleared', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'App Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0x99FFFFFF),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Color(0xFFFFC107)),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.school, color: Color(0xFFFFC107)),
                  title: const Text('About'),
                  subtitle: const Text('Study Planner - Task Management App'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Study Planner',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.school,
                        size: 48,
                        color: Color(0xFFFFC107),
                      ),
                      applicationLegalese: '© 2024 Study Planner',
                      children: [
                        const Text(
                          'A Flutter app for managing your study tasks with reminders and calendar integration.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Data Management',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0x99FFFFFF),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storage, color: Color(0xFFFFC107)),
                  title: const Text('Storage'),
                  subtitle: const Text('Tasks are stored locally on your device'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Clear All Tasks'),
                  subtitle: const Text('Delete all stored tasks'),
                  onTap: _clearAllTasks,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Features',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0x99FFFFFF),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Color(0xFFFFC107)),
                  title: const Text('Task Management'),
                  subtitle: const Text('Add, edit, and delete tasks'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Color(0xFFFFC107)),
                  title: const Text('Calendar View'),
                  subtitle: const Text('View tasks by date'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active, color: Color(0xFFFFC107)),
                  title: const Text('Reminders'),
                  subtitle: const Text('Get notified about upcoming tasks'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.today, color: Color(0xFFFFC107)),
                  title: const Text('Today\'s Tasks'),
                  subtitle: const Text('Quick view of tasks due today'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
