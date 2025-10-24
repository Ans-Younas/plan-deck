import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plan_deck/data/models/task.dart';
import 'package:plan_deck/data/models/task_status.dart';
import 'package:plan_deck/application/providers/task_providers.dart';

class TaskCreationScreen extends StatefulWidget {
  final Task? taskToEdit;

  const TaskCreationScreen({super.key, this.taskToEdit});

  @override
  State<TaskCreationScreen> createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();
  DateTime? _selectedDueDate;
  List<String> _selectedPredecessorIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _taskNameController.text = widget.taskToEdit!.title;
      _taskDescriptionController.text = widget.taskToEdit!.description;
      _selectedDueDate = widget.taskToEdit!.dueDate;
      _selectedPredecessorIds = List.from(widget.taskToEdit!.predecessorIds);
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? today,
      firstDate: today,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _addPredecessors() async {
    final tasksNotifier = Provider.of<TasksNotifier>(context, listen: false);
    final allTasks = tasksNotifier.tasks;

    final List<Task> availableTasks = allTasks
        .where(
          (task) =>
              (widget.taskToEdit == null || task.id != widget.taskToEdit!.id),
        )
        .toList();

    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return _PredecessorSelectionDialog(
          availableTasks: availableTasks,
          initialSelected: _selectedPredecessorIds,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedPredecessorIds = result;
      });
    }
  }

  void _createTask() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDueDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a due date.')),
        );
        return;
      }

      // Determine initial status based on dependencies
      final tasksNotifier = Provider.of<TasksNotifier>(context, listen: false);
      TaskStatus initialStatus = TaskStatus.ready;

      // Check if any predecessors are not done
      for (String predecessorId in _selectedPredecessorIds) {
        final predecessor = tasksNotifier.getTaskById(predecessorId);
        if (predecessor != null && predecessor.status != TaskStatus.done) {
          initialStatus = TaskStatus.blocked;
          break;
        }
      }

      final taskData = Task(
        id: widget
            .taskToEdit
            ?.id, // Use existing ID if editing, null if creating new
        title: _taskNameController.text,
        description: _taskDescriptionController.text,
        dueDate: _selectedDueDate!,
        status: initialStatus,
        predecessorIds: List.from(
          _selectedPredecessorIds,
        ), // Ensure a copy is passed
      );

      if (widget.taskToEdit != null) {
        await tasksNotifier.updateTask(taskData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task updated successfully!')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        await tasksNotifier.addTask(taskData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task created successfully!')),
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _taskDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksNotifier = Provider.of<TasksNotifier>(
      context,
    ); // Listen to tasks for dependency selection

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.taskToEdit != null ? 'Edit Task' : 'New Task',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _createTask,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text('Task Name', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _taskNameController,
              decoration: InputDecoration(
                hintText: 'e.g., Design a new logo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            Text(
              'Task Description',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _taskDescriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'e.g., Research competitors, sketch initial ideas...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 16.0),
            Text('Due Date', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8.0),
            GestureDetector(
              onTap: () => _selectDueDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDueDate == null
                          ? 'mm/dd/yyyy'
                          : '${_selectedDueDate!.month}/${_selectedDueDate!.day}/${_selectedDueDate!.year}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Dependencies',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            // Display selected predecessors
            if (_selectedPredecessorIds.isNotEmpty)
              ..._selectedPredecessorIds.map((id) {
                final task = tasksNotifier.getTaskById(id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Chip(
                    label: Text(task?.title ?? 'Unknown Task'),
                    onDeleted: () {
                      setState(() {
                        _selectedPredecessorIds.remove(id);
                      });
                    },
                  ),
                );
              }).toList(),
            GestureDetector(
              onTap: _addPredecessors,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8.0),
                    Text(
                      'Add pre-requisite tasks',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 16.0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _createTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                widget.taskToEdit != null ? 'Update Task' : 'Create Task',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PredecessorSelectionDialog extends StatefulWidget {
  final List<Task> availableTasks;
  final List<String> initialSelected;

  const _PredecessorSelectionDialog({
    required this.availableTasks,
    required this.initialSelected,
  });

  @override
  State<_PredecessorSelectionDialog> createState() => _PredecessorSelectionDialogState();
}

class _PredecessorSelectionDialogState extends State<_PredecessorSelectionDialog> {
  late List<String> tempSelected;

  @override
  void initState() {
    super.initState();
    tempSelected = List.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Predecessor Tasks'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.availableTasks.map((task) {
            return CheckboxListTile(
              title: Text(task.title),
              value: tempSelected.contains(task.id),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    tempSelected.add(task.id);
                  } else {
                    tempSelected.remove(task.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Add'),
          onPressed: () {
            Navigator.of(context).pop(tempSelected);
          },
        ),
      ],
    );
  }
}
