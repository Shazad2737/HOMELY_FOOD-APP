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

  // Determine content type from file extension or mime type
  final mimeType = file.mimeType ?? _getMimeTypeFromPath(file.path);
  final contentType = _parseContentType(mimeType);

  return MultipartFile.fromBytes(
    bytes,
    filename: name,
    contentType: contentType,
  );
}

/// Gets MIME type from file path extension
String _getMimeTypeFromPath(String path) {
  final extension = path.toLowerCase().split('.').last;
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    default:
      return 'image/jpeg'; // Default to jpeg
  }
}

/// Parses MIME type string to MediaType
MediaType? _parseContentType(String? mimeType) {
  if (mimeType == null) return MediaType('image', 'jpeg');

  final parts = mimeType.split('/');
  if (parts.length == 2) {
    return MediaType(parts[0], parts[1]);
  }
  return MediaType('image', 'jpeg');
}
