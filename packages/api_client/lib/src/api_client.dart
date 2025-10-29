import 'dart:async';
import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

///
typedef RequestMethod<T> = Future<Response<T>> Function(
  String path, {
  Object? data,
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  void Function(int, int)? onReceiveProgress,
});

/// {@template api_client}
/// API Client
/// {@endtemplate}
class ApiClient {
  /// {@macro api_client}
  ApiClient({
    required String baseUrl,
    AuthTokenProvider? authTokenProvider,
  })  : _authTokenProvider = authTokenProvider,
        _dio = Dio(
          BaseOptions(
            baseUrl: '$baseUrl/api/v1/',
            sendTimeout: const Duration(seconds: 15),
            headers: {
              'brand': 'IMSS001',
            },
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        ) {
    // Add auth interceptor if provider is available
    if (authTokenProvider != null) {
      _dio.interceptors.add(AuthInterceptor(tokenProvider: authTokenProvider));
    }

    // Only add logger in debug mode to prevent sensitive data leaks in release
    assert(
      () {
        _dio.interceptors.add(
          PrettyDioLogger(
            requestBody: true,
            logPrint: (object) => log(object.toString()),
          ),
        );
        return true;
      }(),
      '',
    );
  }

  /// Dio instance used by the client
  final Dio _dio;

  /// Auth token provider for session management
  final AuthTokenProvider? _authTokenProvider;

  /// Performs a POST request to [path]
  ///
  /// {@macro api_client._request}
  Future<Either<ApiFailure, Response<T>>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    List<MultipartFile?>? files,
    Map<String, dynamic>? queryParameters,
    bool authRequired = true,
  }) async {
    final res = await _request(
      path,
      _dio.post<T>,
      authRequired: authRequired,
      files: files,
      body: body,
      queryParameters: queryParameters,
    );
    return res;
  }

  /// Performs a GET request to [path]
  ///
  /// {@macro api_client._request}
  Future<Either<ApiFailure, Response<T>>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool authRequired = true,
  }) async {
    final res = await _request(
      path,
      _dio.get<T>,
      authRequired: authRequired,
      queryParameters: queryParameters,
    );
    return res;
  }

  /// {@template api_client._request}
  /// [path] should not contain the base url or leading and trailing slashes
  ///
  /// [body] should be a Map of key-value pairs to be sent as the body
  /// of the request
  ///
  /// [queryParameters] should be a Map of key-value pairs to be used as
  ///  the query parameters of the request
  ///
  /// [authRequired] should be set to true if the request requires
  /// authentication (ie, Authorization header should be set). defaults to true
  ///
  /// Returns an [Either] of [ApiFailure] or [Response] with body of type [T]
  ///
  /// Throws [ApiValidationFailure] if the response is 422 and contains
  ///  validation errors
  ///
  /// Throws [UnauthorizedFailure] if the response contains 401 status code
  /// User should be logged out in this case
  ///
  /// Throws [NotFoundFailure] if the response contains 404 status code
  ///
  /// Throws [UnknownApiFailure] if an unknown error occurred
  /// {@endtemplate}
  Future<Either<ApiFailure, Response<T>>> _request<T>(
    String path,
    RequestMethod<T> method, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    List<MultipartFile?>? files,
    bool authRequired = true,
  }) async {
    Object? bodyToSend;
    if (files != null) {
      bodyToSend = FormData.fromMap({
        'files': files,
        if (body != null) ...body,
      });
    } else if (body != null) {
      bodyToSend = body;
    }

    try {
      final res = await method(
        path,
        data: bodyToSend,
        queryParameters: queryParameters,
        options: Options(
          extra: {'authRequired': authRequired}, // Pass to interceptor
        ),
        cancelToken:
            _authTokenProvider?.cancelToken, // Use session cancel token
      );
      return right(res);
    } on DioException catch (e, s) {
      log(
        'DioException occurred while calling $path,${e.requestOptions.uri} $e',
        stackTrace: s,
      );

      // Use hardened error mapping for better UX and safety
      final failure = ErrorMapper.mapDioException(e, path);
      return left(failure);
    } catch (e, s) {
      log('Unknown error occurred while calling $path, $e', stackTrace: s);
      return left(const UnknownApiFailure(500, 'Unknown error'));
    }
  }
}
