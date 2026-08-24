// web_http_stub.dart â€” Stub for native platforms

Future<WebHttpResponse?> webPost(String url, Map<String, dynamic> body,
    Map<String, String> headers) async =>
    null;
Future<WebHttpResponse?> webGet(
    String url, Map<String, String> headers) async =>
    null;
Future<WebHttpResponse?> webPatch(String url, Map<String, dynamic> body,
    Map<String, String> headers) async =>
    null;
Future<WebHttpResponse?> webDelete(
    String url, Map<String, String> headers) async =>
    null;

class WebHttpResponse {
  final int statusCode;
  final String body;
  const WebHttpResponse(this.statusCode, this.body);
}
