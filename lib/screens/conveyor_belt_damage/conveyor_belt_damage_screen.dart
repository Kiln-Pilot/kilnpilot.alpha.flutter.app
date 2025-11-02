import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/convery_belt_damage_kpi/conveyor_belt_damage_bloc.dart';
import 'scanning_options/image_section_widget.dart';
import 'scanning_options/video_section_widget.dart';
import 'scanning_options/stream_section_widget.dart';

class ConveyorBeltDamageScreen extends StatefulWidget {
  const ConveyorBeltDamageScreen({super.key});

  @override
  State<ConveyorBeltDamageScreen> createState() => _ConveyorBeltDamageScreenState();
}

class _ConveyorBeltDamageScreenState extends State<ConveyorBeltDamageScreen> with WidgetsBindingObserver {
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
      // Handle error
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
        context.read<ConveyorBeltDamageBloc>().add(ScanImageEvent(selectedFile!));
      } else if (mode == 1) {
        context.read<ConveyorBeltDamageBloc>().add(ScanVideoEvent(selectedFile!));
      }
    }
  }

  void _startStream() {
    if (selectedCamera == null) return;
    setState(() {
      streamActive = true;
    });
    context.read<ConveyorBeltDamageBloc>().add(StartConveyorStreamEvent(sessionId: selectedCamera!.name));
  }

  void _stopStream() {
    setState(() {
      streamActive = false;
    });
    _stopSending();
    context.read<ConveyorBeltDamageBloc>().add(StopConveyorStreamEvent());
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
        context.read<ConveyorBeltDamageBloc>().add(SendConveyorFrameEvent({
          'message_type': 'frame',
          'frame_data': base64Encode(bytes),
          'frame_number': DateTime.now().millisecondsSinceEpoch,
          'timestamp': DateTime.now().millisecondsSinceEpoch / 1000.0,
          'auto_alert': true,
          'alert_location': selectedCamera?.name ?? '',
        }));
        setState(() {});
      } catch (e) {
        // Handle capture error
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
                    child: Text(
                      'Conveyor Belt Damage KPI',
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
                          context.read<ConveyorBeltDamageBloc>().add(StopConveyorStreamEvent());
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
                ConveyorImageSectionWidget(
                  selectedFile: selectedFile,
                  onPickFile: _pickFile,
                ),
              if (mode == 1)
                ConveyorVideoSectionWidget(
                  selectedFile: selectedFile,
                  onPickFile: _pickFile,
                ),
              if (mode == 2)
                ConveyorStreamSectionWidget(
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
              BlocBuilder<ConveyorBeltDamageBloc, ConveyorBeltDamageState>(
                builder: (context, state) {
                  if (state is ConveyorBeltDamageLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ConveyorBeltDamageError) {
                    return Center(
                      child: Text('Error: ${state.message}', style: TextStyle(color: Colors.red)),
                    );
                  } else if (state is ConveyorBeltDamageImageSuccess) {
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
                                if (data.annotatedImageBase64.isNotEmpty)
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
                                            base64Decode(data.annotatedImageBase64),
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
                  } else if (state is ConveyorBeltDamageVideoSuccess) {
                    final data = state.data; // ConveyorVideoResponse with `message` and `size`
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
                              // The backend for conveyor returns a simple { message, size } payload.
                              Text('Message: ${data.message}'),
                              Text('Size (bytes): ${data.size}'),
                              const SizedBox(height: 8),
                              Text(
                                'Note: video metadata (resolution, fps, frames, duration) is not provided by the conveyor endpoint serializer. If you need those fields, update the backend or the serializer.',
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (state is ConveyorStreamConnected) {
                    return Text('Stream connected.', style: GoogleFonts.poppins(color: Colors.green, fontSize: 16));
                  } else if (state is ConveyorStreamDisconnected) {
                    return Text('Stream disconnected.', style: GoogleFonts.poppins(color: Colors.red, fontSize: 16));
                  } else if (state is ConveyorStreamAnalysis) {
                    final analysis = state.analysis;
                    return Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Live Analysis Result:', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          if (analysis.annotatedImageBase64 != null && analysis.annotatedImageBase64!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                base64Decode(analysis.annotatedImageBase64!),
                                fit: BoxFit.contain,
                                height: 180,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text('Status: ${analysis.status}', style: GoogleFonts.poppins(fontSize: 16)),
                          if (analysis.analysis != null) ...[
                            Text('Alerts Created: ${analysis.alertsCreated ?? 0}', style: GoogleFonts.poppins(fontSize: 16)),
                            Text('Frame Info: ${jsonEncode(analysis.frameInfo)}', style: GoogleFonts.poppins(fontSize: 16)),
                            Text('Analysis: ${jsonEncode(analysis.analysis)}', style: GoogleFonts.poppins(fontSize: 16)),
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
        ),
      ),
    );
  }
}
