import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_dialog.dart';
import '../widgets/task_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final StorageService _storageService = StorageService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Task> _allTasks = [];
  List<Task> _selectedDayTasks = [];
  Map<DateTime, List<Task>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _storageService.getTasks();
    setState(() {
      _allTasks = tasks;
      _tasksByDate = _groupTasksByDate(tasks);
      _updateSelectedDayTasks();
    });
  }

  Map<DateTime, List<Task>> _groupTasksByDate(List<Task> tasks) {
    final map = <DateTime, List<Task>>{};
    for (var task in tasks) {
      final date = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      if (map[date] == null) {
        map[date] = [];
      }
      map[date]!.add(task);
    }
    return map;
  }

  void _updateSelectedDayTasks() {
    final normalizedDate = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    _selectedDayTasks = _tasksByDate[normalizedDate] ?? [];
  }

  List<Task> _getTasksForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _tasksByDate[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _updateSelectedDayTasks();
    });
  }

  Future<void> _showAddTaskDialog() async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => TaskDialog(initialDate: _selectedDay),
    );

    if (result != null) {
      await _storageService.addTask(result);
      _loadTasks();
    }
  }

  Future<void> _showEditTaskDialog(Task task) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => TaskDialog(task: task),
    );

    if (result != null) {
      await _storageService.updateTask(result);
      _loadTasks();
    }
  }

  Future<void> _deleteTask(String taskId) async {
    await _storageService.deleteTask(taskId);
    _loadTasks();
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await _storageService.updateTask(task);
    _loadTasks();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Container(
        color: const Color(0xFF0A1128), // Dark background for the whole screen
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TableCalendar<Task>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: _getTasksForDay,
                calendarStyle: CalendarStyle(
                  // White background for calendar
                  outsideDaysVisible: false,
                  // Today marker - light blue circle
                  todayDecoration: const BoxDecoration(
                    color: Color(0xFF64B5F6), // Light blue
                    shape: BoxShape.circle,
                  ),
                  // Selected date - golden yellow circle
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFFFFC107), // Golden yellow
                    shape: BoxShape.circle,
                  ),
                  // Event markers - small colored dots
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFFFFC107),
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                  // Text colors
                  defaultTextStyle: const TextStyle(color: Colors.black),
                  weekendTextStyle: const TextStyle(color: Colors.black),
                  selectedTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  titleTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.black),
                  rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.black),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM d, y').format(_selectedDay),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${_selectedDayTasks.length} ${_selectedDayTasks.length == 1 ? 'task' : 'tasks'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selectedDayTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 60,
                            color: Colors.black.withOpacity(0.6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks for this day',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _selectedDayTasks.length,
                      itemBuilder: (context, index) {
                        final task = _selectedDayTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () => _showEditTaskDialog(task),
                          onDelete: () => _deleteTask(task.id),
                          onToggleComplete: () => _toggleTaskCompletion(task),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
