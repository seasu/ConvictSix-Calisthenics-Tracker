import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// The camera image format this feature requests on each platform — chosen
/// so the raw bytes ML Kit expects don't need any pixel-format conversion,
/// only plane concatenation. Use this when constructing the
/// [CameraController] (`imageFormatGroup: motionLabImageFormatGroup`).
final ImageFormatGroup motionLabImageFormatGroup =
    defaultTargetPlatform == TargetPlatform.android
        ? ImageFormatGroup.nv21
        : ImageFormatGroup.bgra8888;

/// Converts a live camera frame into the [InputImage] format ML Kit's pose
/// detector expects.
///
/// This assumes the screen is locked to portrait (see
/// [MotionLabScreen]/`SystemChrome.setPreferredOrientations`) so
/// [CameraDescription.sensorOrientation] alone determines the rotation,
/// without needing to add a device-orientation delta on top. This function
/// is the one place in the feature that talks directly to platform-specific
/// camera buffer layouts — it can only be verified by actually running the
/// camera on a real device, not in this sandbox.
InputImage? inputImageFromCameraImage(
  CameraImage image,
  CameraDescription camera,
) {
  final rotation =
      InputImageRotationValue.fromRawValue(camera.sensorOrientation);
  if (rotation == null) return null;

  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null) return null;

  final allBytes = WriteBuffer();
  for (final plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    ),
  );
}
