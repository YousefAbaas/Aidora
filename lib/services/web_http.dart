// web_http.dart — Web-only HTTP using dart:html XmlHttpRequest
// This sends requests WITHOUT triggering CORS preflight for simple cases.
// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

class WebHttpResponse {
  final int statusCode;
  final String body;
  const WebHttpResponse(this.statusCode, this.body);
}

Future<WebHttpResponse> webPost(
    String url, Map<String, dynamic> body, Map<String, String> headers) async {
  return _send('POST', url, jsonEncode(body), headers);
}

Future<WebHttpResponse> webGet(
    String url, Map<String, String> headers) async {
  return _send('GET', url, null, headers);
}

Future<WebHttpResponse> webPatch(
    String url, Map<String, dynamic> body, Map<String, String> headers) async {
  return _send('PATCH', url, jsonEncode(body), headers);
}

Future<WebHttpResponse> webDelete(
    String url, Map<String, String> headers) async {
  return _send('DELETE', url, null, headers);
}

Future<WebHttpResponse> _send(
    String method, String url, String? body, Map<String, String> headers) async {
  final completer = Completer<WebHttpResponse>();
  final xhr = html.HttpRequest()
    ..open(method, url, async: true);

  headers.forEach((k, v) => xhr.setRequestHeader(k, v));
  // Allow cross-origin credentials (cookies/auth)
  xhr.withCredentials = false;

  xhr.onLoad.first.then((_) {
    completer.complete(WebHttpResponse(xhr.status ?? 0, xhr.responseText ?? ''));
  });
  xhr.onError.first.then((_) {
    completer.complete(WebHttpResponse(0, '{"error":"Network error"}'));
  });
  xhr.onTimeout.first.then((_) {
    completer.complete(WebHttpResponse(408, '{"error":"Timeout"}'));
  });

  if (body != null) {
    xhr.send(body);
  } else {
    xhr.send();
  }

  return completer.future.timeout(const Duration(seconds: 30),
      onTimeout: () => const WebHttpResponse(408, '{"error":"Timeout"}'));
}
