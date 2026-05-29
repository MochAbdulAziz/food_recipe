import 'package:dio/dio.dart';

/// Singleton Dio client pointed at TheMealDB free tier.
class ApiClient {
  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    _dio.interceptors.addAll([
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  /// GET request. [path] should start with '/'.
  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
    );
    return response.data!;
  }
}

// ── Interceptors ─────────────────────────────────────────────────────────────

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] → ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ✗ ${err.type}: ${err.message}');
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final msg = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Request timed out. Check your connection.',
      DioExceptionType.connectionError => 'No internet connection.',
      DioExceptionType.badResponse =>
        'Server error (${err.response?.statusCode}).',
      _ => 'Unexpected error: ${err.message}',
    };
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        type: err.type,
        message: msg,
        response: err.response,
        error: err.error,
      ),
    );
  }
}
