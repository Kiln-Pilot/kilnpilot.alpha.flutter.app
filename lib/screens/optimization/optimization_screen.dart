import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kilnpilot_alpha_flutter_app/blocs/optimization/optimization_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/optimization/serializers/optimization_response.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/optimization/dialog/create_optimization_dialog.dart';

class OptimizationsScreen extends StatefulWidget {
  const OptimizationsScreen({super.key});

  @override
  State<OptimizationsScreen> createState() => _OptimizationsScreenState();
}

class _OptimizationsScreenState extends State<OptimizationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  List<String> filters = ['All', 'Energy', 'Quality', 'Maintenance'];

  @override
  void initState() {
    super.initState();
    // Trigger load on init
    context.read<OptimizationBloc>().add(ListOptimizations());
  }

  List<OptimizationResponse> _filter(List<OptimizationResponse> all) {
    final search = _searchController.text.toLowerCase();
    return all.where((opt) {
      final matchesFilter =
          _selectedFilter == 'All' ||
          (opt.kpiCode == 'kiln_temperature' && _selectedFilter == 'Energy') ||
          (opt.kpiCode == 'rack_size' && _selectedFilter == 'Maintenance');
      final matchesSearch =
          opt.name.toLowerCase().contains(search) ||
          opt.severityClasses.any(
            (sc) => sc.name.toLowerCase().contains(search) || sc.description.toLowerCase().contains(search),
          );
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Optimization'),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => const CreateOptimizationDialog(),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            Text(
              'Kiln Optimizations',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
      
            const SizedBox(height: 24),
            // Search and filter row
            Row(
              children: [
                // Search bar
                Expanded(
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Search optimizations...',
                    onChanged: (val) => setState(() {}),
                    leading: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(width: 16),
                // Filter dropdown
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: filters.map((f) => DropdownMenuItem<String>(value: f, child: Text(f))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedFilter = val);
                  },
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // BlocBuilder for grid
            BlocBuilder<OptimizationBloc, OptimizationState>(
              builder: (context, state) {
                if (state is OptimizationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is OptimizationsLoaded) {
                  final optimizations = _filter(state.optimizations);
                  return Expanded(
                    child: ListView.builder(
                      itemCount: optimizations.length,
                      itemBuilder: (context, index) {
                        final opt = optimizations[index];
                        return Card(
                          child: ListTile(
                            title: Text(opt.name),
                            subtitle: Text(opt.kpiCode),
                            trailing: Icon(Icons.chevron_right),
                            onTap: () {
                              context.read<OptimizationBloc>().add(GetOptimization(opt.id));
                              context.go('/dashboard/optimizations/detail/${opt.id}');
                            },
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is OptimizationError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}