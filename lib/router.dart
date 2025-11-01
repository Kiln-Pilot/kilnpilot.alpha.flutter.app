import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kilnpilot_alpha_flutter_app/blocs/chatbot/chatbot_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/blocs/chatbot/chatbot_session_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/blocs/ppe_detection_kpi/ppe_detection_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/blocs/rock_size_detection_kpi/rock_detection_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/cement_operations/chatbot_repository.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/clinker_quality_kpi/clinker_quality_kpi_repository.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/conveyor_belt_damage_kpi/conveyor_belt_damage_kpi_repository.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/emission_prediction_kpi/emission_repository_kpi_repository.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/optimization/optimization_repository.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/ppe_detection_kpi/ppe_detection_kpi_repository.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/rock_size_detection_kpi/rock_size_detection_kpi_repository.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/thermal_kpi/thermal_kpi_repository.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/clinker_quality/clinker_quality_screen.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/conveyor_belt_damage/conveyor_belt_damage_screen.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/dashboard/dashboard.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/dashboard/dashboard_shell.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/emission_predictions/emission_prediction_screen.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/kiln_temperature/kiln_temperature_screen.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/optimization/optimization_detail_screen.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/optimization/optimization_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/blocs/thermal_kpi/thermal_kpi_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/chat/chatbot_screen.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/ppe_detection/ppe_detection_screen.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/rock_size_detection/rock_size_detection_screen.dart';

import 'blocs/clinker_quality_kpi/clinker_quality_bloc.dart';
import 'blocs/convery_belt_damage_kpi/conveyor_belt_damage_bloc.dart';
import 'blocs/emission_prediction_kpi/emission_prediction_bloc.dart';
import 'blocs/optimization/optimization_bloc.dart';

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
      builder: (context, state, child) => BlocProvider(
        create: (context) => OptimizationBloc(OptimizationRepository())..add(ListOptimizations()),
        child: DashboardShell(child: child),
      ),
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
                BlocProvider(create: (_) => ChatbotBloc(ChatbotRepository())),
                BlocProvider(create: (_) => ChatbotSessionBloc(ChatbotRepository())),
              ],
              child: ChatbotScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/dashboard/optimizations',
          pageBuilder: (context, state) => MaterialPage(child: const OptimizationsScreen()),
          routes: [
            GoRoute(
              path: 'detail/:optimizationId',
              pageBuilder: (context, state) {
                final optimizationId = state.pathParameters['optimizationId']!;
                return MaterialPage(child: OptimizationDetailScreen(optimizationId: optimizationId));
              },
            ),
          ],
        ),
        GoRoute(
          path: '/dashboard/kiln-temperature',
          pageBuilder: (context, state) => MaterialPage(
            child: BlocProvider(create: (_) => ThermalKpiBloc(ThermalRepository()), child: KilnTemperatureScreen()),
          ),
        ),
        GoRoute(
          path: '/dashboard/conveyor-belt-damage',
          pageBuilder: (context, state) => MaterialPage(
            child: BlocProvider(
              create: (_) => ConveyorBeltDamageBloc(ConveyorBeltRepository()),
              child: ConveyorBeltDamageScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/dashboard/ppe-detection',
          pageBuilder: (context, state) => MaterialPage(
            child: BlocProvider(create: (_) => PpeDetectionBloc(PpeDetectionRepository()), child: PpeDetectionScreen()),
          ),
        ),
        GoRoute(
          path: '/dashboard/rock-size',
          pageBuilder: (context, state) => MaterialPage(
            child: BlocProvider(
              create: (_) => RockDetectionBloc(RockSizeDetectionRepository()),
              child: RockSizeDetectionScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/dashboard/clinker-quality',
          pageBuilder: (context, state) => MaterialPage(
            child: BlocProvider(
              create: (context) => ClinkerQualityBloc(ClinkerQualityRepository()),
              child: ClinkerQualityScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/dashboard/emission-prediction',
          pageBuilder: (context, state) => MaterialPage(
            child: BlocProvider(
              create: (context) => EmissionPredictionBloc(EmissionPredictionRepository()),
              child: EmissionPredictionScreen(),
            ),
          ),
        ),
      ],
    ),
  ],
);
