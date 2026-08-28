enum ProductUnitType {
  piece(1, 'Adet'),
  box(2, 'Kutu');

  final int value;
  final String label;

  const ProductUnitType(
    this.value,
    this.label,
  );

  factory ProductUnitType.fromJson(
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
        return ProductUnitType.box;

      case 1:
      default:
        return ProductUnitType.piece;
    }
  }
}