import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

export 'package:dio/dio.dart';

/// Converts a [ui.Image] to a [MultipartFile].
///
/// This is used to convert the images to a format that can be sent
/// to the API.
Future<MultipartFile?> imageToMultiPartFile(
  ui.Image? image,
  String name,
  String? fileType,
) async {
  final bytes = await image?.toByteData(format: ui.ImageByteFormat.png);
  if (bytes != null) {
    final signatureData = bytes.buffer.asUint8List();
    return MultipartFile.fromBytes(
      signatureData,
      filename: name,
      contentType: MediaType('image', fileType ?? 'jpeg'),
    );
  }
  return null;
}

/// Converts a [XFile] to [MultipartFile]
Future<MultipartFile?> xFileToMultiPartFile({
  required XFile file,
  required String name,
}) async {
  final bytes = await file.readAsBytes();
  return MultipartFile.fromBytes(
    bytes,
    filename: name,
  );
}
