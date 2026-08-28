import 'cake_analysis_item.dart';

class CakeAnalysis {
  final DateTime startDate;
  final DateTime endDate;

  final List<CakeAnalysisItem> cakes;

  const CakeAnalysis({
    required this.startDate,
    required this.endDate,
    required this.cakes,
  });

  factory CakeAnalysis.fromJson(
    Map<String, dynamic> json,
  ) {
    return CakeAnalysis(
      startDate: _readDateTime(
        json['startDate'],
      ),
      endDate: _readDateTime(
        json['endDate'],
      ),
      cakes: _readCakes(
        json['cakes'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate':
          startDate.toIso8601String(),
      'endDate':
          endDate.toIso8601String(),
      'cakes': cakes
          .map(
            (cake) => cake.toJson(),
          )
          .toList(),
    };
  }

  // =========================================================
  // TOPLAM SATIŞ
  // =========================================================

  int get totalSoldSliceCount {
    return cakes.fold(
      0,
      (
        total,
        cake,
      ) =>
          total +
          cake.soldSliceCount,
    );
  }

  // =========================================================
  // TOPLAM CİRO
  // =========================================================

  double get totalRealizedRevenue {
    return cakes.fold(
      0.0,
      (
        total,
        cake,
      ) =>
          total +
          cake.realizedRevenue,
    );
  }

  // =========================================================
  // TOPLAM ZAYİ
  // =========================================================

  int get totalWastedSliceCount {
    return cakes.fold(
      0,
      (
        total,
        cake,
      ) =>
          total +
          cake.wastedSliceCount,
    );
  }

  // =========================================================
  // TOPLAM ZAYİ MALİYETİ
  // =========================================================

  double get totalWasteCost {
    return cakes.fold(
      0.0,
      (
        total,
        cake,
      ) =>
          total +
          cake.wasteCost,
    );
  }

  // =========================================================
  // EN ÇOK SATAN
  // =========================================================

  List<CakeAnalysisItem> get topSellingCakes {
    final items =
        List<CakeAnalysisItem>.from(
      cakes,
    );

    items.sort(
      (
        a,
        b,
      ) =>
          b.soldSliceCount.compareTo(
        a.soldSliceCount,
      ),
    );

    return items;
  }

  // =========================================================
  // EN ÇOK ZAYİ
  // =========================================================

  List<CakeAnalysisItem> get topWastedCakes {
    final items =
        List<CakeAnalysisItem>.from(
      cakes,
    );

    items.sort(
      (
        a,
        b,
      ) =>
          b.wastedSliceCount.compareTo(
        a.wastedSliceCount,
      ),
    );

    return items;
  }

  // =========================================================
  // FORMAT
  // =========================================================

  String get totalSoldSliceCountText {
    return '$totalSoldSliceCount dilim';
  }

  String get totalWastedSliceCountText {
    return '$totalWastedSliceCount dilim';
  }

  String get totalRealizedRevenueText {
    return '${_formatNumber(totalRealizedRevenue)} ₺';
  }

  String get totalWasteCostText {
    return '${_formatNumber(totalWasteCost)} ₺';
  }

  // =========================================================
  // JSON HELPERS
  // =========================================================

  static List<CakeAnalysisItem>
      _readCakes(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (
            item,
          ) =>
              CakeAnalysisItem.fromJson(
            Map<String, dynamic>.from(
              item,
            ),
          ),
        )
        .toList();
  }

  static DateTime _readDateTime(
    dynamic value,
  ) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(
            value,
          ) ??
          DateTime.fromMillisecondsSinceEpoch(
            0,
            isUtc: true,
          );
    }

    return DateTime.fromMillisecondsSinceEpoch(
      0,
      isUtc: true,
    );
  }

  static String _formatNumber(
    double value,
  ) {
    if (value ==
        value.truncateToDouble()) {
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