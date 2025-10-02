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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Study Planner'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D47),
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
                outsideDaysVisible: false,
                weekendTextStyle: const TextStyle(color: Colors.white),
                defaultTextStyle: const TextStyle(color: Colors.white),
                todayDecoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: Color(0xFF1A1B2E),
                  fontWeight: FontWeight.bold,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Color(0xFF1A1B2E),
                  fontWeight: FontWeight.bold,
                ),
                markerDecoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                markerSize: 6,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                formatButtonTextStyle: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 14,
                ),
                formatButtonDecoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFD700)),
                  borderRadius: BorderRadius.circular(8),
                ),
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFFFFD700),
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFFFD700),
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.grey),
                weekendStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D47),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM d, y').format(_selectedDay),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedDayTasks.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1B2E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDayTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks for this day',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }
}
