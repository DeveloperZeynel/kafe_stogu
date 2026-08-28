import '../core/network/api_client.dart';
import '../models/products/product.dart';
import '../models/products/product_stock_movement.dart';

class ProductService {
  final ApiClient apiClient;

  ProductService({
    required this.apiClient,
  });

  // =========================================================
  // TÜM ÜRÜNLERİ GETİR
  // GET /api/Products
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<List<Product>> getAll() async {
    final response =
        await apiClient.dio.get(
      '/Products',
    );

    final data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) => Product.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          ),
        )
        .toList();
  }

  // =========================================================
  // KATEGORİYE GÖRE ÜRÜNLER
  // GET /api/Products/category/{categoryId}
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<List<Product>> getByCategory(
    int categoryId,
  ) async {
    final response =
        await apiClient.dio.get(
      '/Products/category/$categoryId',
    );

    final data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) => Product.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          ),
        )
        .toList();
  }

  // =========================================================
  // ÜRÜN DETAY
  // GET /api/Products/{id}
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<Product> getById(
    int id,
  ) async {
    final response =
        await apiClient.dio.get(
      '/Products/$id',
    );

    return Product.fromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  }

  // =========================================================
  // ÜRÜN EKLE
  // POST /api/Products
  // SADECE ADMIN
  // =========================================================

  Future<Product> create({
    required String name,
    required int categoryId,
    required int unitType,
    required double initialStock,
    required double minimumStock,
  }) async {
    final response =
        await apiClient.dio.post(
      '/Products',
      data: {
        'name': name,
        'categoryId': categoryId,
        'unitType': unitType,
        'initialStock':
            initialStock,
        'minimumStock':
            minimumStock,
      },
    );

    return Product.fromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  }

  // =========================================================
  // ÜRÜN GÜNCELLE
  // PUT /api/Products/{id}
  // SADECE ADMIN
  // =========================================================

  Future<Product> update({
    required int id,
    required String name,
    required int categoryId,
    required int unitType,
    required double minimumStock,
  }) async {
    final response =
        await apiClient.dio.put(
      '/Products/$id',
      data: {
        'name': name,
        'categoryId': categoryId,
        'unitType': unitType,
        'minimumStock':
            minimumStock,
      },
    );

    return Product.fromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  }

  // =========================================================
  // ÜRÜN SİL
  // DELETE /api/Products/{id}
  // SADECE ADMIN
  // =========================================================

  Future<void> delete(
    int id,
  ) async {
    await apiClient.dio.delete(
      '/Products/$id',
    );
  }

  // =========================================================
  // STOK GİRİŞİ
  // POST /api/Products/{id}/stock-in
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<Map<String, dynamic>>
      stockIn({
    required int id,
    required double quantity,
    String? note,
  }) async {
    final response =
        await apiClient.dio.post(
      '/Products/$id/stock-in',
      data: {
        'quantity': quantity,
        'note': note,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  // =========================================================
  // STOK ÇIKIŞI
  // POST /api/Products/{id}/stock-out
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<Map<String, dynamic>>
      stockOut({
    required int id,
    required double quantity,
    String? note,
  }) async {
    final response =
        await apiClient.dio.post(
      '/Products/$id/stock-out',
      data: {
        'quantity': quantity,
        'note': note,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  // =========================================================
  // STOK DÜZELTME
  // POST /api/Products/{id}/stock-adjustment
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<Map<String, dynamic>>
      adjustStock({
    required int id,
    required double quantity,
    String? note,
  }) async {
    final response =
        await apiClient.dio.post(
      '/Products/$id/stock-adjustment',
      data: {
        'quantity': quantity,
        'note': note,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  // =========================================================
  // STOK HAREKETLERİ
  // GET /api/Products/{id}/stock-movements
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<List<ProductStockMovement>>
      getStockMovements(
    int id,
  ) async {
    final response =
        await apiClient.dio.get(
      '/Products/$id/stock-movements',
    );

    final data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) =>
              ProductStockMovement.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          ),
        )
        .toList();
  }

  // =========================================================
  // DÜŞÜK STOKLAR
  // GET /api/Products/low-stock
  // SADECE ADMIN
  // =========================================================

  Future<List<Product>>
      getLowStock() async {
    final response =
        await apiClient.dio.get(
      '/Products/low-stock',
    );

    final data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) => Product.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          ),
        )
        .toList();
  }

  // =========================================================
  // ÜRÜN DASHBOARD
  // GET /api/Products/dashboard
  // SADECE ADMIN
  // =========================================================

  Future<Map<String, dynamic>>
      getDashboard() async {
    final response =
        await apiClient.dio.get(
      '/Products/dashboard',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  // =========================================================
  // STOK RAPORU
  // GET /api/Products/reports/stock
  // SADECE ADMIN
  // =========================================================

  Future<Map<String, dynamic>>
      getStockReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response =
        await apiClient.dio.get(
      '/Products/reports/stock',
      queryParameters: {
        if (startDate != null)
          'startDate':
              startDate.toIso8601String(),

        if (endDate != null)
          'endDate':
              endDate.toIso8601String(),
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  // =========================================================
  // STOK HAREKET RAPORU
  // GET /api/Products/reports/stock/movements
  // SADECE ADMIN
  // =========================================================

  Future<Map<String, dynamic>>
      getStockMovementReport({
    DateTime? startDate,
    DateTime? endDate,
    int? productId,
  }) async {
    final response =
        await apiClient.dio.get(
      '/Products/reports/stock/movements',
      queryParameters: {
        if (startDate != null)
          'startDate':
              startDate.toIso8601String(),

        if (endDate != null)
          'endDate':
              endDate.toIso8601String(),

        'productId': ?productId,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }
}
