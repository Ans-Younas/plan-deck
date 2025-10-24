import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plan_deck/data/models/task.dart';
import 'package:plan_deck/data/models/task_status.dart';
import 'package:plan_deck/presentation/dashboard/widgets/up_next_card.dart';
import 'package:plan_deck/presentation/task_creation/task_creation_screen.dart';
import 'package:plan_deck/presentation/task_details/task_details_screen.dart';
import 'package:plan_deck/application/providers/task_providers.dart';
import 'package:plan_deck/application/providers/recommendation_provider.dart';
import 'package:plan_deck/application/providers/theme_provider.dart';

enum TaskFilter { all, unlocked, inProgress, completed, locked }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TaskFilter _selectedFilter = TaskFilter.all;

  String _getFilterDisplayName(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.unlocked:
        return 'Unlocked';
      case TaskFilter.inProgress:
        return 'In Progress';
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.locked:
        return 'Locked';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksNotifier = Provider.of<TasksNotifier>(context);
    final recommendationProvider = Provider.of<RecommendationProvider>(context);

    List<Task> filteredTasks;
    switch (_selectedFilter) {
      case TaskFilter.all:
        filteredTasks = tasksNotifier.tasks;
        break;
      case TaskFilter.unlocked:
        filteredTasks = tasksNotifier.readyTasks;
        break;
      case TaskFilter.inProgress:
        filteredTasks = tasksNotifier.inProgressTasks;
        break;
      case TaskFilter.completed:
        filteredTasks = tasksNotifier.doneTasks;
        break;
      case TaskFilter.locked:
        filteredTasks = tasksNotifier.blockedTasks;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your PlanDeck',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${tasksNotifier.readyTasks.length} tasks unlocked',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () {
                  themeProvider.setThemeMode(
                    themeProvider.themeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  );
                },
              );
            },
          ),
        ],
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Up Next',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (recommendationProvider.upNextTask != null)
            Consumer<TasksNotifier>(
              builder: (context, tasksNotifier, child) {
                final task = recommendationProvider.upNextTask!;
                final successorCount = tasksNotifier
                    .getSuccessorTasks(task.id)
                    .length;
                return UpNextCard(
                  title: task.title,
                  description: successorCount > 0
                      ? 'This unlocks $successorCount other task${successorCount == 1 ? '' : 's'}.'
                      : task.description.isNotEmpty
                      ? task.description
                      : 'No description available.',
                  onStartTask: () {
                    // Start the task by setting status to inProgress
                    final updatedTask = Task(
                      id: task.id,
                      title: task.title,
                      description: task.description,
                      dueDate: task.dueDate,
                      status: TaskStatus.inProgress,
                      predecessorIds: task.predecessorIds,
                    );
                    tasksNotifier.updateTask(updatedTask);
                    
                    // Navigate to task details
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsScreen(task: updatedTask),
                      ),
                    );
                  },
                );
              },
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No tasks ready to start.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TaskFilter.values.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_getFilterDisplayName(filter)),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          if (_selectedFilter == TaskFilter.all)
            ..._buildAllTaskSections(tasksNotifier)
          else
            ..._buildFilteredTasks(filteredTasks),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTaskSuggestions(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  List<Widget> _buildAllTaskSections(TasksNotifier tasksNotifier) {
    return [
      if (tasksNotifier.readyTasks.isNotEmpty)
        ..._buildTaskSection('Unlocked & Ready', tasksNotifier.readyTasks),
      if (tasksNotifier.inProgressTasks.isNotEmpty)
        ..._buildTaskSection('In Progress', tasksNotifier.inProgressTasks),
      if (tasksNotifier.doneTasks.isNotEmpty)
        ..._buildTaskSection('Completed', tasksNotifier.doneTasks),
      if (tasksNotifier.blockedTasks.isNotEmpty)
        ..._buildTaskSection('Locked', tasksNotifier.blockedTasks),
    ];
  }

  List<Widget> _buildFilteredTasks(List<Task> tasks) {
    return tasks.map((task) => _buildTaskCard(task)).toList();
  }

  List<Widget> _buildTaskSection(String title, List<Task> tasks) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      ),
      ...tasks.map((task) => _buildTaskCard(task)),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildTaskCard(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          leading: Icon(
            _getTaskIcon(task.status),
            color: _getTaskColor(task.status),
          ),
          title: Text(
            task.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            'Due: ${task.dueDate.toLocal().toString().split(' ')[0]}',
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getTaskColor(task.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getStatusDisplayName(task.status),
              style: TextStyle(
                color: _getTaskColor(task.status),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TaskDetailsScreen(task: task),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getTaskIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.ready:
        return Icons.lock_open;
      case TaskStatus.inProgress:
        return Icons.hourglass_empty;
      case TaskStatus.done:
        return Icons.check_circle;
      case TaskStatus.blocked:
        return Icons.lock;
    }
  }

  Color _getTaskColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.ready:
        return Colors.green;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.blue;
      case TaskStatus.blocked:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(TaskStatus status) {
    switch (status) {
      case TaskStatus.ready:
        return 'To-Do';
      case TaskStatus.inProgress:
        return 'In-Progress';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.blocked:
        return 'Locked';
    }
  }

  void _showTaskSuggestions(BuildContext context) {
    final recommendationProvider = Provider.of<RecommendationProvider>(context, listen: false);
    final suggestions = recommendationProvider.getTaskSuggestions();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Task Suggestions', style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskCreationScreen()));
                  },
                  child: const Text('Create Custom'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(suggestions[index]),
                  trailing: const Icon(Icons.add),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskCreationScreen(
                          taskToEdit: Task(
                            id: null,
                            title: suggestions[index],
                            description: '',
                            dueDate: DateTime.now().add(const Duration(days: 7)),
                            status: TaskStatus.ready,
                            predecessorIds: [],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
