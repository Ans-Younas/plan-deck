import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plan_deck/data/models/task.dart';
import 'package:plan_deck/data/models/task_status.dart';

Future<void> initializeHive() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Register adapters
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(TaskAdapter());

  // Open boxes if needed, e.g., for tasks
  // await Hive.openBox<Task>('tasks');
}
