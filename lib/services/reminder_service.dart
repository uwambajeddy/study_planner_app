import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class ReminderService {
  final StorageService _storageService = StorageService();
  Timer? _reminderTimer;

  void startReminderService(BuildContext context) {
    // Check for reminders every 5 seconds for more responsive notifications
    _reminderTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkReminders(context);
    });
    
    // Also check immediately on start
    _checkReminders(context);
  }

  void stopReminderService() {
    _reminderTimer?.cancel();
  }

  final Set<String> _shownReminders = {}; // Track already shown reminders

  Future<void> _checkReminders(BuildContext context) async {
    final tasks = await _storageService.getTasks();
    final now = DateTime.now();

    for (var task in tasks) {
      if (task.hasReminder && task.reminderTime != null && !task.isCompleted) {
        final reminderTime = task.reminderTime!;

        // Check if reminder time has passed and is within the current minute
        if (reminderTime.isBefore(now) || reminderTime.isAtSameMomentAs(now)) {
          final timeDiff = now.difference(reminderTime);
          
          // Show reminder if it's within the last minute and hasn't been shown yet
          if (timeDiff.inMinutes < 1 && !_shownReminders.contains(task.id)) {
            _shownReminders.add(task.id);
            _showReminderPopup(context, task);
          }
        }
      }
    }
    
    // Clean up old shown reminders (older than 5 minutes)
    final oldReminderCutoff = now.subtract(const Duration(minutes: 5));
    _shownReminders.removeWhere((taskId) {
      final task = tasks.firstWhere((t) => t.id == taskId, orElse: () => tasks.first);
      return task.reminderTime != null && task.reminderTime!.isBefore(oldReminderCutoff);
    });
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
                  color: Color(0xFF212121),
                )
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: const Color(0xFF757575)),
              ),
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
