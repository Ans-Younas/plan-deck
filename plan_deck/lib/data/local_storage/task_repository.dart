import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:plan_deck/data/models/task.dart';

class TaskRepository extends ChangeNotifier {
  late Box<Task> _taskBox;

  Future<void> init() async {
    _taskBox = await Hive.openBox<Task>('tasks');
  }

  List<Task> get tasks => _taskBox.values.toList();

  Future<void> addTask(Task task) async {
    await _taskBox.put(task.id, task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
    notifyListeners();
  }
}
