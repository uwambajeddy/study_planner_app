import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final DateTime? initialDate;

  const TaskDialog({super.key, this.task, this.initialDate});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  bool _hasReminder = false;
  late DateTime _reminderDateTime;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    
    if (task != null) {
      _dueDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      _dueTime = TimeOfDay(
        hour: task.dueDate.hour,
        minute: task.dueDate.minute,
      );
      _hasReminder = task.hasReminder;
      _reminderDateTime = task.reminderTime ?? task.dueDate;
    } else {
      final initialDate = widget.initialDate ?? DateTime.now();
      _dueDate = DateTime(
        initialDate.year,
        initialDate.month,
        initialDate.day,
      );
      _dueTime = TimeOfDay.now();
      _reminderDateTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );

    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  Future<void> _selectReminderDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _reminderDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: dueDateTime,
      hasReminder: _hasReminder,
      reminderTime: _hasReminder ? _reminderDateTime : null,
      isCompleted: widget.task?.isCompleted ?? false,
    );

    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.task == null ? 'Add Task' : 'Edit Task',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(dateFormat.format(_dueDate)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(timeFormat.format(DateTime(
                        2000,
                        1,
                        1,
                        _dueTime.hour,
                        _dueTime.minute,
                      ))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Set Reminder', style: TextStyle(color: Colors.black)),
                subtitle: _hasReminder
                    ? Text(
                        'Reminder: ${dateFormat.format(_reminderDateTime)} at ${timeFormat.format(_reminderDateTime)}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      )
                    : null,
                value: _hasReminder,
                onChanged: (value) {
                  setState(() {
                    _hasReminder = value;
                  });
                },
                secondary: const Icon(Icons.notifications, color: Color(0xFFFFC107)),
              ),
              if (_hasReminder) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _selectReminderDateTime,
                  icon: const Icon(Icons.alarm),
                  label: const Text('Set Reminder Time'),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveTask,
                    child: Text(widget.task == null ? 'Add' : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
