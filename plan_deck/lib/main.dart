import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plan_deck/core/constants/app_themes.dart';
import 'package:plan_deck/data/local_storage/hive_init.dart';
import 'package:plan_deck/data/local_storage/task_repository.dart';
import 'package:plan_deck/application/providers/theme_provider.dart';
import 'package:plan_deck/application/providers/task_providers.dart';
import 'package:plan_deck/application/providers/recommendation_provider.dart';
import 'package:plan_deck/presentation/dashboard/dashboard_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeHive();
  final taskRepository = TaskRepository();
  await taskRepository.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskRepository>(
          create: (context) => taskRepository,
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<TasksNotifier>(
          create: (context) => TasksNotifier(taskRepository),
        ),
        ChangeNotifierProxyProvider<TasksNotifier, RecommendationProvider>(
          create: (context) => RecommendationProvider(
            Provider.of<TasksNotifier>(context, listen: false),
          ),
          update: (context, tasksNotifier, recommendationProvider) =>
              recommendationProvider!..updateRecommendation(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Plan Deck',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          home: const AppInitializer(),
        );
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // App initialization complete
  }

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}
