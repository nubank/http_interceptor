import 'dart:math';

import 'package:test/test.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http/http.dart';
import 'package:http_interceptor/models/request_data.dart';

main() {
  group("Initialization: ", () {
    test("can be instantiated", () {
      // Arrange
      RequestData requestData;

      // Act
      requestData = RequestData(
          method: Method.GET, baseUrl: "https://www.google.com/helloworld");

      // Assert
      expect(requestData, isNotNull);
    });
    test("can be instantiated from HTTP GET Request", () {
      // Arrange
      Uri url = Uri.parse("https://www.google.com/helloworld");

      Request request = Request("GET", url);
      RequestData requestData;

      // Act
      requestData = RequestData.fromHttpRequest(request);

      // Assert
      expect(requestData, isNotNull);
      expect(requestData.method, equals(Method.GET));
      expect(requestData.url, equals("https://www.google.com/helloworld"));
    });
    test("can be instantiated from HTTP GET Request with long path", () {
      // Arrange
      Uri url = Uri.parse("https://www.google.com/helloworld/foo/bar");

      Request request = Request("GET", url);
      RequestData requestData;

      // Act
      requestData = RequestData.fromHttpRequest(request);

      // Assert
      expect(requestData, isNotNull);
      expect(requestData.method, equals(Method.GET));
      expect(
          requestData.url, equals("https://www.google.com/helloworld/foo/bar"));
    });
    test("can be instantiated from HTTP GET Request with parameters", () {
      // Arrange
      Uri url = Uri.parse(
          "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3");

      Request request = Request("GET", url);
      RequestData requestData;

      // Act
      requestData = RequestData.fromHttpRequest(request);

      // Assert
      expect(requestData, isNotNull);
      expect(requestData.method, equals(Method.GET));
      expect(requestData.baseUrl, equals("https://www.google.com/helloworld"));
      expect(
          requestData.url,
          equals(
              "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3"));
    });
    test(
        "can be instantiated from HTTP GET Request with multiple parameters with same key",
        () {
      // Arrange
      Uri url = Uri.parse(
          "https://www.google.com/helloworld?name=Hugo&type=2&type=3&type=4");

      Request request = Request("GET", url);
      RequestData requestData;

      // Act
      requestData = RequestData.fromHttpRequest(request);

      // Assert
      expect(
          requestData.url,
          equals(
              "https://www.google.com/helloworld?name=Hugo&type=2&type=3&type=4"));
    });
    test("can be instatiated from HTTP PUT Request with body", () {
      // Arrange
      Uri url = Uri.parse(
          "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3");

      Request request = Request("PUT", url);
      request.body = 'a body';
      RequestData requestData;

      // Act
      requestData = RequestData.fromHttpRequest(request, BodyType.string);

      // Assert
      expect(requestData, isNotNull);
      expect(requestData.body, isNotNull);
      expect(requestData.bodyBytes, isNull);
      expect(requestData.bodyFields, isNull);
      expect(requestData.method, equals(Method.PUT));
      expect(
          requestData.url,
          equals(
              "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3"));
    });
  });
  test("can be instatiated from HTTP PUT Request with bodyBytes", () {
    // Arrange
    Uri url = Uri.parse(
        "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3");

    Request request = Request("PUT", url);
    request.bodyBytes = [1, 2, 3];
    RequestData requestData;

    // Act
    requestData = RequestData.fromHttpRequest(request, BodyType.list);

    // Assert
    expect(requestData, isNotNull);
    expect(requestData.body, isNull);
    expect(requestData.bodyBytes, equals([1, 2, 3]));
    expect(requestData.bodyFields, isNull);
    expect(requestData.method, equals(Method.PUT));
    expect(
        requestData.url,
        equals(
            "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3"));
  });
  test("can be instatiated from HTTP PUT Request with bodyFields", () {
    // Arrange
    Uri url = Uri.parse(
        "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3");

    Request request = Request("PUT", url);
    request.bodyFields = {'field': 'value'};
    RequestData requestData;

    // Act
    requestData = RequestData.fromHttpRequest(request, BodyType.map);

    // Assert
    expect(requestData, isNotNull);
    expect(requestData.body, isNull);
    expect(requestData.bodyBytes, isNull);
    expect(requestData.bodyFields, equals({'field': 'value'}));
    expect(requestData.method, equals(Method.PUT));
    expect(
        requestData.url,
        equals(
            "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3"));
  });
  test("correctly creates the request URL string", () {
    // Arrange
    Uri url = Uri.parse(
        "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3");

    Request request = Request("GET", url);
    RequestData requestData;

    // Act
    requestData = RequestData.fromHttpRequest(request);

    // Assert
    expect(requestData, isNotNull);
    expect(requestData.method, equals(Method.GET));
    expect(
        requestData.url,
        equals(
            "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3"));
  });
  test("can be instatiated from a request with a body", () {
    // Arrange
    Uri url = Uri.parse(
        "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3");

    Request request = Request("GET", url);
    request.body = 'a body';
    RequestData requestData;

    // Act
    requestData = RequestData.fromHttpRequest(request);

    // Assert
    expect(requestData, isNotNull);
    expect(requestData.body, isNotNull);
    expect(requestData.bodyBytes, isNull);
    expect(requestData.bodyFields, isNull);
    expect(requestData.method, equals(Method.GET));
    expect(
        requestData.url,
        equals(
            "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3"));
  });
}
