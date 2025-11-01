import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class EmissionPredictionBatchSectionWidget extends StatelessWidget {
  final PlatformFile? selectedFile;
  final VoidCallback onPick;
  final Map<String, Map<String, String>> featuresMeta;

  const EmissionPredictionBatchSectionWidget({super.key, required this.selectedFile, required this.onPick, required this.featuresMeta});

  @override
  Widget build(BuildContext context) {
    final keys = featuresMeta.keys.toList();
    final sampleHeader = keys.join(', ');

    final int total = keys.length;
    final int base = total ~/ 3;
    final int rem = total % 3;
    final int leftCount = base + (rem > 0 ? 1 : 0);
    final int middleCount = base + (rem > 1 ? 1 : 0);
    final leftKeys = keys.sublist(0, leftCount);
    final middleKeys = keys.sublist(leftCount, leftCount + middleCount);
    final rightKeys = keys.sublist(leftCount + middleCount, total);

    Widget buildItem(String key) {
      final meta = featuresMeta[key]!;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meta['label'] ?? '', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(meta['desc'] ?? '', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade800)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.upload_file, size: 28),
              label: Text('Choose file (CSV/XLSX)', style: GoogleFonts.poppins(fontSize: 18, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(width: 12),
            if (selectedFile != null) Expanded(child: Text('Selected: ${selectedFile!.name}', overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          color: Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  '$total Required attributes',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: leftKeys.map((k) => Padding(padding: const EdgeInsets.only(bottom: 12.0), child: buildItem(k))).toList())),
                    const SizedBox(width: 12),
                    // Column 2
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: middleKeys.map((k) => Padding(padding: const EdgeInsets.only(bottom: 12.0), child: buildItem(k))).toList())),
                    const SizedBox(width: 12),
                    // Column 3
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rightKeys.map((k) => Padding(padding: const EdgeInsets.only(bottom: 12.0), child: buildItem(k))).toList())),
                    const SizedBox(width: 12),
                    // Column 4: sample header and bullet list
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Sample CSV', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: sampleHeader));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV header copied to clipboard')));
                                  },
                                  icon: const Icon(Icons.copy),
                                  tooltip: 'Copy CSV header',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Header:', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                              child: Text(sampleHeader, style: GoogleFonts.robotoMono(fontSize: 12)),
                            ),
                            const SizedBox(height: 12),
                            Text('Attributes (bulleted):', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 260),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: keys.map((k) {
                                    final label = featuresMeta[k]?['label'] ?? k;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        const Text('• ', style: TextStyle(fontSize: 14)),
                                        Expanded(child: Text('$k — $label', style: GoogleFonts.poppins(fontSize: 13))),
                                      ]),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
