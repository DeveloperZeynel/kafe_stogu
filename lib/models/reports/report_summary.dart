import 'top_selling_cake.dart';

class ReportSummary {
  final DateTime startDate;

  final DateTime endDate;


  // =========================================================
  // SATIŞ
  // =========================================================

  final int totalSoldSliceCount;

  final double totalRealizedRevenue;


  // =========================================================
  // ZAYİ
  // =========================================================

  final int totalWastedSliceCount;

  final double totalWasteCost;


  // =========================================================
  // DOLAP
  // =========================================================

  final int totalCabinetSliceCount;


  // =========================================================
  // EN ÇOK SATILAN PASTALAR
  // =========================================================

  final List<TopSellingCake>
      topSellingCakes;


  const ReportSummary({
    required this.startDate,
    required this.endDate,
    required this.totalSoldSliceCount,
    required this.totalRealizedRevenue,
    required this.totalWastedSliceCount,
    required this.totalWasteCost,
    required this.totalCabinetSliceCount,
    required this.topSellingCakes,
  });


  factory ReportSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportSummary(
      startDate: _readDateTime(
        json['startDate'],
      ),
      endDate: _readDateTime(
        json['endDate'],
      ),
      totalSoldSliceCount: _readInt(
        json['totalSoldSliceCount'],
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
      totalCabinetSliceCount: _readInt(
        json['totalCabinetSliceCount'],
      ),
      topSellingCakes:
          _readTopSellingCakes(
        json['topSellingCakes'],
      ),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'startDate':
          startDate.toIso8601String(),
      'endDate':
          endDate.toIso8601String(),
      'totalSoldSliceCount':
          totalSoldSliceCount,
      'totalRealizedRevenue':
          totalRealizedRevenue,
      'totalWastedSliceCount':
          totalWastedSliceCount,
      'totalWasteCost':
          totalWasteCost,
      'totalCabinetSliceCount':
          totalCabinetSliceCount,
      'topSellingCakes':
          topSellingCakes
              .map(
                (cake) =>
                    cake.toJson(),
              )
              .toList(),
    };
  }


  // =========================================================
  // YARDIMCI TEXTLER
  // =========================================================

  String get totalSoldSliceCountText {
    return '$totalSoldSliceCount dilim';
  }

  String get totalWastedSliceCountText {
    return '$totalWastedSliceCount dilim';
  }

  String get totalCabinetSliceCountText {
    return '$totalCabinetSliceCount dilim';
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

  static List<TopSellingCake>
      _readTopSellingCakes(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) =>
              TopSellingCake.fromJson(
            Map<String, dynamic>.from(
              item,
            ),
          ),
        )
        .toList();
  }


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