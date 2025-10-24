import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart'; // Import uuid
import 'package:plan_deck/data/models/task_status.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  TaskStatus status;

  @HiveField(5)
  List<String> predecessorIds; // IDs of tasks this task depends on

  Task({
    String? id, // Make id optional in constructor
    required this.title,
    this.description = '',
    required this.dueDate,
    this.status = TaskStatus.ready, // Changed from todo to ready
    this.predecessorIds = const [],
  }) : id = id ?? const Uuid().v4(); // Generate UUID if not provided
}
