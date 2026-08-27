import 'package:http/http.dart' as http;

/// Web stub â€” uses bytes (dart:io not available on web)
Future<http.MultipartFile> buildImageFile(
    String fieldName, dynamic xfile) async {
  final bytes = await xfile.readAsBytes() as List<int>;
  final filename = (xfile.name as String?) ?? 'profile.jpg';
  return http.MultipartFile.fromBytes(fieldName, bytes, filename: filename);
}
