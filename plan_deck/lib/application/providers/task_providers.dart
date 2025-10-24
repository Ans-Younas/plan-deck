import 'package:flutter/material.dart';
import 'package:plan_deck/data/local_storage/task_repository.dart';
import 'package:plan_deck/data/models/task.dart';
import 'package:plan_deck/data/models/task_status.dart';

class TasksNotifier extends ChangeNotifier {
  final TaskRepository _taskRepository;
  List<Task> _tasks = [];

  TasksNotifier(this._taskRepository) {
    _loadTasks();
  }

  List<Task> get tasks => _tasks;

  List<Task> get readyTasks =>
      _tasks.where((task) => task.status == TaskStatus.ready).toList();
  List<Task> get inProgressTasks =>
      _tasks.where((task) => task.status == TaskStatus.inProgress).toList();
  List<Task> get doneTasks =>
      _tasks.where((task) => task.status == TaskStatus.done).toList();
  List<Task> get blockedTasks =>
      _tasks.where((task) => task.status == TaskStatus.blocked).toList();

  Future<void> _loadTasks() async {
    await _taskRepository.init(); // Ensure repository is initialized
    _tasks = _taskRepository.tasks;
    _recalculateAllTaskStatuses(); // Recalculate statuses on load
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    // Ensure predecessorIds are correctly passed and saved
    final taskToAdd = Task(
      id: task.id, // Assuming task already has an ID or it's generated
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      status: task.status,
      predecessorIds: task.predecessorIds,
    );
    await _taskRepository.addTask(taskToAdd);
    _tasks = _taskRepository.tasks;
    _recalculateAllTaskStatuses();
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    // If task has no id, treat it as a new task
    if (updatedTask.id == null) {
      await addTask(updatedTask);
      return;
    }

    // Find existing task
    final taskIndex = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (taskIndex == -1) {
      await addTask(updatedTask);
      return;
    }

    final taskToUpdate = _tasks[taskIndex];
    taskToUpdate.title = updatedTask.title;
    taskToUpdate.description = updatedTask.description;
    taskToUpdate.dueDate = updatedTask.dueDate;
    taskToUpdate.status = updatedTask.status;
    taskToUpdate.predecessorIds = updatedTask.predecessorIds;

    await _taskRepository.updateTask(taskToUpdate);
    _tasks = _taskRepository.tasks;
    _recalculateAllTaskStatuses();
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    await _taskRepository.deleteTask(taskId);
    _tasks = _taskRepository.tasks;
    _recalculateAllTaskStatuses();
    notifyListeners();
  }

  void _recalculateAllTaskStatuses() {
    for (var task in _tasks) {
      if (task.status == TaskStatus.done ||
          task.status == TaskStatus.inProgress) {
        continue;
      }

      bool isBlocked = false;
      for (String predecessorId in task.predecessorIds) {
        final predecessor = getTaskById(predecessorId);
        if (predecessor != null && predecessor.status != TaskStatus.done) {
          isBlocked = true;
          break;
        }
      }

      if (isBlocked) {
        task.status = TaskStatus.blocked;
      } else {
        task.status = TaskStatus.ready;
      }
    }
  }

  // Helper to get a task by ID
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper to get successor tasks
  List<Task> getSuccessorTasks(String taskId) {
    return _tasks
        .where((task) => task.predecessorIds.contains(taskId))
        .toList();
  }
}
