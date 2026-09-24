import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  // Initialize and load saved token
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('vrs_access_token');
      _refreshToken = prefs.getString('vrs_refresh_token');
    } catch (_) {
      // Platform channels might not be ready in pure testing, keep in memory
    }
  }

  Future<void> setTokens({required String accessToken, String? refreshToken}) async {
    _accessToken = accessToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      _refreshToken = refreshToken;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vrs_access_token', accessToken);
      if (_refreshToken != null && _refreshToken!.isNotEmpty) {
        await prefs.setString('vrs_refresh_token', _refreshToken!);
      }
    } catch (_) {}
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('vrs_access_token');
      await prefs.remove('vrs_refresh_token');
    } catch (_) {}
  }

  Completer<bool>? _refreshCompleter;

  bool _isAuthEndpoint(String endpoint) {
    return endpoint.contains(ApiConstants.login) ||
        endpoint.contains(ApiConstants.verifyOtp) ||
        endpoint.contains(ApiConstants.sendOtp) ||
        endpoint.contains(ApiConstants.refreshToken);
  }

  /// Refreshes accessToken using current refreshToken
  Future<bool> refreshTokenSession() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    if (_refreshToken == null || _refreshToken!.isEmpty) {
      return false;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final refreshUri = _buildUri(ApiConstants.refreshToken);
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final body = {'refreshToken': _refreshToken};

      _logRequest(method: 'POST', uri: refreshUri, headers: headers, body: body);
      final stopwatch = Stopwatch()..start();

      final response = await http
          .post(refreshUri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 7));
      stopwatch.stop();

      _logResponse(
        method: 'POST',
        uri: refreshUri,
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBody: response.body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        dynamic jsonBody;
        try {
          jsonBody = jsonDecode(response.body);
        } catch (_) {
          jsonBody = null;
        }

        final dynamic data = (jsonBody is Map<String, dynamic> && jsonBody['data'] != null)
            ? jsonBody['data']
            : jsonBody;

        if (data is Map<String, dynamic>) {
          final newAccessToken = data['accessToken']?.toString();
          final newRefreshToken = data['refreshToken']?.toString() ?? _refreshToken;

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            await setTokens(accessToken: newAccessToken, refreshToken: newRefreshToken);
            _refreshCompleter?.complete(true);
            _refreshCompleter = null;
            return true;
          }
        }
      }

      if (response.statusCode == 401 || response.statusCode == 403 || response.statusCode == 400) {
        await clearTokens();
      }
      _refreshCompleter?.complete(false);
      _refreshCompleter = null;
      return false;
    } catch (_) {
      _refreshCompleter?.complete(false);
      _refreshCompleter = null;
      return false;
    }
  }

  Map<String, String> _buildHeaders([Map<String, String>? extraHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final urlStr = '${ApiConstants.baseUrl}$cleanEndpoint';
    final baseUri = Uri.parse(urlStr);
    if (queryParams == null || queryParams.isEmpty) {
      return baseUri;
    }
    final stringParams = queryParams.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
    return baseUri.replace(queryParameters: stringParams);
  }

  dynamic _processResponse(http.Response response) {
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(response.body);
    } catch (_) {
      jsonBody = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (jsonBody is Map<String, dynamic>) {
        if (jsonBody.containsKey('success') && jsonBody['success'] == false) {
          throw ApiException(
            jsonBody['message'] ?? 'Request failed',
            statusCode: response.statusCode,
            data: jsonBody['data'],
          );
        }
        return jsonBody['data'] ?? jsonBody;
      }
      return jsonBody;
    } else {
      String errorMessage = 'Server error (${response.statusCode})';
      if (jsonBody is Map<String, dynamic> && jsonBody['message'] != null) {
        errorMessage = jsonBody['message'].toString();
      }
      throw ApiException(
        errorMessage,
        statusCode: response.statusCode,
        data: jsonBody,
      );
    }
  }

  // ===========================================================================
  // API LOGGER (DEBUG MODE ONLY)
  // ===========================================================================
  static const String _topBorder =
      '╔════════════════════════════════════════════════════════════';
  static const String _divider =
      '╠════════════════════════════════════════════════════════════';
  static const String _bottomBorder =
      '╚════════════════════════════════════════════════════════════';
  static const String _linePrefix = '║ ';

  bool _isSensitiveKey(String key) {
    final lower = key.toLowerCase().replaceAll(RegExp(r'[-_]'), '');
    const sensitive = {
      'authorization',
      'accesstoken',
      'refreshtoken',
      'password',
      'secret',
      'apikey',
    };
    if (sensitive.contains(lower)) return true;
    if (lower.contains('password')) return true;
    if (lower.contains('secret')) return true;
    if (lower.contains('token') &&
        (lower.contains('access') ||
            lower.contains('refresh') ||
            lower.contains('auth'))) {
      return true;
    }
    return false;
  }

  dynamic _maskSensitiveData(dynamic data) {
    if (data is Map) {
      final masked = <String, dynamic>{};
      for (final entry in data.entries) {
        final keyStr = entry.key.toString();
        if (_isSensitiveKey(keyStr)) {
          final valStr = entry.value?.toString() ?? '';
          if (valStr.toLowerCase().startsWith('bearer ')) {
            masked[keyStr] = 'Bearer ******';
          } else {
            masked[keyStr] = '******';
          }
        } else {
          masked[keyStr] = _maskSensitiveData(entry.value);
        }
      }
      return masked;
    } else if (data is List) {
      return data.map((item) => _maskSensitiveData(item)).toList();
    }
    return data;
  }

  String _sanitizeUrl(Uri uri) {
    if (!uri.hasQuery) return uri.toString();
    final sanitizedParams = <String, String>{};
    uri.queryParameters.forEach((key, value) {
      if (_isSensitiveKey(key)) {
        sanitizedParams[key] = '******';
      } else {
        sanitizedParams[key] = value;
      }
    });
    return uri.replace(queryParameters: sanitizedParams).toString();
  }

  List<String> _formatJson(dynamic data) {
    try {
      final masked = _maskSensitiveData(data);
      final pretty = const JsonEncoder.withIndent('  ').convert(masked);
      return pretty.split('\n');
    } catch (_) {
      return [data.toString()];
    }
  }

  List<String> _formatJsonOrText(dynamic data) {
    if (data == null) {
      return ['null'];
    }

    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) {
        return ['null'];
      }
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          final decoded = jsonDecode(trimmed);
          return _formatJson(decoded);
        } catch (_) {
          return trimmed.split('\n');
        }
      }
      return trimmed.split('\n');
    }

    return _formatJson(data);
  }

  void _logRequest({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    dynamic body,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer();
    buffer.writeln(_topBorder);
    buffer.writeln('$_linePrefix🚀 API REQUEST');
    buffer.writeln(_divider);
    buffer.writeln('$_linePrefix${'METHOD'.padRight(9)}: $method');
    buffer.writeln('$_linePrefix${'URL'.padRight(9)}: ${_sanitizeUrl(uri)}');
    buffer.writeln('$_linePrefix${'HEADERS'.padRight(9)}:');

    final headerLines = _formatJson(headers);
    for (final line in headerLines) {
      buffer.writeln('$_linePrefix  $line');
    }

    if (body == null) {
      buffer.writeln('$_linePrefix${'BODY'.padRight(9)}: null');
    } else {
      buffer.writeln('$_linePrefix${'BODY'.padRight(9)}:');
      final bodyLines = _formatJsonOrText(body);
      for (final line in bodyLines) {
        buffer.writeln('$_linePrefix  $line');
      }
    }

    buffer.write(_bottomBorder);
    debugPrint(buffer.toString());
  }

  void _logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required int durationMs,
    required String? responseBody,
  }) {
    if (!kDebugMode) return;

    final isSuccess = statusCode >= 200 && statusCode < 300;
    final title = isSuccess ? '✅ API RESPONSE' : '❌ API RESPONSE';

    final buffer = StringBuffer();
    buffer.writeln(_topBorder);
    buffer.writeln('$_linePrefix$title');
    buffer.writeln(_divider);
    buffer.writeln('$_linePrefix${'METHOD'.padRight(9)}: $method');
    buffer.writeln('$_linePrefix${'URL'.padRight(9)}: ${_sanitizeUrl(uri)}');
    buffer.writeln('$_linePrefix${'STATUS'.padRight(9)}: $statusCode');
    buffer.writeln('$_linePrefix${'DURATION'.padRight(9)}: $durationMs ms');

    if (responseBody == null || responseBody.trim().isEmpty) {
      buffer.writeln('$_linePrefix${'RESPONSE'.padRight(9)}: null');
    } else {
      buffer.writeln('$_linePrefix${'RESPONSE'.padRight(9)}:');
      final responseLines = _formatJsonOrText(responseBody);
      for (final line in responseLines) {
        buffer.writeln('$_linePrefix  $line');
      }
    }

    buffer.write(_bottomBorder);
    debugPrint(buffer.toString());
  }

  void _logError({
    required String method,
    required Uri uri,
    required int durationMs,
    required dynamic error,
  }) {
    if (!kDebugMode) return;

    String errorMessage;
    if (error is TimeoutException) {
      errorMessage = 'Request timed out';
    } else if (error != null) {
      final str = error.toString();
      if (str.toLowerCase().contains('timeout')) {
        errorMessage = 'Request timed out';
      } else {
        errorMessage = str;
      }
    } else {
      errorMessage = 'Unknown error';
    }

    final buffer = StringBuffer();
    buffer.writeln(_topBorder);
    buffer.writeln('$_linePrefix❌ API ERROR');
    buffer.writeln(_divider);
    buffer.writeln('$_linePrefix${'METHOD'.padRight(9)}: $method');
    buffer.writeln('$_linePrefix${'URL'.padRight(9)}: ${_sanitizeUrl(uri)}');
    buffer.writeln('$_linePrefix${'DURATION'.padRight(9)}: $durationMs ms');
    buffer.writeln('$_linePrefix${'ERROR'.padRight(9)}: $errorMessage');
    buffer.write(_bottomBorder);
    debugPrint(buffer.toString());
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    final uri = _buildUri(endpoint, queryParams);
    final requestHeaders = _buildHeaders(headers);
    _logRequest(method: 'GET', uri: uri, headers: requestHeaders, body: null);
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http
          .get(uri, headers: requestHeaders)
          .timeout(const Duration(seconds: 7));
      stopwatch.stop();
      _logResponse(
        method: 'GET',
        uri: uri,
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBody: response.body,
      );

        if (response.statusCode == 401 && !_isAuthEndpoint(endpoint) && _refreshToken != null && _refreshToken!.isNotEmpty) {
          final refreshed = await refreshTokenSession();
          if (refreshed) {
            final retryHeaders = _buildHeaders(headers);
            final retryStopwatch = Stopwatch()..start();
            _logRequest(method: 'GET', uri: uri, headers: retryHeaders, body: null);
            final retryResponse = await http
                .get(uri, headers: retryHeaders)
                .timeout(const Duration(seconds: 7));
            retryStopwatch.stop();
            _logResponse(
              method: 'GET',
              uri: uri,
              statusCode: retryResponse.statusCode,
              durationMs: retryStopwatch.elapsedMilliseconds,
              responseBody: retryResponse.body,
            );
            return _processResponse(retryResponse);
          }
        }

        return _processResponse(response);
      } on TimeoutException {
        stopwatch.stop();
        _logError(
          method: 'GET',
          uri: uri,
          durationMs: stopwatch.elapsedMilliseconds,
          error: 'Request timed out',
        );
        throw ApiException('Connection timed out. Please check your internet or backend server.');
      } catch (e) {
        stopwatch.stop();
        if (e is! ApiException) {
          _logError(
            method: 'GET',
            uri: uri,
            durationMs: stopwatch.elapsedMilliseconds,
            error: e,
          );
        }
        if (e is ApiException) rethrow;
        throw ApiException('Network error: ${e.toString()}');
      }
    }

    Future<dynamic> post(String endpoint, {dynamic body, Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
      final uri = _buildUri(endpoint, queryParams);
      final requestHeaders = _buildHeaders(headers);
      _logRequest(method: 'POST', uri: uri, headers: requestHeaders, body: body);
      final stopwatch = Stopwatch()..start();
      try {
        final response = await http
            .post(
              uri,
              headers: requestHeaders,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(const Duration(seconds: 7));
        stopwatch.stop();
        _logResponse(
          method: 'POST',
          uri: uri,
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
          responseBody: response.body,
        );

        if (response.statusCode == 401 && !_isAuthEndpoint(endpoint) && _refreshToken != null && _refreshToken!.isNotEmpty) {
          final refreshed = await refreshTokenSession();
          if (refreshed) {
            final retryHeaders = _buildHeaders(headers);
            final retryStopwatch = Stopwatch()..start();
            _logRequest(method: 'POST', uri: uri, headers: retryHeaders, body: body);
            final retryResponse = await http
                .post(
                  uri,
                  headers: retryHeaders,
                  body: body != null ? jsonEncode(body) : null,
                )
                .timeout(const Duration(seconds: 7));
            retryStopwatch.stop();
            _logResponse(
              method: 'POST',
              uri: uri,
              statusCode: retryResponse.statusCode,
              durationMs: retryStopwatch.elapsedMilliseconds,
              responseBody: retryResponse.body,
            );
            return _processResponse(retryResponse);
          }
        }

        return _processResponse(response);
      } on TimeoutException {
        stopwatch.stop();
        _logError(
          method: 'POST',
          uri: uri,
          durationMs: stopwatch.elapsedMilliseconds,
          error: 'Request timed out',
        );
        throw ApiException('Connection timed out. Please check your internet or backend server.');
      } catch (e) {
        stopwatch.stop();
        if (e is! ApiException) {
          _logError(
            method: 'POST',
            uri: uri,
            durationMs: stopwatch.elapsedMilliseconds,
            error: e,
          );
        }
        if (e is ApiException) rethrow;
        throw ApiException('Network error: ${e.toString()}');
      }
    }

    Future<dynamic> put(String endpoint, {dynamic body, Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
      final uri = _buildUri(endpoint, queryParams);
      final requestHeaders = _buildHeaders(headers);
      _logRequest(method: 'PUT', uri: uri, headers: requestHeaders, body: body);
      final stopwatch = Stopwatch()..start();
      try {
        final response = await http
            .put(
              uri,
              headers: requestHeaders,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(const Duration(seconds: 7));
        stopwatch.stop();
        _logResponse(
          method: 'PUT',
          uri: uri,
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
          responseBody: response.body,
        );

        if (response.statusCode == 401 && !_isAuthEndpoint(endpoint) && _refreshToken != null && _refreshToken!.isNotEmpty) {
          final refreshed = await refreshTokenSession();
          if (refreshed) {
            final retryHeaders = _buildHeaders(headers);
            final retryStopwatch = Stopwatch()..start();
            _logRequest(method: 'PUT', uri: uri, headers: retryHeaders, body: body);
            final retryResponse = await http
                .put(
                  uri,
                  headers: retryHeaders,
                  body: body != null ? jsonEncode(body) : null,
                )
                .timeout(const Duration(seconds: 7));
            retryStopwatch.stop();
            _logResponse(
              method: 'PUT',
              uri: uri,
              statusCode: retryResponse.statusCode,
              durationMs: retryStopwatch.elapsedMilliseconds,
              responseBody: retryResponse.body,
            );
            return _processResponse(retryResponse);
          }
        }

        return _processResponse(response);
      } on TimeoutException {
        stopwatch.stop();
        _logError(
          method: 'PUT',
          uri: uri,
          durationMs: stopwatch.elapsedMilliseconds,
          error: 'Request timed out',
        );
        throw ApiException('Connection timed out. Please check your internet or backend server.');
      } catch (e) {
        stopwatch.stop();
        if (e is! ApiException) {
          _logError(
            method: 'PUT',
            uri: uri,
            durationMs: stopwatch.elapsedMilliseconds,
            error: e,
          );
        }
        if (e is ApiException) rethrow;
        throw ApiException('Network error: ${e.toString()}');
      }
    }

    Future<dynamic> patch(String endpoint, {dynamic body, Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
      final uri = _buildUri(endpoint, queryParams);
      final requestHeaders = _buildHeaders(headers);
      _logRequest(method: 'PATCH', uri: uri, headers: requestHeaders, body: body);
      final stopwatch = Stopwatch()..start();
      try {
        final response = await http
            .patch(
              uri,
              headers: requestHeaders,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(const Duration(seconds: 7));
        stopwatch.stop();
        _logResponse(
          method: 'PATCH',
          uri: uri,
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
          responseBody: response.body,
        );

        if (response.statusCode == 401 && !_isAuthEndpoint(endpoint) && _refreshToken != null && _refreshToken!.isNotEmpty) {
          final refreshed = await refreshTokenSession();
          if (refreshed) {
            final retryHeaders = _buildHeaders(headers);
            final retryStopwatch = Stopwatch()..start();
            _logRequest(method: 'PATCH', uri: uri, headers: retryHeaders, body: body);
            final retryResponse = await http
                .patch(
                  uri,
                  headers: retryHeaders,
                  body: body != null ? jsonEncode(body) : null,
                )
                .timeout(const Duration(seconds: 7));
            retryStopwatch.stop();
            _logResponse(
              method: 'PATCH',
              uri: uri,
              statusCode: retryResponse.statusCode,
              durationMs: retryStopwatch.elapsedMilliseconds,
              responseBody: retryResponse.body,
            );
            return _processResponse(retryResponse);
          }
        }

        return _processResponse(response);
      } on TimeoutException {
        stopwatch.stop();
        _logError(
          method: 'PATCH',
          uri: uri,
          durationMs: stopwatch.elapsedMilliseconds,
          error: 'Request timed out',
        );
        throw ApiException('Connection timed out. Please check your internet or backend server.');
      } catch (e) {
        stopwatch.stop();
        if (e is! ApiException) {
          _logError(
            method: 'PATCH',
            uri: uri,
            durationMs: stopwatch.elapsedMilliseconds,
            error: e,
          );
        }
        if (e is ApiException) rethrow;
        throw ApiException('Network error: ${e.toString()}');
      }
    }

    Future<dynamic> delete(String endpoint, {Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
      final uri = _buildUri(endpoint, queryParams);
      final requestHeaders = _buildHeaders(headers);
      _logRequest(method: 'DELETE', uri: uri, headers: requestHeaders, body: null);
      final stopwatch = Stopwatch()..start();
      try {
        final response = await http
            .delete(uri, headers: requestHeaders)
            .timeout(const Duration(seconds: 7));
        stopwatch.stop();
        _logResponse(
          method: 'DELETE',
          uri: uri,
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
          responseBody: response.body,
        );

        if (response.statusCode == 401 && !_isAuthEndpoint(endpoint) && _refreshToken != null && _refreshToken!.isNotEmpty) {
          final refreshed = await refreshTokenSession();
          if (refreshed) {
            final retryHeaders = _buildHeaders(headers);
            final retryStopwatch = Stopwatch()..start();
            _logRequest(method: 'DELETE', uri: uri, headers: retryHeaders, body: null);
            final retryResponse = await http
                .delete(uri, headers: retryHeaders)
                .timeout(const Duration(seconds: 7));
            retryStopwatch.stop();
            _logResponse(
              method: 'DELETE',
              uri: uri,
              statusCode: retryResponse.statusCode,
              durationMs: retryStopwatch.elapsedMilliseconds,
              responseBody: retryResponse.body,
            );
            return _processResponse(retryResponse);
          }
        }

        return _processResponse(response);
      } on TimeoutException {
        stopwatch.stop();
        _logError(
          method: 'DELETE',
          uri: uri,
          durationMs: stopwatch.elapsedMilliseconds,
          error: 'Request timed out',
        );
        throw ApiException('Connection timed out. Please check your internet or backend server.');
      } catch (e) {
        stopwatch.stop();
        if (e is! ApiException) {
          _logError(
            method: 'DELETE',
            uri: uri,
            durationMs: stopwatch.elapsedMilliseconds,
            error: e,
          );
        }
        if (e is ApiException) rethrow;
        throw ApiException('Network error: ${e.toString()}');
      }
    }
  }
