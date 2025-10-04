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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Calendar container with white background
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                // Today marker - light blue circle
                todayDecoration: BoxDecoration(
                  color: Colors.lightBlue.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.lightBlue, width: 2),
                ),
                todayTextStyle: const TextStyle(
                  color: Color(0xFF212121),
                  fontWeight: FontWeight.bold,
                ),
                // Selected date - golden yellow circle
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFFFFC107),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                // Default text colors
                defaultTextStyle: const TextStyle(color: Color(0xFF212121)),
                weekendTextStyle: TextStyle(color: Colors.red[700]),
                outsideTextStyle: TextStyle(color: Colors.grey[400]),
                // Event markers - small colored dots
                markerDecoration: const BoxDecoration(
                  color: Color(0xFFFFC107),
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                titleTextStyle: TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                formatButtonTextStyle: TextStyle(color: Color(0xFF212121)),
                leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF212121)),
                rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF212121)),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w600),
                weekendStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM d, y').format(_selectedDay),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${_selectedDayTasks.length} ${_selectedDayTasks.length == 1 ? 'task' : 'tasks'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
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
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks for this day',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.6),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
