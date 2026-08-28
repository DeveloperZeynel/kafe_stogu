class Category {
  final int id;

  final String name;

  final bool isActive;

  final DateTime createdAt;

  final int productCount;

  const Category({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.productCount,
  });

  factory Category.fromJson(
    Map<String, dynamic> json,
  ) {
    return Category(
      id: _readInt(
        json['id'],
      ),
      name: _readString(
        json['name'],
      ),
      isActive:
          json['isActive'] == true,
      createdAt: _readDateTime(
        json['createdAt'],
      ),
      productCount: _readInt(
        json['productCount'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'createdAt':
          createdAt.toIso8601String(),
      'productCount': productCount,
    };
  }

  String get productCountText {
    if (productCount == 1) {
      return '1 ürün';
    }

    return '$productCount ürün';
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
}
