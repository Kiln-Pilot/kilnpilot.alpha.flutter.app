import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kilnpilot_alpha_flutter_app/blocs/optimization/optimization_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/optimization/serializers/optimization_response.dart';
import 'package:kilnpilot_alpha_flutter_app/screens/optimization/dialog/create_optimization_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class OptimizationsScreen extends StatefulWidget {
  const OptimizationsScreen({super.key});

  @override
  State<OptimizationsScreen> createState() => _OptimizationsScreenState();
}

class _OptimizationsScreenState extends State<OptimizationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _filterSearchController = TextEditingController();
  String? selectedValue = 'All';
  List<String> filters = ['All', 'Energy', 'Quality', 'Maintenance'];

  @override
  void initState() {
    super.initState();
    // Trigger load on init
    context.read<OptimizationBloc>().add(ListOptimizations());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterSearchController.dispose();
    super.dispose();
  }

  List<OptimizationResponse> _filter(List<OptimizationResponse> all) {
    final search = _searchController.text.toLowerCase();
    final filter = selectedValue ?? 'All';
    return all.where((opt) {
      final matchesFilter =
          filter == 'All' ||
          (opt.kpiCode == 'kiln_temperature' && filter == 'Energy') ||
          (opt.kpiCode == 'rack_size' && filter == 'Maintenance');
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
          await showDialog(context: context, builder: (context) => const CreateOptimizationDialog());
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            Text('Optimizations', style: GoogleFonts.poppins(fontSize: 54, fontWeight: FontWeight.w400)),

            const SizedBox(height: 24),
            // Search and filter row
            Row(
              children: [
                // Search bar
                Expanded(
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Search optimizations...',
                    hintStyle: WidgetStateProperty.all(
                      GoogleFonts.poppins(fontSize: 18, color: Theme.of(context).hintColor),
                    ),
                    textStyle: WidgetStateProperty.all(GoogleFonts.poppins(fontSize: 18, color: Colors.black)),
                    onChanged: (val) => setState(() {}),
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                    leading: Padding(padding: const EdgeInsets.all(12.0), child: Icon(Icons.search)),
                  ),
                ),
                const SizedBox(width: 16),
                // Filter dropdown using DropdownButton2
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    customButton: Container(
                      width: 250,
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade700),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedValue ?? 'Select Filter',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: selectedValue == null ? Theme.of(context).hintColor : Colors.black,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    hint: Text('Select Filter', style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                    items: filters
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item, style: const TextStyle(fontSize: 14)),
                          ),
                        )
                        .toList(),
                    value: selectedValue,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                      });
                    },
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height: 40,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        color: Colors.white,
                      ),
                    ),
                    dropdownStyleData: const DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(height: 40),
                    dropdownSearchData: DropdownSearchData(
                      searchController: _filterSearchController,
                      searchInnerWidgetHeight: 50,
                      searchInnerWidget: Container(
                        height: 50,
                        padding: const EdgeInsets.only(top: 8, bottom: 4, right: 8, left: 8),
                        child: TextFormField(
                          expands: true,
                          maxLines: null,
                          controller: _filterSearchController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            hintText: 'Search for a filter...',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
                      },
                    ),
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        _filterSearchController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // BlocBuilder for grid
            BlocBuilder<OptimizationBloc, OptimizationState>(
              builder: (context, state) {
                if (state is OptimizationLoading) {
                  return Expanded(child: const Center(child: CircularProgressIndicator()));
                } else if (state is OptimizationsLoaded) {
                  final optimizations = _filter(state.optimizations);
                  return Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemCount: optimizations.length,
                      itemBuilder: (context, index) {
                        final opt = optimizations[index];
                        return FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 21),
                            backgroundColor: Colors.grey.shade100,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () {
                            context.read<OptimizationBloc>().add(GetOptimization(opt.id));
                            context.go('/dashboard/optimizations/detail/${opt.id}');
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(opt.name, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('KPI Code: ${opt.kpiCode}', style: GoogleFonts.poppins(fontSize: 16)),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: opt.active ? Colors.green.shade100 : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Status: ${opt.active ? 'Active' : 'Inactive'}',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Severity Classes:',
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              ...opt.severityClasses.map(
                                (sc) => Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    '- ${sc.name}: ${sc.description}',
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
                                  ),
                                ),
                              ),
                            ],
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
