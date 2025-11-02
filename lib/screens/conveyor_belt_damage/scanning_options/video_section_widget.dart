import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/convery_belt_damage_kpi/conveyor_belt_damage_bloc.dart';

class ConveyorVideoSectionWidget extends StatelessWidget {
  final PlatformFile? selectedFile;
  final VoidCallback onPickFile;
  const ConveyorVideoSectionWidget({
    super.key,
    required this.selectedFile,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 50,
          child: FilledButton.icon(
            icon: const Icon(Icons.videocam),
            label: const Text('Upload Video'),
            onPressed: onPickFile,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        if (selectedFile != null)
          Container(
            margin: const EdgeInsets.only(top: 18),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam, size: 32),
                const SizedBox(width: 12),
                Text(selectedFile!.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        BlocBuilder<ConveyorBeltDamageBloc, ConveyorBeltDamageState>(
          builder: (context, state) {
            if (state is ConveyorBeltDamageLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ConveyorBeltDamageError) {
              return Center(child: Text('Error: ${state.message}', style: TextStyle(color: Colors.red)));
            } else if (state is ConveyorBeltDamageVideoSuccess) {
              final data = state.data; // ConveyorVideoResponse
              return SingleChildScrollView(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Video Scan Result:', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (selectedFile != null)
                          Row(
                            children: [
                              const Icon(Icons.videocam, size: 32),
                              const SizedBox(width: 12),
                              Expanded(child: Text(selectedFile!.name)),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Text('Detailed Report', style: Theme.of(context).textTheme.titleSmall),
                        const Divider(),
                        Text('Message: ${data.message}'),
                        Text('Size (bytes): ${data.size}'),
                        const SizedBox(height: 8),
                        Text(
                          'Note: This conveyor endpoint returns only a simple {message, size} payload. If you expect detailed video metadata (resolution, fps, frames, duration), update the API or serializer.',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
