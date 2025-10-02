import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class ReminderService {
  final StorageService _storageService = StorageService();
  Timer? _reminderTimer;

  void startReminderService(BuildContext context) {
    // Check for reminders every minute
    _reminderTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkReminders(context);
    });
  }

  void stopReminderService() {
    _reminderTimer?.cancel();
  }

  Future<void> _checkReminders(BuildContext context) async {
    final tasks = await _storageService.getTasks();
    final now = DateTime.now();

    for (var task in tasks) {
      if (task.hasReminder && 
          task.reminderTime != null && 
          !task.isCompleted) {
        final reminderTime = task.reminderTime!;
        
        // Check if reminder time is within the current minute
        if (reminderTime.year == now.year &&
            reminderTime.month == now.month &&
            reminderTime.day == now.day &&
            reminderTime.hour == now.hour &&
            reminderTime.minute == now.minute) {
          _showReminderPopup(context, task);
        }
      }
    }
  }

  void _showReminderPopup(BuildContext context, Task task) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.orange),
              SizedBox(width: 8),
              Text('Reminder'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(task.description),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss'),
            ),
            ElevatedButton(
              onPressed: () async {
                task.isCompleted = true;
                await _storageService.updateTask(task);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Mark as Done'),
            ),
          ],
        );
      },
    );
  }
}
