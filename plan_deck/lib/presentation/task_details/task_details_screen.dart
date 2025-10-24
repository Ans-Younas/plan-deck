import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plan_deck/data/models/task.dart';
import 'package:plan_deck/data/models/task_status.dart';
import 'package:plan_deck/core/constants/app_colors.dart';
import 'package:plan_deck/core/helpers/date_formatter.dart';
import 'package:plan_deck/application/providers/task_providers.dart';
import 'package:plan_deck/presentation/task_creation/task_creation_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Task _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  void _toggleTaskStatus() {
    if (_currentTask.status == TaskStatus.blocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This task is locked and cannot be completed.'),
        ),
      );
      return;
    }
    final tasksNotifier = Provider.of<TasksNotifier>(context, listen: false);
    setState(() {
      if (_currentTask.status == TaskStatus.done) {
        _currentTask.status = TaskStatus.ready;
      } else {
        _currentTask.status = TaskStatus.done;
      }
    });
    tasksNotifier.updateTask(_currentTask);
  }

  void _startTask() {
    if (_currentTask.status == TaskStatus.blocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This task is locked and cannot be started.'),
        ),
      );
      return;
    }
    final tasksNotifier = Provider.of<TasksNotifier>(context, listen: false);
    setState(() {
      _currentTask.status = TaskStatus.inProgress;
    });
    tasksNotifier.updateTask(_currentTask);
  }

  void _editTask() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => TaskCreationScreen(taskToEdit: _currentTask),
          ),
        )
        .then((result) {
          if (result == true) {
            // Refresh the task data
            final tasksNotifier = Provider.of<TasksNotifier>(
              context,
              listen: false,
            );
            final updatedTask = tasksNotifier.getTaskById(_currentTask.id);
            if (updatedTask != null) {
              setState(() {
                _currentTask = updatedTask;
              });
            }
          }
        });
  }

  void _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final tasksNotifier = Provider.of<TasksNotifier>(context, listen: false);
      await tasksNotifier.deleteTask(_currentTask.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Task Details', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _editTask,
            child: const Text(
              'Edit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _currentTask.status == TaskStatus.done,
                    onChanged: (bool? value) {
                      _toggleTaskStatus();
                    },
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentTask.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Chip(
                          label: Text(
                            _currentTask.status.name.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textLight, // Example color
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          backgroundColor:
                              AppColors.accentLight, // Example color
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                _currentTask.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24.0),
              // Due Date Card
              Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      const SizedBox(width: 16.0),
                      Text(
                        'Due Date',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text(
                        DateFormatter.formatDate(_currentTask.dueDate),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8.0),

              const SizedBox(height: 24.0),
              Text(
                'Linked Tasks',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              // Requires Tasks
              Text('Requires', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8.0),
              Consumer<TasksNotifier>(
                builder: (context, tasksNotifier, child) {
                  final predecessors = _currentTask.predecessorIds
                      .map((id) => tasksNotifier.getTaskById(id))
                      .where((task) => task != null)
                      .cast<Task>()
                      .toList();

                  if (predecessors.isEmpty) {
                    return Card(
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_open,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            const SizedBox(width: 16.0),
                            Text(
                              'No prerequisite tasks',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: predecessors
                        .map(
                          (task) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              color: Theme.of(context).cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  task.status == TaskStatus.done
                                      ? Icons.check_circle
                                      : Icons.lock,
                                  color: task.status == TaskStatus.done
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                title: Text(task.title),
                                subtitle: Text(task.status.name.toUpperCase()),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16.0,
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TaskDetailsScreen(task: task),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              // Unlocks Tasks
              Text('Unlocks', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8.0),
              Consumer<TasksNotifier>(
                builder: (context, tasksNotifier, child) {
                  final successors = tasksNotifier.getSuccessorTasks(
                    _currentTask.id,
                  );

                  if (successors.isEmpty) {
                    return Card(
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.link_off,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            const SizedBox(width: 16.0),
                            Text(
                              'No dependent tasks',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: successors
                        .map(
                          (task) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              color: Theme.of(context).cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  task.status == TaskStatus.blocked
                                      ? Icons.lock
                                      : task.status == TaskStatus.ready
                                      ? Icons.check_circle_outline
                                      : Icons.link,
                                  color: task.status == TaskStatus.blocked
                                      ? Colors.grey
                                      : task.status == TaskStatus.ready
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                                title: Text(task.title),
                                subtitle: Text(task.status.name.toUpperCase()),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16.0,
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TaskDetailsScreen(task: task),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 100.0), // Space for the bottom buttons
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: _deleteTask,
                  ),
                  const SizedBox(width: 16.0),
                  if (_currentTask.status == TaskStatus.ready)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _startTask,
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text(
                          'Start Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A5FBF),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _currentTask.status == TaskStatus.blocked
                            ? null
                            : _toggleTaskStatus,
                        icon: Icon(
                          _currentTask.status == TaskStatus.done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        label: Text(
                          _currentTask.status == TaskStatus.done
                              ? 'Mark as Incomplete'
                              : 'Mark as Complete',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentTask.status == TaskStatus.done
                              ? Colors.orange
                              : Colors.green,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
