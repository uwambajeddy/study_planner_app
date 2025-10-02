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
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D47),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Switch(
                  value: true,
                  onChanged: (value) {
                    // Handle notification toggle
                  },
                  activeColor: const Color(0xFFFFD700),
                  activeTrackColor: const Color(0xFFFFD700).withOpacity(0.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Storage Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D47),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Local',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // App Information Section
          const Text(
            'App Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D47),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Color(0xFFFFD700)),
                  title: const Text(
                    'App Version',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    '1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFF3A3D57)),
                ListTile(
                  leading: const Icon(Icons.school, color: Color(0xFFFFD700)),
                  title: const Text(
                    'About',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Study Planner - Task Management App',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Study Planner',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.school,
                        size: 48,
                        color: Color(0xFFFFD700),
                      ),
                      children: [
                        const Text(
                          'A Flutter app for managing your study tasks with reminders and calendar integration.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Data Management Section
          const Text(
            'Data Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D47),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storage, color: Color(0xFFFFD700)),
                  title: const Text(
                    'Storage',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Tasks are stored locally on your device',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFF3A3D57)),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Clear All Tasks',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Delete all stored tasks',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: _clearAllTasks,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
