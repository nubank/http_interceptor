import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_interceptor/extensions/extensions.dart';
import 'package:http_interceptor/http/http.dart';
import 'package:http_interceptor/utils/utils.dart';

/// A class that mimics HTTP Request in order to intercept it's data.
class RequestData {
  /// The HTTP method of the request.
  ///
  /// Most commonly "GET" or "POST", less commonly "HEAD", "PUT", or "DELETE".
  /// Non-standard method names are also supported.
  Method method;

  /// The base URL String to which the request will be sent. It does not include
  /// the query parameters.
  String baseUrl;

  /// Map of String to String that represents the headers of the request.
  Map<String, String> headers;

  /// Map of String to String that represents the query parameters of the
  /// request.
  Map<String, dynamic> params;

  dynamic body;

  Uint8List? bodyBytes;

  Map<String, String>? bodyFields;

  /// The encoding used for the request.
  Encoding? encoding;

  RequestData({
    required this.method,
    required this.baseUrl,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    this.encoding,
    this.body,
    this.bodyBytes,
    this.bodyFields,
  })  : headers = headers ?? {},
        params = params ?? {};

  /// The complete URL String including query parameters to which the request
  /// will be sent.
  String get url => buildUrlString(baseUrl, params);

  /// Creates a new request data from an HTTP request.
  ///
  /// For now it only supports [Request].
  /// TODO(codingalecr): Support for [MultipartRequest] and [StreamedRequest].
  factory RequestData.fromHttpRequest(BaseRequest request,
      [BodyType? bodyType]) {
    var params = Map<String, dynamic>();
    request.url.queryParametersAll.forEach((key, value) {
      params[key] = value;
    });
    String baseUrl = request.url.origin + request.url.path;

    if (request is Request) {
      final requestData = RequestData(
        method: methodFromString(request.method),
        baseUrl: baseUrl,
        headers: request.headers,
        encoding: request.encoding,
        params: params,
      );

      switch (bodyType) {
        case BodyType.string:
          print(
              'vovo - RequestData - fromHttpRequest - request.body.length = ${request.body.length}');

          requestData.body = request.body;
          print(
              'vovo - RequestData - fromHttpRequest - requestData.body?.length = ${requestData.body?.length}');

          break;
        case BodyType.list:
          print(
              'vovo - RequestData - fromHttpRequest - request.bodyBytes.length = ${request.bodyBytes.length}');

          requestData.bodyBytes = request.bodyBytes;
          print(
              'vovo - RequestData - fromHttpRequest - requestData.bodyBytes?.length = ${requestData.bodyBytes?.length}');

          break;
        case BodyType.map:
          requestData.bodyFields = request.bodyFields;
          break;
        default:
          break;
      }
      print(
          'vovo - RequestData - fromHttpRequest - requestData.encoding = ${requestData.encoding}');
      return requestData;
    }

    throw UnsupportedError(
      "Can't intercept ${request.runtimeType}. Request type not supported yet.",
    );
  }

  /// Converts this request data to an HTTP request.
  Request toHttpRequest() {
    var reqUrl = buildUrlString(baseUrl, params);

    Request request = new Request(methodToString(method), reqUrl.toUri());

    if (encoding != null) request.encoding = encoding!;

    print('vovo - RequestData - toHttpRequest - encoding = ${encoding}');
    print('vovo - RequestData - toHttpRequest - body = ${body}');
    print('vovo - RequestData - toHttpRequest - bodyBytes = ${bodyBytes}');
    if (body != null) {
      print('vovo - RequestData - toHttpRequest - body != NULL');
      if (body is String) {
        print('vovo - RequestData - toHttpRequest - body STRING');
        print('vovo - RequestData - toHttpRequest - body = ${body as String}');
        request.body = body as String;
        print(
            'vovo - RequestData - toHttpRequest - request.body = ${request.body}');
      } else if (body is List) {
        print('vovo - RequestData - toHttpRequest - body LIST');
        print(
            'vovo - RequestData - toHttpRequest - body = ${bodyBytes?.length}');
        request.bodyBytes = bodyBytes!;
        print(
            'vovo - RequestData - toHttpRequest - request.bodyBytes = ${request.bodyBytes}');
      } else if (body is Map) {
        print('vovo - RequestData - toHttpRequest - body MAP');
        request.bodyFields = bodyFields!;
      } else {
        throw new ArgumentError('Invalid request body "$body".');
      }
    } else if (bodyBytes != null) {
      print('vovo - RequestData - toHttpRequest - bodyBytes != null');
      if (bodyBytes is List) {
        print('vovo - RequestData - toHttpRequest - bodyBytes LIST');
        print(
            'vovo - RequestData - toHttpRequest - body = ${bodyBytes?.length}');
        request.bodyBytes = bodyBytes!;
        print(
            'vovo - RequestData - toHttpRequest - request.bodyBytes = ${request.bodyBytes}');
      } else {
        throw new ArgumentError('Invalid request bodyBytes "$bodyBytes".');
      }
    } else if (bodyFields != null) {
      print('vovo - RequestData - toHttpRequest - bodyFields != null');
      if (bodyFields is Map) {
        print('vovo - RequestData - toHttpRequest - bodyFields MAP');
        request.bodyFields = bodyFields!;
      } else {
        throw new ArgumentError('Invalid request bodyFields "$bodyFields".');
      }
    }

    request.headers.addAll(headers);
    print('vovo - RequestData - toHttpRequest - encoding = ${encoding}');
    return request;
  }

  /// Convenient toString implementation for logging.
  @override
  String toString() {
    return 'Request Data { $method, $baseUrl, $headers, $params, $body }';
  }
}
