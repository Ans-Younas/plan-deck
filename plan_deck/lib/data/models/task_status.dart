import 'package:hive/hive.dart';

part 'task_status.g.dart';

@HiveType(typeId: 0)
enum TaskStatus {
  @HiveField(0)
  ready,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  done,
  @HiveField(3)
  blocked,
}
