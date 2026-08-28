import 'product_stock_movement_type.dart';

class ProductStockMovement {
  final int id;

  final int productId;

  final String productName;

  final double quantity;

  final ProductStockMovementType movementType;

  final double previousStock;

  final double newStock;

  final String? note;

  final DateTime createdAt;

  const ProductStockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.movementType,
    required this.previousStock,
    required this.newStock,
    required this.note,
    required this.createdAt,
  });

  factory ProductStockMovement.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductStockMovement(
      id: _readInt(
        json['id'],
      ),
      productId: _readInt(
        json['productId'],
      ),
      productName: _readString(
        json['productName'],
      ),
      quantity: _readDouble(
        json['quantity'],
      ),
      movementType:
          ProductStockMovementType.fromJson(
        json['movementType'],
      ),
      previousStock: _readDouble(
        json['previousStock'],
      ),
      newStock: _readDouble(
        json['newStock'],
      ),
      note: _readNullableString(
        json['note'],
      ),
      createdAt: _readDateTime(
        json['createdAt'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'movementType':
          movementType.value,
      'previousStock':
          previousStock,
      'newStock': newStock,
      'note': note,
      'createdAt':
          createdAt.toIso8601String(),
    };
  }

  String get movementTypeText {
    return movementType.label;
  }

  String get quantityText {
    return _formatNumber(
      quantity,
    );
  }

  String get previousStockText {
    return _formatNumber(
      previousStock,
    );
  }

  String get newStockText {
    return _formatNumber(
      newStock,
    );
  }

  bool get increasesStock {
    return movementType ==
        ProductStockMovementType.initialEntry ||
        movementType ==
            ProductStockMovementType.stockIn;
  }

  bool get decreasesStock {
    return movementType ==
        ProductStockMovementType.stockOut;
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

  static String? _readNullableString(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final text =
        value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
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
