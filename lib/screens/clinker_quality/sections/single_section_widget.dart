import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/clinker_quality_kpi/clinker_quality_bloc.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';

class ClinkerQualitySingleSectionWidget extends StatelessWidget {
  final Map<String, Map<String, String>> featuresMeta;
  final Map<String, TextEditingController> controllers;
  final GlobalKey<FormState> formKey;

  const ClinkerQualitySingleSectionWidget({
    super.key,
    required this.featuresMeta,
    required this.controllers,
    required this.formKey,
  });

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
    // Prepare three columns (left, middle, right)
    final keys = featuresMeta.keys.toList();
    final int total = keys.length;
    // distribute items across 3 columns; give extra items to left, then middle
    final int base = total ~/ 3;
    final int rem = total % 3;
    final int leftCount = base + (rem > 0 ? 1 : 0);
    final int middleCount = base + (rem > 1 ? 1 : 0);
    // rightCount not needed explicitly; rightKeys computed using sublist
    final leftKeys = keys.sublist(0, leftCount);
    final middleKeys = keys.sublist(leftCount, leftCount + middleCount);
    final rightKeys = keys.sublist(leftCount + middleCount, total);

    Widget buildField(String k) {
      final meta = featuresMeta[k]!;
      // If meta provides 'options' (comma-separated), render a dropdown
      if (meta.containsKey('options') && (meta['options'] ?? '').trim().isNotEmpty) {
        final options = meta['options']!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meta['label']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                '${meta['type']} — ${meta['desc']}',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: controllers[k]!.text.isNotEmpty ? controllers[k]!.text : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  fillColor: Colors.white,
                  label: Text(meta['label']!),
                  filled: true,
                ),
                items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: (v) => controllers[k]!.text = v ?? '',
                dropdownColor: Colors.white,
                validator: (v) {
                  if (v == null || v.toString().trim().isEmpty) return 'Required';
                  return null;
                },
              ),
            ],
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meta['label']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              '${meta['type']} — ${meta['desc']}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controllers[k],
              keyboardType: meta['type'] == 'int'
                  ? TextInputType.number
                  : (meta['type'] == 'float'
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.text),
              inputFormatters: meta['type'] == 'int'
                  ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
                  : (meta['type'] == 'float'
                        ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                        : <TextInputFormatter>[]),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
                fillColor: Colors.white,
                filled: true,
                hintText: meta['type'] == 'string' ? 'e.g. good' : 'numeric value',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (meta['type'] == 'int') {
                  if (int.tryParse(v.trim()) == null) return 'Enter a valid integer';
                }
                if (meta['type'] == 'float') {
                  if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      );
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manual input for a single sample',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          // Three-column layout
          Row(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  spacing: 12,
                  children: List.generate(leftKeys.length, (index) {
                    final k = leftKeys[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == leftKeys.length - 1 ? 0 : 12),
                      child: buildField(k),
                    );
                  }),
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 12,
                  children: List.generate(middleKeys.length, (index) {
                    final k = middleKeys[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == middleKeys.length - 1 ? 0 : 12),
                      child: buildField(k),
                    );
                  }),
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 12,
                  children: List.generate(rightKeys.length, (index) {
                    final k = rightKeys[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == rightKeys.length - 1 ? 0 : 12),
                      child: buildField(k),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _submit(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  backgroundColor: Colors.grey.shade200,
                ),
                child: Text(
                  'Predict',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  for (final c in controllers.values) {
                    c.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  backgroundColor: Colors.grey.shade200,
                ),
                child: Text(
                  'Clear',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
