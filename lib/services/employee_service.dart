import '../core/network/api_client.dart';
import '../models/employees/employee.dart';

class EmployeeService {
  final ApiClient apiClient;

  EmployeeService({
    required this.apiClient,
  });

  // =========================================================
  // ÇALIŞANLARI GETİR
  //
  // GET /api/Auth/employees
  //
  // SADECE ADMIN
  // =========================================================

  Future<List<Employee>> getAll() async {
    final response =
        await apiClient.dio.get(
      '/Auth/employees',
    );

    final data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) => Employee.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          ),
        )
        .toList();
  }

  // =========================================================
  // ÇALIŞAN DETAY
  //
  // GET /api/Auth/employees/{id}
  //
  // SADECE ADMIN
  // =========================================================

  Future<Employee> getById(
    int id,
  ) async {
    final response =
        await apiClient.dio.get(
      '/Auth/employees/$id',
    );

    final data =
        Map<String, dynamic>.from(
      response.data as Map,
    );

    return Employee.fromJson(
      data,
    );
  }

  // =========================================================
  // ÇALIŞAN EKLE
  //
  // POST /api/Auth/employees
  //
  // SADECE ADMIN
  // =========================================================

  Future<Employee> create({
    required String username,
    required String password,
  }) async {
    final response =
        await apiClient.dio.post(
      '/Auth/employees',
      data: {
        'username':
            username.trim(),
        'password':
            password,
      },
    );

    final data =
        Map<String, dynamic>.from(
      response.data as Map,
    );

    return Employee.fromJson(
      data,
    );
  }

  // =========================================================
  // ÇALIŞAN GÜNCELLE
  //
  // PUT /api/Auth/employees/{id}
  //
  // SADECE ADMIN
  // =========================================================

  Future<Employee> update({
    required int id,
    required String username,
  }) async {
    final response =
        await apiClient.dio.put(
      '/Auth/employees/$id',
      data: {
        'username':
            username.trim(),
      },
    );

    final data =
        Map<String, dynamic>.from(
      response.data as Map,
    );

    return Employee.fromJson(
      data,
    );
  }

  // =========================================================
  // ÇALIŞAN ŞİFRESİ DEĞİŞTİR
  //
  // PUT /api/Auth/employees/{id}/password
  //
  // SADECE ADMIN
  // =========================================================

  Future<void> changePassword({
    required int id,
    required String newPassword,
  }) async {
    await apiClient.dio.put(
      '/Auth/employees/$id/password',
      data: {
        'newPassword':
            newPassword,
      },
    );
  }

  // =========================================================
  // ÇALIŞANI PASİFLEŞTİR
  //
  // DELETE /api/Auth/employees/{id}
  //
  // SADECE ADMIN
  // =========================================================

  Future<void> deactivate(
    int id,
  ) async {
    await apiClient.dio.delete(
      '/Auth/employees/$id',
    );
  }

  // =========================================================
  // ÇALIŞANI AKTİFLEŞTİR
  //
  // POST /api/Auth/employees/{id}/activate
  //
  // SADECE ADMIN
  // =========================================================

  Future<void> activate(
    int id,
  ) async {
    await apiClient.dio.post(
      '/Auth/employees/$id/activate',
    );
  }
}