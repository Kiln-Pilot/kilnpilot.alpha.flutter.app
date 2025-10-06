import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../blocs/thermal_kpi/thermal_kpi_bloc.dart';

class StreamSectionWidget extends StatefulWidget {
  final List<CameraDescription> availableCameras;
  final CameraDescription? selectedCamera;
  final CameraController? cameraController;
  final bool cameraLoading;
  final bool streamActive;
  final bool isSending;
  final Uint8List? lastFrameBytes;
  final VoidCallback onStartStream;
  final VoidCallback onStopStream;
  final ValueChanged<CameraDescription?> onCameraChanged;
  final VoidCallback onStartSending;
  final VoidCallback onStopSending;

  const StreamSectionWidget({
    super.key,
    required this.availableCameras,
    required this.selectedCamera,
    required this.cameraController,
    required this.cameraLoading,
    required this.streamActive,
    required this.isSending,
    required this.lastFrameBytes,
    required this.onStartStream,
    required this.onStopStream,
    required this.onCameraChanged,
    required this.onStartSending,
    required this.onStopSending,
  });

  @override
  State<StreamSectionWidget> createState() => _StreamSectionWidgetState();
}

class _StreamSectionWidgetState extends State<StreamSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stream mode selected. Choose camera and start stream.', style: GoogleFonts.poppins(fontSize: 18)),
          const SizedBox(height: 12),
          widget.cameraLoading
              ? const CircularProgressIndicator()
              : DropdownButtonHideUnderline(
                  child: DropdownButton2<CameraDescription>(
                    isExpanded: true,
                    customButton: Container(
                      height: 50,
                      width: 320,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.selectedCamera?.name ?? 'Select Camera',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 24),
                        ],
                      ),
                    ),
                    hint: Text(
                      'Select Camera',
                      style: GoogleFonts.poppins(fontSize: 16, color: Theme.of(context).hintColor),
                    ),
                    items: widget.availableCameras.map((camera) => DropdownMenuItem(
                      value: camera,
                      child: Text(camera.name, style: GoogleFonts.poppins(fontSize: 16)),
                    )).toList(),
                    value: widget.selectedCamera,
                    onChanged: widget.onCameraChanged,
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height: 40,
                      width: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
                        color: Colors.white,
                      ),
                    ),
                    dropdownStyleData: const DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors.white,
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40
                    ),
                  ),
                ),
          const SizedBox(height: 12),
          if (widget.cameraController != null && widget.cameraController!.value.isInitialized && !widget.cameraLoading && widget.streamActive)
            Container(
              height: 200,
              width: 320,
              child: CameraPreview(widget.cameraController!),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Stream'),
                onPressed: widget.streamActive || widget.selectedCamera == null ? null : widget.onStartStream,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                icon: const Icon(Icons.stop),
                label: const Text('Stop Stream'),
                onPressed: widget.streamActive ? widget.onStopStream : null,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                icon: Icon(widget.isSending ? Icons.pause : Icons.send),
                label: Text(widget.isSending ? 'Stop Sending' : 'Start Sending'),
                onPressed: widget.streamActive
                    ? (widget.isSending ? widget.onStopSending : widget.onStartSending)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.isSending ? Colors.orange : Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          // if (widget.lastFrameBytes != null && widget.streamActive)
          //   Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 12.0),
          //     child: ClipRRect(
          //       borderRadius: BorderRadius.circular(12),
          //       child: Image.memory(widget.lastFrameBytes!, fit: BoxFit.contain, height: 180),
          //     ),
          //   ),
          SizedBox(height: 18),
          BlocBuilder<ThermalKpiBloc, ThermalKpiState>(
            builder: (context, state) {
              if (state is ThermalStreamConnected) {
                return Text('Stream connected.', style: GoogleFonts.poppins(color: Colors.green, fontSize: 16));
              } else if (state is ThermalStreamDisconnected) {
                return Text('Stream disconnected.', style: GoogleFonts.poppins(color: Colors.red, fontSize: 16));
              } else if (state is ThermalStreamAnalysis) {
                final analysis = state.analysis;
                return Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Live Analysis Result:', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      if (analysis['annotated_image'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(analysis['annotated_image']),
                            fit: BoxFit.contain,
                            height: 180,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text('Status: ${analysis['status']}', style: GoogleFonts.poppins(fontSize: 16)),
                      if (analysis['analysis'] != null) ...[
                        Text('Alerts Created: ${analysis['alerts_created']}', style: GoogleFonts.poppins(fontSize: 16)),
                        Text('Frame Info: ${jsonEncode(analysis['frame_info'])}', style: GoogleFonts.poppins(fontSize: 16)),
                        Text('Analysis: ${jsonEncode(analysis['analysis'])}', style: GoogleFonts.poppins(fontSize: 16)),
                      ],
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
