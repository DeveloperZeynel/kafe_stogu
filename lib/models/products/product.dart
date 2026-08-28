import 'product_unit_type.dart';

class Product {
  final int id;

  final String name;

  final int categoryId;

  final String categoryName;

  final ProductUnitType unitType;

  final double currentStock;

  final double minimumStock;

  final bool isLowStock;

  final bool isActive;

  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.unitType,
    required this.currentStock,
    required this.minimumStock,
    required this.isLowStock,
    required this.isActive,
    required this.createdAt,
  });

  factory Product.fromJson(
    Map<String, dynamic> json,
  ) {
    return Product(
      id: _readInt(
        json['id'],
      ),
      name: _readString(
        json['name'],
      ),
      categoryId: _readInt(
        json['categoryId'],
      ),
      categoryName: _readString(
        json['categoryName'],
      ),
      unitType: ProductUnitType.fromJson(
        json['unitType'],
      ),
      currentStock: _readDouble(
        json['currentStock'],
      ),
      minimumStock: _readDouble(
        json['minimumStock'],
      ),
      isLowStock:
          json['isLowStock'] == true,
      isActive:
          json['isActive'] == true,
      createdAt: _readDateTime(
        json['createdAt'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'unitType':
          unitType.value,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'isLowStock': isLowStock,
      'isActive': isActive,
      'createdAt':
          createdAt.toIso8601String(),
    };
  }

  String get unitText {
    return unitType.label;
  }

  String get stockText {
    return '${_formatNumber(currentStock)} $unitText';
  }

  String get minimumStockText {
    return '${_formatNumber(minimumStock)} $unitText';
  }

  String get statusText {
    if (isLowStock) {
      return 'Düşük stok';
    }

    return 'Stok yeterli';
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
                value,
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
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(2)
        .replaceFirst(
          RegExp(r'\.?0+$'),
          '',
        );
  }
}
