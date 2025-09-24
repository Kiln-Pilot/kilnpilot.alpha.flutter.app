import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/server_health/server_health_bloc.dart';
import '../../repositories/server_health/server_health_repository.dart';
import 'dialogs/server_health_dialog.dart';

class DashboardShell extends StatefulWidget {
  final Widget child;

  const DashboardShell({required this.child, super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int currentIndex = 0;

  final List<List<dynamic>> navItems = [
    ["Dashboard", Icons.dashboard_outlined, "/dashboard"],
    ["Chat", Icons.chat_bubble_outline, "/dashboard/chat"],
    ["Kiln Optimizations", Icons.settings_outlined, "/dashboard/optimizations"],
  ];

  void changeTab(int index) {
    if (index == currentIndex) return;
    setState(() {
      currentIndex = index;
      context.go(navItems[index][2] as String);
    });
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < navItems.length; i++) {
      if (location == navItems[i][2]) {
        return i;
      }
    }
    return currentIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      currentIndex = _getCurrentIndex(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServerHealthBloc(HealthRepository())..add(FetchHealthEvent()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: [
            Container(
              width: 350,
              color: Colors.grey[100],
              child: Column(
                children: [
                  // Health indicator at top
                  BlocBuilder<ServerHealthBloc, ServerHealthState>(
                    builder: (context, state) {
                      Color indicatorColor = Colors.grey;
                      String statusText = 'Unknown';
                      if (state is ServerHealthLoading) {
                        statusText = 'Checking...';
                        indicatorColor = Colors.amber;
                      } else if (state is ServerHealthSuccess) {
                        final status = state.data['status'] ?? 'unknown';
                        if (status == 'healthy') {
                          indicatorColor = Colors.green;
                          statusText = 'Healthy';
                        } else {
                          indicatorColor = Colors.red;
                          statusText = 'Unhealthy';
                        }
                      } else if (state is ServerHealthError) {
                        indicatorColor = Colors.red;
                        statusText = 'Error';
                      }
                      return InkWell(
                        onTap: () async {
                          final bloc = context.read<ServerHealthBloc>();
                          bloc.add(FetchDetailedHealthEvent());
                          await showDialog(
                            context: context,
                            builder: (ctx) {
                              return BlocProvider.value(
                                value: bloc,
                                child: const ServerHealthDialog(),
                              );
                            },
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: indicatorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: indicatorColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.health_and_safety, color: indicatorColor),
                              SizedBox(width: 12),
                              Text(
                                'Server: $statusText',
                                style: TextStyle(color: indicatorColor, fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              Icon(Icons.info_outline, color: indicatorColor),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: navItems.length,
                      itemBuilder: (context, index) {
                        final item = navItems[index];
                        final isSelected = index == currentIndex;
                        return ListTile(
                          leading: Icon(item[1], color: isSelected ? Theme.of(context).colorScheme.primary : null),
                          title: Text(
                            item[0],
                            style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : null),
                          ),
                          selected: isSelected,
                          onTap: () => changeTab(index),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}
