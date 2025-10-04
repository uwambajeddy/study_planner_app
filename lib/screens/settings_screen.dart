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
        title: const Text('Clear All Tasks'),
        content: const Text(
          'Are you sure you want to delete all tasks? This action cannot be undone.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
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
            content: Text('All tasks cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'App Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: Color(0xFFFFC107),
                  ),
                  title: const Text(
                    'App Version',
                    style: TextStyle(color: Color(0xFF212121)),
                  ),
                  subtitle: const Text(
                    '1.0.0',
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Data Management',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storage, color: Color(0xFFFFC107)),
                  title: const Text(
                    'Storage',
                    style: TextStyle(color: Color(0xFF212121)),
                  ),
                  subtitle: const Text(
                    'Tasks are stored locally on your device',
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Clear All Tasks',
                    style: TextStyle(color: Color(0xFF212121)),
                  ),
                  subtitle: const Text(
                    'Delete all stored tasks',
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  onTap: _clearAllTasks,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Features',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text(
                    'Task Management',
                    style: TextStyle(color: Color(0xFF212121)),
                  ),
                  subtitle: const Text(
                    'Add, edit, and delete tasks',
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Colors.orange,
                  ),
                  title: const Text(
                    'Calendar View',
                    style: TextStyle(color: Color(0xFF212121)),
                  ),
                  subtitle: const Text(
                    'View tasks by date',
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.notifications_active,
                    color: Color(0xFFFFC107),
                  ),
                  title: const Text(
                    'Reminders',
                    style: TextStyle(color: Color(0xFF212121)),
                  ),
                  subtitle: const Text(
                    'Get notified about upcoming tasks',
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.today, color: Colors.purple),
                  title: const Text(
                    'Today\'s Tasks',
                    style: TextStyle(color: Color(0xFF212121)),
                  ),
                  subtitle: const Text(
                    'Quick view of tasks due today',
                    style: TextStyle(color: Color(0xFF757575)),
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
