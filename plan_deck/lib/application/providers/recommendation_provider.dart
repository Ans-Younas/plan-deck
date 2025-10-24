import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plan_deck/data/models/task.dart';
import 'package:plan_deck/application/providers/task_providers.dart';

class RecommendationProvider extends ChangeNotifier {
  Task? _upNextTask;
  final TasksNotifier _tasksNotifier;

  RecommendationProvider(this._tasksNotifier) {
    _tasksNotifier.addListener(updateRecommendation);
    updateRecommendation();
  }

  Task? get upNextTask => _upNextTask;

  void updateRecommendation() {
    final readyTasks = _tasksNotifier.readyTasks;

    if (readyTasks.isEmpty) {
      _upNextTask = null;
    } else {
      readyTasks.sort((a, b) {
        int dueDateComparison = a.dueDate.compareTo(b.dueDate);
        if (dueDateComparison != 0) {
          return dueDateComparison;
        }
        return a.id.compareTo(b.id);
      });
      _upNextTask = readyTasks.first;
    }
    notifyListeners();
  }

  List<String> getTaskSuggestions() {
    return [
      'Review and organize emails',
      'Plan weekly goals',
      'Update project documentation',
      'Backup important files',
      'Clean workspace',
      'Code review for team members',
      'Update dependencies',
      'Write unit tests',
      'Refactor legacy code',
      'Update README documentation',
      'Set up CI/CD pipeline',
      'Database optimization',
      'Security audit',
      'Performance testing',
      'API documentation update',
    ];
  }

  @override
  void dispose() {
    _tasksNotifier.removeListener(updateRecommendation);
    super.dispose();
  }

  static RecommendationProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<RecommendationProvider>(context, listen: true);
  }
}
