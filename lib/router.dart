import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/dashboard.dart';


final GoRouter router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
    path: '/dashboard',
    pageBuilder: (context, state) => MaterialPage(child: Dashboard()),
    ),
  ],
);