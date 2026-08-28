enum ProductStockMovementType {
  initialEntry(
    1,
    'İlk Giriş',
  ),

  stockIn(
    2,
    'Stok Girişi',
  ),

  stockOut(
    3,
    'Stok Çıkışı',
  ),

  adjustment(
    4,
    'Stok Düzeltme',
  );

  final int value;

  final String label;

  const ProductStockMovementType(
    this.value,
    this.label,
  );

  factory ProductStockMovementType.fromJson(
    dynamic value,
  ) {
    final int number;

    if (value is int) {
      number = value;
    } else if (value is num) {
      number = value.toInt();
    } else if (value is String) {
      number =
          int.tryParse(value) ?? 1;
    } else {
      number = 1;
    }

    switch (number) {
      case 2:
        return ProductStockMovementType
            .stockIn;

      case 3:
        return ProductStockMovementType
            .stockOut;

      case 4:
        return ProductStockMovementType
            .adjustment;

      case 1:
      default:
        return ProductStockMovementType
            .initialEntry;
    }
  }
}
