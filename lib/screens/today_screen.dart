import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_dialog.dart';
import '../widgets/task_card.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final StorageService _storageService = StorageService();
  List<Task> _todayTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayTasks();
  }

  Future<void> _loadTodayTasks() async {
    setState(() => _isLoading = true);
    final tasks = await _storageService.getTodaysTasks();
    setState(() {
      _todayTasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _showAddTaskDialog() async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => const TaskDialog(),
    );

    if (result != null) {
      await _storageService.addTask(result);
      _loadTodayTasks();
    }
  }

  Future<void> _showEditTaskDialog(Task task) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => TaskDialog(task: task),
    );

    if (result != null) {
      await _storageService.updateTask(result);
      _loadTodayTasks();
    }
  }

  Future<void> _deleteTask(String taskId) async {
    await _storageService.deleteTask(taskId);
    _loadTodayTasks();
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await _storageService.updateTask(task);
    _loadTodayTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task list section
                Expanded(
                  child: _todayTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks for today',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap "New Task" to add a task',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTodayTasks,
                          color: const Color(0xFFFFD700),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _todayTasks.length,
                            itemBuilder: (context, index) {
                              final task = _todayTasks[index];
                              return TaskCard(
                                task: task,
                                onTap: () => _showEditTaskDialog(task),
                                onDelete: () => _deleteTask(task.id),
                                onToggleComplete: () => _toggleTaskCompletion(task),
                              );
                            },
                          ),
                        ),
                ),
                // New Task button at bottom
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _showAddTaskDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF1A1B2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'New Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
