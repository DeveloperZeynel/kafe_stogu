import '../core/network/api_client.dart';
import '../models/products/category.dart';

class CategoryService {
  final ApiClient apiClient;

  CategoryService({
    required this.apiClient,
  });

  // =========================================================
  // KATEGORİLERİ GETİR
  // GET /api/Categories
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<List<Category>> getAll() async {
    final response =
        await apiClient.dio.get(
      '/Categories',
    );

    final data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) => Category.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // =========================================================
  // KATEGORİ DETAY
  // GET /api/Categories/{id}
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<Category> getById(
    int id,
  ) async {
    final response =
        await apiClient.dio.get(
      '/Categories/$id',
    );

    return Category.fromJson(
      response.data
          as Map<String, dynamic>,
    );
  }

  // =========================================================
  // KATEGORİ EKLE
  // POST /api/Categories
  // SADECE ADMIN
  // =========================================================

  Future<Category> create({
    required String name,
  }) async {
    final response =
        await apiClient.dio.post(
      '/Categories',
      data: {
        'name': name.trim(),
      },
    );

    return Category.fromJson(
      response.data
          as Map<String, dynamic>,
    );
  }

  // =========================================================
  // KATEGORİ GÜNCELLE
  // PUT /api/Categories/{id}
  // SADECE ADMIN
  // =========================================================

  Future<Category> update({
    required int id,
    required String name,
  }) async {
    final response =
        await apiClient.dio.put(
      '/Categories/$id',
      data: {
        'name': name.trim(),
      },
    );

    return Category.fromJson(
      response.data
          as Map<String, dynamic>,
    );
  }

  // =========================================================
  // KATEGORİ SİL
  // DELETE /api/Categories/{id}
  // SADECE ADMIN
  // =========================================================

  Future<void> delete(
    int id,
  ) async {
    await apiClient.dio.delete(
      '/Categories/$id',
    );
  }
}
