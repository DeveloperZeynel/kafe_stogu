class TopSellingCake {
  final int cakeId;

  final String cakeName;

  final int soldSliceCount;

  final double revenue;

  const TopSellingCake({
    required this.cakeId,
    required this.cakeName,
    required this.soldSliceCount,
    required this.revenue,
  });

  factory TopSellingCake.fromJson(
    Map<String, dynamic> json,
  ) {
    return TopSellingCake(
      cakeId: _readInt(
        json['cakeId'],
      ),
      cakeName: _readString(
        json['cakeName'],
      ),
      soldSliceCount: _readInt(
        json['soldSliceCount'],
      ),
      revenue: _readDouble(
        json['revenue'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cakeId': cakeId,
      'cakeName': cakeName,
      'soldSliceCount': soldSliceCount,
      'revenue': revenue,
    };
  }

  String get soldSliceCountText {
    return '$soldSliceCount dilim';
  }

  String get revenueText {
    return '${_formatNumber(revenue)} ₺';
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