import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/task/task_cubit.dart';
import 'presentation/blocs/tag/tag_cubit.dart';
import 'presentation/blocs/schedule/schedule_cubit.dart';
import 'presentation/blocs/speech/speech_cubit.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/add_task_screen.dart';
import 'presentation/screens/task_detail_screen.dart';
import 'presentation/screens/schedule_screen.dart';
import 'presentation/screens/settings_screen.dart';

/// Root application widget.
///
/// Sets up theme, routing, and BLoC providers at the root level.
class JarvisApp extends StatefulWidget {
  const JarvisApp({super.key});

  @override
  State<JarvisApp> createState() => _JarvisAppState();
}

class _JarvisAppState extends State<JarvisApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/add-task',
          builder: (context, state) {
            final extra = state.extra as Map<String, String?>?;
            return AddTaskScreen(
              initialTitle: extra?['title'],
              initialTag: extra?['tag'],
            );
          },
        ),
        GoRoute(
          path: '/task/:id',
          builder: (context, state) => TaskDetailScreen(
            taskId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/schedule',
          builder: (context, state) => const ScheduleScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<TaskCubit>()),
        BlocProvider(create: (_) => sl<TagCubit>()),
        BlocProvider(create: (_) => sl<ScheduleCubit>()),
        BlocProvider(create: (_) => sl<SpeechCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Jarvis',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
