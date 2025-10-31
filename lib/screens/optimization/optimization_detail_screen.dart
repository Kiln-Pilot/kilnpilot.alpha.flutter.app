import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kilnpilot_alpha_flutter_app/blocs/optimization/optimization_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/optimization/dialog/create_optimization_dialog.dart';

class OptimizationDetailScreen extends StatelessWidget {
  final String optimizationId;

  const OptimizationDetailScreen({super.key, required this.optimizationId});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (popped, result) {
        if (popped) {
          context.read<OptimizationBloc>().add(ListOptimizations());
        }
      },
      child: BlocBuilder<OptimizationBloc, OptimizationState>(
        builder: (context, state) {
          if (state is OptimizationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OptimizationError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is OptimizationLoaded) {
            final opt = state.optimization;
            return Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            opt.name,
                            style: GoogleFonts.poppins(fontSize: 54, fontWeight: FontWeight.w400),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Spacer(),
                        // edit button
                        SizedBox(
                          height: 50,
                          width: 250,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.edit, size: 22),
                            label: Text(
                              'Edit Optimization',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: () async {
                              final bloc = context.read<OptimizationBloc>();
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => BlocProvider.value(
                                  value: bloc,
                                  child: CreateOptimizationDialog(initialData: opt),
                                ),
                              );
                              if (result == true) {
                                context.read<OptimizationBloc>().add(GetOptimization(opt.id));
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        // delete button same style as above
                        SizedBox(
                          height: 50,
                          width: 260,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.delete, size: 22),
                            label: Text(
                              'Delete Optimization',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Optimization'),
                                  content: const Text('Are you sure you want to delete this optimization?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                context.read<OptimizationBloc>().add(DeleteOptimization(opt.id));
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),

                      ],
                    ),
                    Text('KPI Code: ${opt.kpiCode}', style: Theme.of(context).textTheme.titleMedium),
                    Text('Active: ${opt.active ? "Yes" : "No"}'),
                    Text('Begin Time: ${opt.beginTime}'),
                    Text('End Time: ${opt.endTime}'),
                    const SizedBox(height: 24),
                    Text('Severity Classes', style: Theme.of(context).textTheme.titleLarge),
                    ...opt.severityClasses.map(
                      (sc) => Card(
                        color: Colors.grey.shade200,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Level: ${sc.level}', style: Theme.of(context).textTheme.titleMedium),
                              Text('Name: ${sc.name}'),
                              Text('Description: ${sc.description}'),
                              Text('Type: ${sc.type}'),
                              const SizedBox(height: 8),
                              Text('Thresholds:', style: Theme.of(context).textTheme.bodyLarge),
                              ..._buildThresholds(sc, opt.kpiCode),
                              const SizedBox(height: 8),
                              Text('Actions:', style: Theme.of(context).textTheme.bodyLarge),
                              ...sc.actions.map((a) => Text('- ${a.name}: ${a.description}')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // If not loaded, trigger load
          context.read<OptimizationBloc>().add(GetOptimization(optimizationId));
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  List<Widget> _buildThresholds(sc, String kpiCode) {
    final List<Widget> widgets = [];
    if (kpiCode == 'kiln_temperature') {
      if (sc.type == 'greater_than') {
        widgets.add(Text('Min Value: ${sc.thresholds.minValue}'));
        widgets.add(Text('Min Temperature Unit: ${sc.thresholds.minTemperatureUnit}'));
        widgets.add(Text('Duration (min): ${sc.thresholds.durationMinutes}'));
      } else if (sc.type == 'less_than') {
        widgets.add(Text('Max Value: ${sc.thresholds.maxValue}'));
        widgets.add(Text('Max Temperature Unit: ${sc.thresholds.maxTemperatureUnit}'));
        widgets.add(Text('Duration (min): ${sc.thresholds.durationMinutes}'));
      } else if (sc.type == 'in_between') {
        widgets.add(Text('Min Value: ${sc.thresholds.minValue}'));
        widgets.add(Text('Max Value: ${sc.thresholds.maxValue}'));
        widgets.add(Text('Min Temperature Unit: ${sc.thresholds.minTemperatureUnit}'));
        widgets.add(Text('Max Temperature Unit: ${sc.thresholds.maxTemperatureUnit}'));
        widgets.add(Text('Duration (min): ${sc.thresholds.durationMinutes}'));
      }
    } else if (kpiCode == 'rock_size') {
      final thresholds = sc.thresholds;
      if (sc.type == 'greater_than' && thresholds.greaterThan != null) {
        widgets.add(Text('Min Value: ${thresholds.greaterThan!.minValue}'));
        widgets.add(Text('Efficiency Loss (%): ${thresholds.greaterThan!.efficiencyLossPercent}'));
        widgets.add(Text('Size Deviation (%): ${thresholds.greaterThan!.sizeDeviationPercent}'));
        widgets.add(Text('Duration (min): ${thresholds.greaterThan!.durationMinutes}'));
      } else if (sc.type == 'less_than' && thresholds.lessThan != null) {
        widgets.add(Text('Max Value: ${thresholds.lessThan!.maxValue}'));
        widgets.add(Text('Efficiency Loss (%): ${thresholds.lessThan!.efficiencyLossPercent}'));
        widgets.add(Text('Size Deviation (%): ${thresholds.lessThan!.sizeDeviationPercent}'));
        widgets.add(Text('Duration (min): ${thresholds.lessThan!.durationMinutes}'));
      } else if (sc.type == 'in_between' && thresholds.inBetween != null) {
        widgets.add(Text('Min Value: ${thresholds.inBetween!.minValue}'));
        widgets.add(Text('Max Value: ${thresholds.inBetween!.maxValue}'));
        widgets.add(Text('Efficiency Loss (%): ${thresholds.inBetween!.efficiencyLossPercent}'));
        widgets.add(Text('Size Deviation (%): ${thresholds.inBetween!.sizeDeviationPercent}'));
        widgets.add(Text('Duration (min): ${thresholds.inBetween!.durationMinutes}'));
      } else {
        widgets.add(const Text('No thresholds data available.'));
      }
    }
    return widgets;
  }
}
