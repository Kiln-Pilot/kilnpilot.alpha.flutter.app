import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/thermal_kpi/thermal_kpi_bloc.dart';
import 'scanning_options/image_section_widget.dart';
import 'scanning_options/video_section_widget.dart';
import 'scanning_options/stream_section_widget.dart';

class KilnTemperatureScreen extends StatefulWidget {
  const KilnTemperatureScreen({super.key});

  @override
  State<KilnTemperatureScreen> createState() => _KilnTemperatureScreenState();
}

class _KilnTemperatureScreenState extends State<KilnTemperatureScreen> with WidgetsBindingObserver {
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
    context.read<ThermalKpiBloc>().add(FetchThermalConfigEvent());
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
      // Handle camera errors
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
        context.read<ThermalKpiBloc>().add(ScanImageEvent(selectedFile!));
      } else if (mode == 1) {
        context.read<ThermalKpiBloc>().add(ScanVideoEvent(selectedFile!));
      }
    }
  }

  void _startStream() {
    if (selectedCamera == null) return;
    setState(() {
      streamActive = true;
    });
    context.read<ThermalKpiBloc>().add(StartThermalStreamEvent(sessionId: selectedCamera!.name));
  }

  void _stopStream() {
    setState(() {
      streamActive = false;
    });
    _stopSending();
    context.read<ThermalKpiBloc>().add(StopThermalStreamEvent());
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
        context.read<ThermalKpiBloc>().add(SendThermalFrameEvent({
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

  Future<void> _sendCameraFrame() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return;
    try {
      final file = await cameraController!.takePicture();
      final bytes = await file.readAsBytes();
      lastFrameBytes = bytes;
      context.read<ThermalKpiBloc>().add(
        SendThermalFrameEvent({
          'message_type': 'frame',
          'frame_data': base64Encode(bytes),
          'frame_number': DateTime.now().millisecondsSinceEpoch,
          'timestamp': DateTime.now().millisecondsSinceEpoch / 1000.0,
          'auto_alert': true,
          'alert_location': selectedCamera?.name ?? '',
        }),
      );
      setState(() {});
    } catch (e) {
      // Handle capture error
    }
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
                      'Kiln Temperature KPI',
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
                          context.read<ThermalKpiBloc>().add(StopThermalStreamEvent());
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
                ImageSectionWidget(
                  selectedFile: selectedFile,
                  onPickFile: _pickFile,
                ),
              if (mode == 1)
                VideoSectionWidget(
                  selectedFile: selectedFile,
                  onPickFile: _pickFile,
                ),
              if (mode == 2)
                StreamSectionWidget(
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
              BlocBuilder<ThermalKpiBloc, ThermalKpiState>(
                builder: (context, state) {
                  if (state is ThermalKpiLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ThermalKpiError) {
                    return Center(
                      child: Text('Error: ${state.message}', style: TextStyle(color: Colors.red)),
                    );
                  } else if (state is ThermalKpiImageSuccess) {
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
                                if (data.annotatedImage != null)
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
                                            base64Decode(data.annotatedImage!),
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
                            Text('Status: ${data.status}', style: GoogleFonts.poppins(fontSize: 16)),
                            if (data.analysis != null) ...[
                              Text(
                                'Total Detections: ${data.analysis!.totalDetections}',
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                              Text(
                                'High Temp Count: ${data.analysis!.highTemperatureCount}',
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                              Text(
                                'Max Temp: ${data.analysis!.maxTemperature}',
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                              Text(
                                'Min Temp: ${data.analysis!.minTemperature}',
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text('Detections:', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
                              SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: data.analysis!.detections.length,
                                  itemBuilder: (context, idx) {
                                    final det = data.analysis!.detections[idx];
                                    return ListTile(
                                      dense: true,
                                      title: Text('Detection #${det.detectionId}'),
                                      subtitle: Text(
                                        'Temp: ${det.temperature}, High: ${det.isHighTemperature}, Area: ${det.area}, Box: (${det.boundingBox.x},${det.boundingBox.y},${det.boundingBox.width},${det.boundingBox.height})',
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  } else if (state is ThermalKpiVideoSuccess) {
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
                              if (selectedFile != null)
                                Row(
                                  children: [
                                    Icon(Icons.videocam, size: 32),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(selectedFile!.name)),
                                  ],
                                ),
                              const SizedBox(height: 8),
                              Text('Detailed Report', style: Theme.of(context).textTheme.titleSmall),
                              const Divider(),
                              Text('Status: ${data.status}'),
                              if (data.videoInfo != null) ...[
                                Text('Resolution: ${data.videoInfo!.width}x${data.videoInfo!.height}'),
                                Text('FPS: ${data.videoInfo!.fps}'),
                                Text('Frames: ${data.videoInfo!.totalFrames}'),
                                Text('Duration: ${data.videoInfo!.duration}s'),
                              ],
                              if (data.analysis != null) ...[
                                Text('Total Detections: ${data.analysis!.totalDetections}'),
                                Text('High Temp Detections: ${data.analysis!.totalHighTemperatureDetections}'),
                                Text('Max Temp: ${data.analysis!.maxTemperature}'),
                                Text('Min Temp: ${data.analysis!.minTemperature}'),
                                const SizedBox(height: 8),
                                ExpansionTile(
                                  title: Text('Per-frame Details'),
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: data.analysis!.frames.length,
                                      itemBuilder: (context, idx) {
                                        final frame = data.analysis!.frames[idx];
                                        return ExpansionTile(
                                          title: Text('Frame #${frame.frameNumber} (t=${frame.timestamp}s)'),
                                          subtitle: Text(
                                            'Max Temp: ${frame.maxTemperature}, High Temp Count: ${frame.highTemperatureCount}',
                                          ),
                                          children: [
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: frame.detections.length,
                                              itemBuilder: (context, didx) {
                                                final det = frame.detections[didx];
                                                return ListTile(
                                                  dense: true,
                                                  title: Text('Detection #${det.detectionId}'),
                                                  subtitle: Text(
                                                    'Temp: ${det.temperature}, High: ${det.isHighTemperature}, Area: ${det.area}, Box: (${det.boundingBox.x},${det.boundingBox.y},${det.boundingBox.width},${det.boundingBox.height})',
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (state is ThermalKpiConfigSuccess) {
                    final config = state.data;
                    return Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thermal Screening Config:', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Threshold: ${config.threshold}'),
                          Text('Area of Box: ${config.areaOfBox}'),
                          Text('Min Temp: ${config.minTemp}'),
                        ],
                      ),
                    );
                  } else if (state is ThermalKpiSupportedFormatsSuccess) {
                    final formats = state.data;
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Supported Formats:', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text('Formats: ${formats.supportedFormats}'),
                          ],
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
