import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Updated navItems: add a section header and a KPI entry
  final List<Map<String, dynamic>> navItems = [
    {"type": "item", "label": "Dashboard", "icon": Icons.dashboard_outlined, "route": "/dashboard"},
    {"type": "item", "label": "Chat", "icon": Icons.chat_bubble_outline, "route": "/dashboard/chat"},
    {
      "type": "item",
      "label": "Optimizations",
      "icon": Icons.settings_outlined,
      "route": "/dashboard/optimizations",
    },
    {"type": "section", "label": "KPIs"},
    {"type": "item", "label": "Kiln Temperature", "icon": Icons.thermostat, "route": "/dashboard/kiln-temperature"},
    {"type": "item", "label": "Conveyor Belt Damage", "icon": Icons.dangerous, "route": "/dashboard/conveyor-belt-damage"},
    // ppe detection
    {"type": "item", "label": "PPE Detection", "icon": Icons.security, "route": "/dashboard/ppe-detection"},

  ];

  void changeTab(int index) {
    if (index == currentIndex) return;
    setState(() {
      currentIndex = index;
      final item = navItems[index];
      if (item["type"] == "item") {
        context.go(item["route"] as String);
      }
    });
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < navItems.length; i++) {
      final item = navItems[i];
      if (item["type"] == "item" && location == item["route"]) {
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
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Row(
                  children: [
                    Text('Kiln Pilot', style: GoogleFonts.poppins(fontSize: 84)),
                    Spacer(),
                    // Use other widgets here if needed
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: Row(
                children: [
                  Container(
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(60)),
                    ),

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
                                    return BlocProvider.value(value: bloc, child: const ServerHealthDialog());
                                  },
                                );
                              },
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(60),
                                bottomRight: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                                topLeft: Radius.circular(8),
                              ),
                              child: Container(
                                height: 54,
                                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: indicatorColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(60),
                                    bottomRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                    topLeft: Radius.circular(8),
                                  ),
                                  border: Border.all(color: indicatorColor, width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.health_and_safety, color: indicatorColor),
                                    SizedBox(width: 12),
                                    Text(
                                      'Server: $statusText',
                                      style: GoogleFonts.poppins(color: indicatorColor, fontWeight: FontWeight.w500, fontSize: 18),
                                    ),
                                    Spacer(),
                                    Icon(Icons.info_outline, color: indicatorColor),
                                    SizedBox(width: 12),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: ListView.separated(
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemCount: navItems.length,
                            itemBuilder: (context, index) {
                              final item = navItems[index];
                              if (item["type"] == "section") {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  child: Text(
                                    item["label"],
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                    ),
                                  ),
                                );
                              }
                              final isSelected = index == currentIndex;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: isSelected ? Colors.grey.withOpacity(0.3) : Colors.white,
                                    foregroundColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.black,
                                    alignment: Alignment.centerLeft,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => changeTab(index),
                                  child: Row(
                                    children: [
                                      Icon(item["icon"], color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[700], size: 24,),
                                      const SizedBox(width: 16),
                                      Text(
                                        item["label"],
                                        style: GoogleFonts.jost(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected ? Colors.black : Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
          ],
        ),
      ),
    );
  }
}
