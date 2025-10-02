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
        title: const Text('Today\'s Tasks'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _todayTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks for today',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add a new task',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTodayTasks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
