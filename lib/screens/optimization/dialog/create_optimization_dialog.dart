import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/blocs/optimization/optimization_bloc.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/optimization/serializers/optimization_create.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/optimization/serializers/optimization_response.dart';
import 'package:kilnpilot_alpha_flutter_app/repositories/optimization/serializers/optimization_update.dart';

class CreateOptimizationDialog extends StatefulWidget {
  final OptimizationResponse? initialData;
  const CreateOptimizationDialog({super.key, this.initialData});

  @override
  State<CreateOptimizationDialog> createState() => _CreateOptimizationDialogState();
}

class _CreateOptimizationDialogState extends State<CreateOptimizationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _kpiCodeController;
  late TextEditingController _beginTimeController;
  late TextEditingController _endTimeController;
  bool _active = true;
  List<dynamic> _severityClasses = [];

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _nameController = TextEditingController(text: d?.name ?? '');
    _kpiCodeController = TextEditingController(text: d?.kpiCode ?? '');
    _beginTimeController = TextEditingController(text: d?.beginTime ?? '');
    _endTimeController = TextEditingController(text: d?.endTime ?? '');
    _active = d?.active ?? true;
    _severityClasses = d?.severityClasses ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _kpiCodeController.dispose();
    _beginTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final create = OptimizationCreate(
        name: _nameController.text,
        kpiCode: _kpiCodeController.text,
        beginTime: _beginTimeController.text,
        endTime: _endTimeController.text,
        active: _active,
        severityClasses: _severityClasses,
      );
      if (widget.initialData == null) {
        context.read<OptimizationBloc>().add(CreateOptimization(create));
      } else {
        final update = OptimizationUpdate(
          name: _nameController.text,
          kpiCode: _kpiCodeController.text,
          beginTime: _beginTimeController.text,
          endTime: _endTimeController.text,
          active: _active,
          severityClasses: _severityClasses,
        );
        context.read<OptimizationBloc>().add(UpdateOptimization(widget.initialData!.id, update));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: BlocListener<OptimizationBloc, OptimizationState>(
        listener: (context, state) {
          if (state is OptimizationCreated || state is OptimizationUpdated) {
            Navigator.of(context).pop(true);
          } else if (state is OptimizationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.initialData == null ? 'Create Optimization' : 'Edit Optimization', style: Theme.of(context).textTheme.titleLarge),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _kpiCodeController,
                    decoration: const InputDecoration(labelText: 'KPI Code'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _beginTimeController,
                    decoration: const InputDecoration(labelText: 'Begin Time'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(labelText: 'End Time'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  SwitchListTile(
                    title: const Text('Active'),
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                  // TODO: Add UI for severityClasses
                  const SizedBox(height: 24),
                  BlocBuilder<OptimizationBloc, OptimizationState>(
                    builder: (context, state) {
                      if (state is OptimizationLoading) {
                        return const CircularProgressIndicator();
                      }
                      return ElevatedButton(
                        onPressed: _submit,
                        child: Text(widget.initialData == null ? 'Create' : 'Update'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
