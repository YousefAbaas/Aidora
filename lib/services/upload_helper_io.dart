import 'package:http/http.dart' as http;

/// Native implementation — uses dart:io File path for efficiency
Future<http.MultipartFile> buildImageFile(
    String fieldName, dynamic xfile) async {
  final path = xfile.path as String;
  // Use fromPath on native — more reliable than reading all bytes
  return http.MultipartFile.fromPath(fieldName, path);
}
