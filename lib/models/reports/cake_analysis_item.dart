class CakeAnalysisItem {
  final int cakeId;
  final String cakeName;

  final int soldSliceCount;
  final double realizedRevenue;

  final int wastedSliceCount;
  final double wasteCost;

  const CakeAnalysisItem({
    required this.cakeId,
    required this.cakeName,
    required this.soldSliceCount,
    required this.realizedRevenue,
    required this.wastedSliceCount,
    required this.wasteCost,
  });

  factory CakeAnalysisItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return CakeAnalysisItem(
      cakeId: _readInt(
        json['cakeId'],
      ),
      cakeName: _readString(
        json['cakeName'],
      ),
      soldSliceCount: _readInt(
        json['soldSliceCount'],
      ),
      realizedRevenue: _readDouble(
        json['realizedRevenue'],
      ),
      wastedSliceCount: _readInt(
        json['wastedSliceCount'],
      ),
      wasteCost: _readDouble(
        json['wasteCost'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cakeId': cakeId,
      'cakeName': cakeName,
      'soldSliceCount': soldSliceCount,
      'realizedRevenue': realizedRevenue,
      'wastedSliceCount': wastedSliceCount,
      'wasteCost': wasteCost,
    };
  }

  String get soldSliceCountText {
    return '$soldSliceCount dilim';
  }

  String get wastedSliceCountText {
    return '$wastedSliceCount dilim';
  }

  String get realizedRevenueText {
    return '${_formatNumber(realizedRevenue)} ₺';
  }

  String get wasteCostText {
    return '${_formatNumber(wasteCost)} ₺';
  }

  double get netRevenue {
    return realizedRevenue - wasteCost;
  }

  String get netRevenueText {
    return '${_formatNumber(netRevenue)} ₺';
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

  static String _readString(
    dynamic value,
  ) {
    return value?.toString() ?? '';
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