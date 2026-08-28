class Cake {
  final int id;
  final String name;
  final int initialSliceCount;
  final int slicesPerBox;
  final double boxPurchasePrice;
  final double slicePurchasePrice;
  final double sliceSalePrice;
  final int currentSliceStock;
  final bool isActive;
  final DateTime createdAt;

  const Cake({
    required this.id,
    required this.name,
    required this.initialSliceCount,
    required this.slicesPerBox,
    required this.boxPurchasePrice,
    required this.slicePurchasePrice,
    required this.sliceSalePrice,
    required this.currentSliceStock,
    required this.isActive,
    required this.createdAt,
  });

  factory Cake.fromJson(
    Map<String, dynamic> json,
  ) {
    return Cake(
      id: json['id'] as int,
      name: json['name'] as String,
      initialSliceCount:
          json['initialSliceCount'] as int,
      slicesPerBox:
          json['slicesPerBox'] as int,
      boxPurchasePrice:
          (json['boxPurchasePrice'] as num)
              .toDouble(),
      slicePurchasePrice:
          (json['slicePurchasePrice'] as num)
              .toDouble(),
      sliceSalePrice:
          (json['sliceSalePrice'] as num)
              .toDouble(),
      currentSliceStock:
          json['currentSliceStock'] as int,
      isActive:
          json['isActive'] as bool,
      createdAt:
          DateTime.parse(
        json['createdAt'] as String,
      ),
    );
  }
}