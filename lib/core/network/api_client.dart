import 'package:dio/dio.dart';

import '../constants/api_config.dart';
import '../storage/auth_storage.dart';

class ApiClient {
  late final Dio dio;

  final AuthStorage authStorage;

  ApiClient({
    required this.authStorage,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout:
            const Duration(seconds: 10),
        receiveTimeout:
            const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (options, handler) async {
          final token =
              await authStorage.getToken();

          if (token != null &&
              token.isNotEmpty) {
            options.headers['Authorization'] =
                'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }
}