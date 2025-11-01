// filepath: lib/screens/ppe_detection/ppe_detection_screen.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/ppe_detection_kpi/ppe_detection_bloc.dart';
import '../../repositories/ppe_detection_kpi/serializers/ppe_image_response.dart';
import 'scanning_options/image_section_widget.dart';
import 'scanning_options/video_section_widget.dart';
import 'scanning_options/stream_section_widget.dart';

class PpeDetectionScreen extends StatefulWidget {
  const PpeDetectionScreen({super.key});

  @override
  State<PpeDetectionScreen> createState() => _PpeDetectionScreenState();
}

class _PpeDetectionScreenState extends State<PpeDetectionScreen> with WidgetsBindingObserver {
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
    setState(() {
      cameraLoading = true;
    });
    try {
      final cameras = await availableCameras();
      setState(() {
        availableCamerasOptions = cameras;
      });
    } catch (e) {
      setState(() {
        availableCamerasOptions = [];
      });
    } finally {
      setState(() {
        cameraLoading = false;
      });
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
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
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
      setState(() {
        selectedFile = result.files.first;
      });
      if (mode == 0) {
        context.read<PpeDetectionBloc>().add(ScanImageEvent(selectedFile!));
      } else if (mode == 1) {
        context.read<PpeDetectionBloc>().add(ScanVideoEvent(selectedFile!));
      }
    }
  }

  void _startStream() {
    if (selectedCamera == null) return;
    setState(() {
      streamActive = true;
    });
    context.read<PpeDetectionBloc>().add(StartPpeStreamEvent(sessionId: selectedCamera!.name));
  }

  void _stopStream() {
    setState(() {
      streamActive = false;
    });
    _stopSending();
    context.read<PpeDetectionBloc>().add(StopPpeStreamEvent());
  }

  void _startSending() {
    if (isSending || cameraController == null || !cameraController!.value.isInitialized) return;
    setState(() {
      isSending = true;
    });
    _sendTimer = Timer.periodic(Duration(milliseconds: sendIntervalMs), (timer) async {
      if (!isSending || cameraController == null || !cameraController!.value.isInitialized) return;
      try {
        final file = await cameraController!.takePicture();
        final bytes = await file.readAsBytes();
        lastFrameBytes = bytes;
        context.read<PpeDetectionBloc>().add(SendPpeFrameEvent({
          'message_type': 'frame',
          'frame_data': base64Encode(bytes),
          'frame_number': DateTime.now().millisecondsSinceEpoch,
          'timestamp': DateTime.now().millisecondsSinceEpoch / 1000.0,
          'auto_alert': true,
          'alert_location': selectedCamera?.name ?? '',
        }));
        setState(() {});
      } catch (e) {
        // ignore
      }
    });
  }

  void _stopSending() {
    setState(() {
      isSending = false;
    });
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
                    child: Text(
                      'PPE Detection KPI',
                      style: GoogleFonts.poppins(fontSize: 54, fontWeight: FontWeight.w400),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 70,
                    width: 450,
                    child: AnimatedToggleSwitch<int>.size(
                      current: mode,
                      values: const [0, 1, 2],
                      iconBuilder: (i) {
                        if (i == 0) {
                          return Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, color: Colors.blue, size: 24),
                                Text('Image', style: GoogleFonts.poppins(color: Colors.blue, fontSize: 18)),
                              ],
                            ),
                          );
                        }
                        if (i == 1) {
                          return Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.videocam, color: Colors.green, size: 24),
                                Text('Video', style: GoogleFonts.poppins(color: Colors.green, fontSize: 18)),
                              ],
                            ),
                          );
                        }
                        return Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wifi_tethering, color: Colors.deepOrange, size: 24),
                              Text('Stream', style: GoogleFonts.poppins(color: Colors.deepOrange, fontSize: 18)),
                            ],
                          ),
                        );
                      },
                      selectedIconScale: 1,
                      indicatorSize: const Size.fromWidth(200),
                      borderWidth: 6.0,
                      style: ToggleStyle(
                        borderColor: Colors.transparent,
                        backgroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(50.0),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 2, offset: Offset(0, 1.5)),
                        ],
                      ),
                      styleBuilder: (i) => ToggleStyle(
                        indicatorColor: i == 0
                            ? Colors.blue[100]!
                            : i == 1
                                ? Colors.green[100]!
                                : Colors.orange[100]!,
                      ),
                      onChanged: (i) {
                        setState(() {
                          mode = i;
                          selectedFile = null;
                          streamActive = false;
                          selectedCamera = null;
                          lastFrameBytes = null;
                        });
                        if (i != 2) {
                          context.read<PpeDetectionBloc>().add(StopPpeStreamEvent());
                        }
                      },
                      iconOpacity: 0.7,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (mode == 0)
                PpeImageSectionWidget(
                  selectedFile: selectedFile,
                  onPickFile: _pickFile,
                ),
              if (mode == 1)
                PpeVideoSectionWidget(
                  selectedFile: selectedFile,
                  onPickFile: _pickFile,
                ),
              if (mode == 2)
                PpeStreamSectionWidget(
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
                    setState(() {
                      selectedCamera = camera;
                    });
                    if (camera != null) _initCameraController(camera);
                  },
                  onStartSending: _startSending,
                  onStopSending: _stopSending,
                ),
              const SizedBox(height: 18),
              BlocBuilder<PpeDetectionBloc, PpeDetectionState>(
                builder: (context, state) {
                  if (state is PpeDetectionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PpeDetectionError) {
                    return Center(
                      child: Text('Error: ${state.message}', style: TextStyle(color: Colors.red)),
                    );
                  } else if (state is PpeDetectionImageSuccess) {
                    final data = state.data;
                    final originalImageBytes = selectedFile?.bytes;
                    return SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Image Scan Result',
                              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (originalImageBytes != null)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Before (Original)',
                                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.memory(originalImageBytes, fit: BoxFit.contain, height: 300),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (data.annotatedImageBase64!=null)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          'After (Annotated)',
                                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.memory(
                                            base64Decode(data.annotatedImageBase64!),
                                            fit: BoxFit.contain,
                                            height: 300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Detailed Report',
                              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
                            ),
                            const Divider(),
                            Text('Alerts Created: ${data.alertsCreated}', style: GoogleFonts.poppins(fontSize: 16)),
                            if (data.analysis != null) ...[
                              Text('Analysis: ${data.analysis}', style: GoogleFonts.poppins(fontSize: 16)),
                            ],
                          ],
                        ),
                      ),
                    );
                  } else if (state is PpeDetectionVideoSuccess) {
                    final data = state.data; // PpeVideoResponse with `message` and `size`
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
                              // The backend for PPE returns a simple { message, size } payload for video uploads.
                              Text('Message: ${data.message}'),
                              Text('Size (bytes): ${data.size}'),
                              const SizedBox(height: 8),
                              Text(
                                'Note: video metadata (resolution, fps, frames, duration) is not provided by the PPE endpoint serializer. If you need those fields, update the backend or the serializer.',
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
          ),
        ),
      ),
    );
  }
}

