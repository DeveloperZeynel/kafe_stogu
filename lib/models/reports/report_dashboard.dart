class ReportDashboard {
  // =========================================================
  // ÜRÜNLER
  // =========================================================

  final int totalProductCount;

  final int lowStockProductCount;


  // =========================================================
  // PASTALAR
  // =========================================================

  final int totalCakeCount;

  // Ana pasta stoğunda bulunan toplam dilim
  final int totalCakeStock;


  // =========================================================
  // DOLAP
  // =========================================================

  final int cabinetRemainingSliceCount;

  final int cabinetSoldSliceCount;

  final int cabinetWastedSliceCount;


  // =========================================================
  // GELİR
  // =========================================================

  final double totalPotentialRevenue;

  final double totalRealizedRevenue;


  // =========================================================
  // ZAYİ
  // =========================================================

  final int totalWastedSliceCount;

  final double totalWasteCost;


  const ReportDashboard({
    required this.totalProductCount,
    required this.lowStockProductCount,
    required this.totalCakeCount,
    required this.totalCakeStock,
    required this.cabinetRemainingSliceCount,
    required this.cabinetSoldSliceCount,
    required this.cabinetWastedSliceCount,
    required this.totalPotentialRevenue,
    required this.totalRealizedRevenue,
    required this.totalWastedSliceCount,
    required this.totalWasteCost,
  });


  // =========================================================
  // FROM JSON
  // =========================================================

  factory ReportDashboard.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportDashboard(
      totalProductCount: _readInt(
        json['totalProductCount'],
      ),

      lowStockProductCount: _readInt(
        json['lowStockProductCount'],
      ),

      totalCakeCount: _readInt(
        json['totalCakeCount'],
      ),

      totalCakeStock: _readInt(
        json['totalCakeStock'],
      ),

      cabinetRemainingSliceCount: _readInt(
        json['cabinetRemainingSliceCount'],
      ),

      cabinetSoldSliceCount: _readInt(
        json['cabinetSoldSliceCount'],
      ),

      cabinetWastedSliceCount: _readInt(
        json['cabinetWastedSliceCount'],
      ),

      totalPotentialRevenue: _readDouble(
        json['totalPotentialRevenue'],
      ),

      totalRealizedRevenue: _readDouble(
        json['totalRealizedRevenue'],
      ),

      totalWastedSliceCount: _readInt(
        json['totalWastedSliceCount'],
      ),

      totalWasteCost: _readDouble(
        json['totalWasteCost'],
      ),
    );
  }


  // =========================================================
  // JSON
  // =========================================================

  Map<String, dynamic> toJson() {
    return {
      'totalProductCount':
          totalProductCount,

      'lowStockProductCount':
          lowStockProductCount,

      'totalCakeCount':
          totalCakeCount,

      'totalCakeStock':
          totalCakeStock,

      'cabinetRemainingSliceCount':
          cabinetRemainingSliceCount,

      'cabinetSoldSliceCount':
          cabinetSoldSliceCount,

      'cabinetWastedSliceCount':
          cabinetWastedSliceCount,

      'totalPotentialRevenue':
          totalPotentialRevenue,

      'totalRealizedRevenue':
          totalRealizedRevenue,

      'totalWastedSliceCount':
          totalWastedSliceCount,

      'totalWasteCost':
          totalWasteCost,
    };
  }


  // =========================================================
  // STOK HESAPLAMALARI
  // =========================================================

  /// Ana stok + dolapta şu anda bulunan toplam dilim.
  int get totalAvailableSliceCount {
    return totalCakeStock +
        cabinetRemainingSliceCount;
  }

  /// Dolaba bugüne kadar giren toplam dilim sayısı.
  int get totalCabinetProcessedSliceCount {
    return cabinetRemainingSliceCount +
        cabinetSoldSliceCount +
        cabinetWastedSliceCount;
  }

  /// Dolaptaki satılmamış veya zayi edilmemiş
  /// dilim miktarını gösterir.
  int get cabinetActiveSliceCount {
    return cabinetRemainingSliceCount;
  }


  // =========================================================
  // GELİR HESAPLAMALARI
  // =========================================================

  /// Potansiyel gelir ile gerçekleşen gelir arasındaki fark.
  double get revenueDifference {
    return totalPotentialRevenue -
        totalRealizedRevenue;
  }

  /// Zayi maliyeti düşüldükten sonraki gelir.
  ///
  /// Not:
  /// Bu değer net kâr değildir.
  /// Sadece gerçekleşen gelirden zayi maliyetinin
  /// düşülmüş halidir.
  double get netRevenueAfterWaste {
    return totalRealizedRevenue -
        totalWasteCost;
  }

  /// Potansiyel cironun yüzde kaçının
  /// gerçekleştiğini gösterir.
  double get revenueRealizationRate {
    if (totalPotentialRevenue <= 0) {
      return 0;
    }

    return
        (totalRealizedRevenue /
            totalPotentialRevenue) *
        100;
  }


  // =========================================================
  // ZAYİ HESAPLAMALARI
  // =========================================================

  double get wasteRate {
    final totalProcessed =
        totalCabinetProcessedSliceCount;

    if (totalProcessed <= 0) {
      return 0;
    }

    return
        (cabinetWastedSliceCount /
            totalProcessed) *
        100;
  }

  /// Toplam zayi maliyetinin gerçekleşen gelire oranı.
  double get wasteCostRate {
    if (totalRealizedRevenue <= 0) {
      return 0;
    }

    return
        (totalWasteCost /
            totalRealizedRevenue) *
        100;
  }


  // =========================================================
  // ÜRÜN HESAPLAMALARI
  // =========================================================

  /// Düşük stokta olmayan aktif ürün sayısı.
  int get normalStockProductCount {
    final result =
        totalProductCount -
            lowStockProductCount;

    if (result < 0) {
      return 0;
    }

    return result;
  }

  /// Düşük stok oranı.
  double get lowStockRate {
    if (totalProductCount <= 0) {
      return 0;
    }

    return
        (lowStockProductCount /
            totalProductCount) *
        100;
  }


  // =========================================================
  // FORMATLAMA
  // =========================================================

  String get totalPotentialRevenueText {
    return _formatCurrency(
      totalPotentialRevenue,
    );
  }

  String get totalRealizedRevenueText {
    return _formatCurrency(
      totalRealizedRevenue,
    );
  }

  String get totalWasteCostText {
    return _formatCurrency(
      totalWasteCost,
    );
  }

  String get revenueDifferenceText {
    return _formatCurrency(
      revenueDifference,
    );
  }

  String get netRevenueAfterWasteText {
    return _formatCurrency(
      netRevenueAfterWaste,
    );
  }

  String get wasteRateText {
    return
        '${wasteRate.toStringAsFixed(1)}%';
  }

  String get wasteCostRateText {
    return
        '${wasteCostRate.toStringAsFixed(1)}%';
  }

  String get revenueRealizationRateText {
    return
        '${revenueRealizationRate.toStringAsFixed(1)}%';
  }

  String get lowStockRateText {
    return
        '${lowStockRate.toStringAsFixed(1)}%';
  }

  String get totalCakeStockText {
    return '$totalCakeStock dilim';
  }

  String get cabinetRemainingSliceCountText {
    return '$cabinetRemainingSliceCount dilim';
  }

  String get cabinetSoldSliceCountText {
    return '$cabinetSoldSliceCount dilim';
  }

  String get cabinetWastedSliceCountText {
    return '$cabinetWastedSliceCount dilim';
  }

  String get totalWastedSliceCountText {
    return '$totalWastedSliceCount dilim';
  }

  String get totalAvailableSliceCountText {
    return '$totalAvailableSliceCount dilim';
  }


  // =========================================================
  // PARSE
  // =========================================================

  static int _readInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(
            value,
          ) ??
          double.tryParse(
            value.replaceAll(
              ',',
              '.',
            ),
          )?.toInt() ??
          0;
    }

    return 0;
  }


  static double _readDouble(
    dynamic value,
  ) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(
            value.replaceAll(
              ',',
              '.',
            ),
          ) ??
          0.0;
    }

    return 0.0;
  }


  // =========================================================
  // FORMAT HELPERS
  // =========================================================

  static String _formatCurrency(
    double value,
  ) {
    return '${_formatNumber(value)} ₺';
  }

  static String _formatNumber(
    double value,
  ) {
    if (value == value.truncateToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value
        .toStringAsFixed(2)
        .replaceFirst(
          RegExp(r'\.?0+$'),
          '',
        );
  }
}