import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/clinker_quality_kpi/clinker_quality_bloc.dart';

class SingleSectionWidget extends StatelessWidget {
  final Map<String, Map<String, String>> featuresMeta;
  final Map<String, TextEditingController> controllers;
  final GlobalKey<FormState> formKey;

  const SingleSectionWidget({super.key, required this.featuresMeta, required this.controllers, required this.formKey});

  void _submit(BuildContext context) {
    if (!formKey.currentState!.validate()) return;
    final Map<String, dynamic> payload = {};
    for (final k in featuresMeta.keys) {
      final val = controllers[k]!.text.trim();
      if (featuresMeta[k]!['type'] == 'string') {
        payload[k] = val;
      } else {
        payload[k] = val.isEmpty ? null : double.tryParse(val) ?? val;
      }
    }
    context.read<ClinkerQualityBloc>().add(PredictSingleEvent(payload));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manual input for a single sample', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 2 : 1,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            children: featuresMeta.keys.map((k) {
              final meta = featuresMeta[k]!;
              return Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meta['label']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${meta['type']} — ${meta['desc']}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers[k],
                        decoration: InputDecoration(border: const OutlineInputBorder(), isDense: true, hintText: meta['type'] == 'string' ? 'e.g. good' : 'numeric value'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(onPressed: () => _submit(context), child: const Text('Predict')),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  for (final c in controllers.values) c.clear();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]),
                child: const Text('Clear', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
