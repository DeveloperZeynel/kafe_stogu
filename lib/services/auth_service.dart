import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/storage/auth_storage.dart';
import '../models/auth/login_response.dart';

class AuthService {
  final ApiClient apiClient;
  final AuthStorage authStorage;

  AuthService({
    required this.apiClient,
    required this.authStorage,
  });

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response =
          await apiClient.dio.post(
        '/Auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final result =
          LoginResponse.fromJson(
        response.data
            as Map<String, dynamic>,
      );

      await authStorage.saveAuth(
        token: result.token,
        userId: result.userId,
        username: result.username,
        role: result.role,
      );

      return result;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception(
          'Kullanıcı adı veya şifre hatalı.',
        );
      }

      if (e.response?.data is Map) {
        final data =
            e.response!.data
                as Map<String, dynamic>;

        final message =
            data['message'];

        if (message != null) {
          throw Exception(
            message.toString(),
          );
        }
      }

      throw Exception(
        'Sunucuya bağlanırken bir hata oluştu.',
      );
    }
  }

  Future<void> logout() async {
    await authStorage.clear();
  }
}