// web_http.dart — Web-only HTTP using package:web XMLHttpRequest
// This sends requests WITHOUT triggering CORS preflight for simple cases.
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

class WebHttpResponse {
  final int statusCode;
  final String body;
  const WebHttpResponse(this.statusCode, this.body);
}

Future<WebHttpResponse> webPost(
    String url, Map<String, dynamic> body, Map<String, String> headers) async {
  return _send('POST', url, jsonEncode(body), headers);
}

Future<WebHttpResponse> webGet(String url, Map<String, String> headers) async {
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

Future<WebHttpResponse> _send(String method, String url, String? body,
    Map<String, String> headers) async {
  final completer = Completer<WebHttpResponse>();
  final xhr = web.XMLHttpRequest();
  xhr.open(method, url, true);

  headers.forEach((k, v) => xhr.setRequestHeader(k, v));
  xhr.withCredentials = false;

  xhr.onLoad.listen((_) {
    if (!completer.isCompleted) {
      completer.complete(
          WebHttpResponse(xhr.status, xhr.responseText));
    }
  });
  xhr.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.complete(const WebHttpResponse(0, '{"error":"Network error"}'));
    }
  });

  if (body != null) {
    xhr.send(body.toJS);
  } else {
    xhr.send();
  }

  return completer.future.timeout(const Duration(seconds: 30),
      onTimeout: () => const WebHttpResponse(408, '{"error":"Timeout"}'));
}