// filepath: lib/screens/rock_size_detection/rock_size_detection_screen.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/rock_size_detection_kpi/rock_detection_bloc.dart';
import '../../repositories/rock_size_detection_kpi/serializers/rock_image_response.dart';
import 'scanning_options/image_section_widget.dart';
import 'scanning_options/video_section_widget.dart';
import 'scanning_options/stream_section_widget.dart';

class RockSizeDetectionScreen extends StatefulWidget {
  const RockSizeDetectionScreen({super.key});

  @override
  State<RockSizeDetectionScreen> createState() => _RockSizeDetectionScreenState();
}

class _RockSizeDetectionScreenState extends State<RockSizeDetectionScreen> with WidgetsBindingObserver {
  int mode = 0; // 0: Image, 1: Video, 2: Stream
  PlatformFile? selectedFile;
  CameraController? cameraController;
  List<CameraDescription> availableCamerasOptions = [];
  CameraDescription? selectedCamera;
  bool streamActive = false;
  Uint8List? lastFrameBytes;
  bool cameraLoading = false;
  bool isSending = false;
  Timer? _sendTimer;
  final int sendIntervalMs = 500;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  Future<void> _initCameras() async {
    setState(() { cameraLoading = true; });
    try {
      final cameras = await availableCameras();
      setState(() { availableCamerasOptions = cameras; });
    } catch (e) {
      setState(() { availableCamerasOptions = []; });
    } finally {
      setState(() { cameraLoading = false; });
    }
  }

  Future<void> _initCameraController(CameraDescription camera) async {
    cameraController?.dispose();
    cameraController = CameraController(camera, ResolutionPreset.medium);
    try {
      await cameraController!.initialize();
      setState(() {});
    } catch (e) {
      // ignore
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? controller = cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed && selectedCamera != null) {
      _initCameraController(selectedCamera!);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    _sendTimer?.cancel();
    super.dispose();
  }

  void _pickFile() async {
    if (mode == 2) return;
    final result = await FilePicker.platform.pickFiles(
      type: mode == 0 ? FileType.image : FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() { selectedFile = result.files.first; });
      if (mode == 0) {
        context.read<RockDetectionBloc>().add(ScanImageEvent(selectedFile!, config: null));
      } else if (mode == 1) {
        context.read<RockDetectionBloc>().add(ScanVideoEvent(selectedFile!));
      }
    }
  }

  void _startStream() {
    if (selectedCamera == null) return;
    setState(() { streamActive = true; });
    context.read<RockDetectionBloc>().add(StartRockStreamEvent(sessionId: selectedCamera!.name));
  }

  void _stopStream() {
    setState(() { streamActive = false; });
    _stopSending();
    context.read<RockDetectionBloc>().add(StopRockStreamEvent());
  }

  void _startSending() {
    if (isSending || cameraController == null || !cameraController!.value.isInitialized) return;
    setState(() { isSending = true; });
    _sendTimer = Timer.periodic(Duration(milliseconds: sendIntervalMs), (timer) async {
      if (!isSending || cameraController == null || !cameraController!.value.isInitialized) return;
      try {
        final file = await cameraController!.takePicture();
        final bytes = await file.readAsBytes();
        lastFrameBytes = bytes;
        context.read<RockDetectionBloc>().add(SendRockFrameEvent({
          'message_type': 'frame',
          'frame_data': base64Encode(bytes),
          'frame_number': DateTime.now().millisecondsSinceEpoch,
          'timestamp': DateTime.now().millisecondsSinceEpoch / 1000.0,
        }));
        setState(() {});
      } catch (e) {
        // ignore
      }
    });
  }

  void _stopSending() {
    setState(() { isSending = false; });
    _sendTimer?.cancel();
    _sendTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Rock Size Detection KPI', style: GoogleFonts.poppins(fontSize: 54, fontWeight: FontWeight.w400)),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 70,
                    width: 450,
                    child: AnimatedToggleSwitch<int>.size(
                      current: mode,
                      values: const [0, 1, 2],
                      iconBuilder: (i) {
                        if (i == 0) return Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image, color: Colors.blue, size: 24), Text('Image', style: GoogleFonts.poppins(color: Colors.blue, fontSize: 18))]));
                        if (i == 1) return Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.videocam, color: Colors.green, size: 24), Text('Video', style: GoogleFonts.poppins(color: Colors.green, fontSize: 18))]));
                        return Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.wifi_tethering, color: Colors.deepOrange, size: 24), Text('Stream', style: GoogleFonts.poppins(color: Colors.deepOrange, fontSize: 18))]));
                      },
                      selectedIconScale: 1,
                      indicatorSize: const Size.fromWidth(200),
                      borderWidth: 6.0,
                      style: ToggleStyle(
                        borderColor: Colors.transparent,
                        backgroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(50.0),
                        boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 2, offset: Offset(0, 1.5))],
                      ),
                      styleBuilder: (i) => ToggleStyle(indicatorColor: i == 0 ? Colors.blue[100]! : i == 1 ? Colors.green[100]! : Colors.orange[100]!),
                      onChanged: (i) {
                        setState(() { mode = i; selectedFile = null; streamActive = false; selectedCamera = null; lastFrameBytes = null; });
                        if (i != 2) context.read<RockDetectionBloc>().add(StopRockStreamEvent());
                      },
                      iconOpacity: 0.7,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (mode == 0) RockImageSectionWidget(selectedFile: selectedFile, onPickFile: _pickFile),
              if (mode == 1) RockVideoSectionWidget(selectedFile: selectedFile, onPickFile: _pickFile),
              if (mode == 2) RockStreamSectionWidget(
                availableCameras: availableCamerasOptions,
                selectedCamera: selectedCamera,
                cameraController: cameraController,
                cameraLoading: cameraLoading,
                streamActive: streamActive,
                isSending: isSending,
                lastFrameBytes: lastFrameBytes,
                onStartStream: _startStream,
                onStopStream: _stopStream,
                onCameraChanged: (camera) {
                  setState(() { selectedCamera = camera; });
                  if (camera != null) _initCameraController(camera);
                },
                onStartSending: _startSending,
                onStopSending: _stopSending,
              ),
              const SizedBox(height: 18),
              BlocBuilder<RockDetectionBloc, RockDetectionState>(
                builder: (context, state) {
                  if (state is RockDetectionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RockDetectionError) {
                    return Center(child: Text('Error: ${state.message}', style: TextStyle(color: Colors.red)));
                  } else if (state is RockDetectionImageSuccess) {
                    final data = state.data;
                    final originalImageBytes = selectedFile?.bytes;
                    return SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Image Scan Result', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (originalImageBytes != null)
                                  Expanded(child: Column(children: [Text('Before (Original)', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(originalImageBytes, fit: BoxFit.contain, height: 300)) ])),
                                if (data.annotatedImageBase64 != null && data.annotatedImageBase64!.isNotEmpty)
                                  Expanded(child: Column(children: [Text('After (Annotated)', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode(data.annotatedImageBase64!), fit: BoxFit.contain, height: 300)) ])),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Detailed Report', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
                            const Divider(),
                            Text('Total Rocks: ${data.totalRocks}', style: GoogleFonts.poppins(fontSize: 16)),
                            Text('Percent Above Threshold: ${data.percentAbove}%', style: GoogleFonts.poppins(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Predictions:', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ...data.predictions.map((p) => Padding(padding: const EdgeInsets.symmetric(vertical: 6.0), child: Text('Length: ${p.lengthMm} mm — Above: ${p.isAboveThreshold} — BBox: ${p.bbox}', style: GoogleFonts.poppins(fontSize: 14)))),
                          ],
                        ),
                      ),
                    );
                  } else if (state is RockDetectionVideoSuccess) {
                    final data = state.data;
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
                              if (selectedFile != null) Row(children: [const Icon(Icons.videocam, size: 32), const SizedBox(width: 12), Expanded(child: Text(selectedFile!.name))]),
                              const SizedBox(height: 8),
                              Text('Detailed Report', style: Theme.of(context).textTheme.titleSmall),
                              const Divider(),
                              Text('Message: ${data.message}'),
                              Text('Size (bytes): ${data.size}'),
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
          ),
        ),
      ),
    );
  }
}

