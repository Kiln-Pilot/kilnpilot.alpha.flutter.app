import 'package:flutter/material.dart';

class OptimizationsScreen extends StatefulWidget {
  const OptimizationsScreen({super.key});

  @override
  State<OptimizationsScreen> createState() => _OptimizationsScreenState();
}

class _OptimizationsScreenState extends State<OptimizationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  List<String> filters = ['All', 'Energy', 'Quality', 'Maintenance'];

  // Dummy optimization data
  final List<Map<String, String>> allOptimizations = [
    {
      'title': 'Reduce Kiln Heat Loss',
      'category': 'Energy',
      'description': 'Insulate kiln shell to minimize heat loss and save fuel.',
    },
    {
      'title': 'Optimize Burner Settings',
      'category': 'Quality',
      'description': 'Adjust burner for better clinker quality and lower emissions.',
    },
    {
      'title': 'Kiln Shell Scanning',
      'category': 'Maintenance',
      'description': 'Use thermal scanning to detect hot spots and prevent damage.',
    },
    {
      'title': 'Raw Mix Optimization',
      'category': 'Quality',
      'description': 'Balance raw mix for improved kiln throughput.',
    },
    {
      'title': 'Alternative Fuels',
      'category': 'Energy',
      'description': 'Switch to alternative fuels to reduce costs and CO₂.',
    },
    {
      'title': 'Kiln Drive Monitoring',
      'category': 'Maintenance',
      'description': 'Monitor drive system for early fault detection.',
    },
  ];

  List<Map<String, String>> get filteredOptimizations {
    final search = _searchController.text.toLowerCase();
    return allOptimizations.where((opt) {
      final matchesFilter = _selectedFilter == 'All' || opt['category'] == _selectedFilter;
      final matchesSearch =
          opt['title']!.toLowerCase().contains(search) || opt['description']!.toLowerCase().contains(search);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              SearchBar(
                controller: _searchController,
                hintText: 'Search optimizations...',
                onChanged: (val) => setState(() {}),
                leading: const Icon(Icons.search),
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
          // Grid of optimizations
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 2.25,
              ),
              itemCount: filteredOptimizations.length,
              itemBuilder: (context, idx) {
                final opt = filteredOptimizations[idx];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          opt['title']!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(opt['category']!),
                          backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 12),
                        Text(opt['description']!, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
