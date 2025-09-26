import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kilnpilot_alpha_flutter_app/blocs/chatbot/chatbot_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/blocs/chatbot/chatbot_session_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/thermal_kpi/thermal_kpi_repository.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/dashboard/dashboard.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/dashboard/dashboard_shell.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/kiln_temperature/kiln_temperature_screen.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/optimization/optimization_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/blocs/thermal_kpi/thermal_kpi_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/chat/chatbot_screen.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/cement_operations/cement_operations_repository.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Chat Screen'));
  }
}

final GoRouter router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => DashboardShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => MaterialPage(child: Dashboard()),
        ),
        GoRoute(
          path: '/dashboard/chat',
          pageBuilder: (context, state) => MaterialPage(
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => ChatbotBloc(CementOperationsRepository()),
                ),
                BlocProvider(
                  create: (_) => ChatbotSessionBloc(CementOperationsRepository())
                ),
              ],
              child: ChatbotScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/dashboard/optimizations',
          pageBuilder: (context, state) => MaterialPage(child: OptimizationsScreen()),
        ),
        GoRoute(
          path: '/dashboard/kiln-temperature',
          pageBuilder: (context, state) => MaterialPage(
            child: BlocProvider(
              create: (_) => ThermalKpiBloc(ThermalRepository()),
              child: KilnTemperatureScreen(),
            ),
          ),
        ),
      ],
    ),
  ],
);