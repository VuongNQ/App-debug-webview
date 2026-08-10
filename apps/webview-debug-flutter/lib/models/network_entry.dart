import 'package:flutter/foundation.dart';

enum NetworkEntryType {
  xhr,
  fetch,
  document,
  stylesheet,
  script,
  image,
  media,
  socket,
  other,
}

@immutable
class NetworkEntry {
  final int id;
  final String url;
  final String method;
  final Map<String, String> requestHeaders;
  final String? requestBody;
  final DateTime startTime;
  final DateTime? endTime;
  final int? statusCode;
  final Map<String, String> responseHeaders;
  final String? responseBodyPreview;
  final NetworkEntryType type;
  final int? contentLength;

  const NetworkEntry({
    required this.id,
    required this.url,
    required this.method,
    required this.requestHeaders,
    this.requestBody,
    required this.startTime,
    this.endTime,
    this.statusCode,
    this.responseHeaders = const {},
    this.responseBodyPreview,
    required this.type,
    this.contentLength,
  });

  Duration? get duration => endTime?.difference(startTime);

  NetworkEntry copyWith({
    DateTime? endTime,
    int? statusCode,
    Map<String, String>? responseHeaders,
    String? responseBodyPreview,
    int? contentLength,
  }) =>
      NetworkEntry(
        id: id,
        url: url,
        method: method,
        requestHeaders: requestHeaders,
        requestBody: requestBody,
        startTime: startTime,
        endTime: endTime ?? this.endTime,
        statusCode: statusCode ?? this.statusCode,
        responseHeaders: responseHeaders ?? this.responseHeaders,
        responseBodyPreview: responseBodyPreview ?? this.responseBodyPreview,
        type: type,
        contentLength: contentLength ?? this.contentLength,
      );
}
