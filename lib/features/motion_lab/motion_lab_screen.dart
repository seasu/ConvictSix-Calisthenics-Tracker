import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'
    as mlkit;

import '../../shared/theme/app_theme.dart';
import 'camera/input_image_converter.dart';
import 'camera/pose_frame_adapter.dart';
import 'detection/hysteresis_rep_counter.dart';
import 'detection/motion_lab_exercise.dart';
import 'detection/pose_frame.dart';
import 'pose_painter.dart';

/// An experimental, self-contained screen for validating whether on-device
/// ML Kit pose detection can reliably count reps for the 6 candidate
/// exercises in [MotionLabExercise]. Deliberately disconnected from the
/// rest of the app: it does not read or write any workout session/history
/// data, has no Riverpod provider, and keeps no state once the screen is
/// closed — see CLAUDE.md's motion-lab section for why.
///
/// Rotation/coordinate handling here assumes the device stays portrait-
/// locked with the front camera — the one configuration this screen has
/// been written for. It has not been verified against real hardware (no
/// camera in the dev sandbox this was built in); expect to revisit
/// [inputImageFromCameraImage] and [PosePainter]'s coordinate mapping after
/// the first on-device test.
class MotionLabScreen extends StatefulWidget {
  const MotionLabScreen({super.key});

  @override
  State<MotionLabScreen> createState() => _MotionLabScreenState();
}

class _MotionLabScreenState extends State<MotionLabScreen> {
  CameraController? _controller;
  final _poseDetector = mlkit.PoseDetector(
    options: mlkit.PoseDetectorOptions(mode: mlkit.PoseDetectionMode.stream),
  );

  MotionLabExercise _exercise = MotionLabExercise.squat;
  HysteresisRepCounter _counter = _newCounter(MotionLabExercise.squat);

  PoseFrame _lastFrame = const {};
  Size _lastImageSize = Size.zero;
  bool _isDetecting = false;
  String? _errorMessage;

  static HysteresisRepCounter _newCounter(MotionLabExercise exercise) {
    return HysteresisRepCounter(
      detector: exercise.detector,
      upThreshold: exercise.upThreshold,
      downThreshold: exercise.downThreshold,
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: motionLabImageFormatGroup,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
      await controller.startImageStream(_onFrame);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = '無法開啟相機：${e.description ?? e.code}');
    }
  }

  void _onFrame(CameraImage image) {
    if (_isDetecting) return;
    _isDetecting = true;
    _processFrame(image).whenComplete(() => _isDetecting = false);
  }

  Future<void> _processFrame(CameraImage image) async {
    final controller = _controller;
    if (controller == null) return;
    final inputImage = inputImageFromCameraImage(image, controller.description);
    if (inputImage == null) return;

    final poses = await _poseDetector.processImage(inputImage);
    if (!mounted || poses.isEmpty) return;

    final frame = poseFrameFrom(poses.first);
    _counter.onFrame(frame);

    setState(() {
      _lastFrame = frame;
      _lastImageSize = Size(image.width.toDouble(), image.height.toDouble());
    });
  }

  void _selectExercise(MotionLabExercise exercise) {
    setState(() {
      _exercise = exercise;
      _counter = _newCounter(exercise);
      _lastFrame = const {};
    });
  }

  void _resetCount() {
    setState(() => _counter = _newCounter(_exercise));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _controller?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('動作偵測實驗室'),
        actions: [
          IconButton(
            onPressed: _resetCount,
            icon: const Icon(Icons.refresh),
            tooltip: '重置計數',
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: MotionLabExercise.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final exercise = MotionLabExercise.values[index];
                final selected = exercise == _exercise;
                return ChoiceChip(
                  label: Text(exercise.nameZh),
                  selected: selected,
                  onSelected: (_) => _selectExercise(exercise),
                  selectedColor: kPrimary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : kTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            color: kBgSurface2,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: const Text(
              '⚠️ 實驗性功能：僅用於驗證鏡頭動作偵測，不會寫入正式訓練紀錄',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: kTextTertiary),
            ),
          ),
          Expanded(
            child: _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  )
                : (controller == null || !controller.value.isInitialized)
                    ? const Center(
                        child: CircularProgressIndicator(color: kPrimary),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraPreview(controller),
                          CustomPaint(
                            painter: PosePainter(
                              frame: _lastFrame,
                              imageSize: _lastImageSize,
                              mirror: controller.description.lensDirection ==
                                  CameraLensDirection.front,
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: kBgSurface3.withAlpha(220),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${_counter.reps}',
                                  style: theme.textTheme.displaySmall,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
