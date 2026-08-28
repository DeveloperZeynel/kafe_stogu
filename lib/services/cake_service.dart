import '../core/network/api_client.dart';
import '../models/cakes/cake.dart';
import '../models/cakes/cake_summary.dart';
import '../models/cakes/cake_cabinet.dart';

class CakeService {
  final ApiClient apiClient;

  CakeService({
    required this.apiClient,
  });

  // =========================================================
  // PASTALARI LİSTELE
  // GET /api/Cakes
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<List<Cake>> getAll() async {
    final response =
        await apiClient.dio.get(
      '/Cakes',
    );

    final data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) => Cake.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // =========================================================
  // PASTA DETAY
  // GET /api/Cakes/{id}
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<Cake> getById(
    int id,
  ) async {
    final response =
        await apiClient.dio.get(
      '/Cakes/$id',
    );

    return Cake.fromJson(
      response.data
          as Map<String, dynamic>,
    );
  }

  // =========================================================
  // PASTA EKLE
  // POST /api/Cakes
  // SADECE ADMIN
  // =========================================================

  Future<Cake> create({
    required String name,
    required int sliceCount,
    required int slicesPerBox,
    required double boxPurchasePrice,
    required double sliceSalePrice,
  }) async {
    final response =
        await apiClient.dio.post(
      '/Cakes',
      data: {
        'name': name,
        'sliceCount': sliceCount,
        'slicesPerBox': slicesPerBox,
        'boxPurchasePrice':
            boxPurchasePrice,
        'sliceSalePrice':
            sliceSalePrice,
      },
    );

    return Cake.fromJson(
      response.data
          as Map<String, dynamic>,
    );
  }

  // =========================================================
  // PASTA GÜNCELLE
  // PUT /api/Cakes/{id}
  // SADECE ADMIN
  // =========================================================

  Future<Cake> update({
    required int id,
    required String name,
    required int slicesPerBox,
    required double boxPurchasePrice,
    required double sliceSalePrice,
  }) async {
    final response =
        await apiClient.dio.put(
      '/Cakes/$id',
      data: {
        'name': name,
        'slicesPerBox':
            slicesPerBox,
        'boxPurchasePrice':
            boxPurchasePrice,
        'sliceSalePrice':
            sliceSalePrice,
      },
    );

    return Cake.fromJson(
      response.data
          as Map<String, dynamic>,
    );
  }

  // =========================================================
  // PASTA SİL
  // DELETE /api/Cakes/{id}
  // SADECE ADMIN
  // =========================================================

  Future<void> delete(
    int id,
  ) async {
    await apiClient.dio.delete(
      '/Cakes/$id',
    );
  }

  // =========================================================
  // STOK DÜZELTME
  // POST /api/Cakes/{id}/stock-adjustment
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<Map<String, dynamic>>
      adjustStock({
    required int id,
    required int quantity,
    String? note,
  }) async {
    final response =
        await apiClient.dio.post(
      '/Cakes/$id/stock-adjustment',
      data: {
        'quantity': quantity,
        'note': note,
      },
    );

    return Map<String, dynamic>.from(
      response.data
          as Map<String, dynamic>,
    );
  }

  // =========================================================
  // PASTAYI DOLABA KOY
  // POST /api/Cakes/{id}/cabinet
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<Map<String, dynamic>>
      putInCabinet({
    required int id,
    required int sliceQuantity,
  }) async {
    final response =
        await apiClient.dio.post(
      '/Cakes/$id/cabinet',
      data: {
        'sliceQuantity':
            sliceQuantity,
      },
    );

    return Map<String, dynamic>.from(
      response.data
          as Map<String, dynamic>,
    );
  }

  // =========================================================
  // TEK PASTANIN DOLAP KAYITLARI
  // GET /api/Cakes/{id}/cabinet
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<List<CakeCabinet>>
      getCabinetRecords(
    int id,
  ) async {
    final response =
        await apiClient.dio.get(
      '/Cakes/$id/cabinet',
    );

    final data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) =>
              CakeCabinet.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // =========================================================
  // TÜM PASTALARIN DOLAP KAYITLARI
  // GET /api/Cakes/cabinets
  // ADMIN + EMPLOYEE
  //
  // Stok İşlemleri
  //     ↓
  // Dolaptaki Pastalar
  //
  // Bütün pastaların bütün partilerini getirir.
  // =========================================================

  Future<List<CakeCabinet>>
      getAllCabinets() async {
    final response =
        await apiClient.dio.get(
      '/Cakes/cabinets',
    );

    final data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) =>
              CakeCabinet.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // =========================================================
  // DOLAPTAN SATIŞ
  // POST /api/Cakes/cabinet/{cabinetId}/sale
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<Map<String, dynamic>>
      createCabinetSale({
    required int cabinetId,
    required int sliceQuantity,
  }) async {
    final response =
        await apiClient.dio.post(
      '/Cakes/cabinet/$cabinetId/sale',
      data: {
        'sliceQuantity':
            sliceQuantity,
      },
    );

    return Map<String, dynamic>.from(
      response.data
          as Map<String, dynamic>,
    );
  }

  // =========================================================
  // DOLAPTAN ZAYİ
  // POST /api/Cakes/cabinet/{cabinetId}/waste
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<Map<String, dynamic>>
      createCabinetWaste({
    required int cabinetId,
    required int sliceQuantity,
  }) async {
    final response =
        await apiClient.dio.post(
      '/Cakes/cabinet/$cabinetId/waste',
      data: {
        'sliceQuantity':
            sliceQuantity,
      },
    );

    return Map<String, dynamic>.from(
      response.data
          as Map<String, dynamic>,
    );
  }

  // =========================================================
  // ANA STOKTAN ZAYİ
  // POST /api/Cakes/{id}/waste
  // ADMIN + EMPLOYEE
  // =========================================================

  Future<Map<String, dynamic>>
      createWaste({
    required int id,
    required int sliceQuantity,
  }) async {
    final response =
        await apiClient.dio.post(
      '/Cakes/$id/waste',
      data: {
        'sliceQuantity':
            sliceQuantity,
      },
    );

    return Map<String, dynamic>.from(
      response.data
          as Map<String, dynamic>,
    );
  }

  // =========================================================
  // PASTA ÖZETİ
  // GET /api/Cakes/summary
  // SADECE ADMIN
  // =========================================================

  Future<List<CakeSummary>>
      getSummary() async {
    final response =
        await apiClient.dio.get(
      '/Cakes/summary',
    );

    final data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) =>
              CakeSummary.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
