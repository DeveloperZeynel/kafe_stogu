class CakeSummary {
  final int id;
  final String name;
  final int initialSliceCount;
  final int currentSliceStock;
  final double slicePurchasePrice;
  final double sliceSalePrice;
  final int totalCabinetSlices;
  final int totalWasteSlices;
  final double totalWasteCost;
  final double potentialRevenue;

  CakeSummary({
    required this.id,
    required this.name,
    required this.initialSliceCount,
    required this.currentSliceStock,
    required this.slicePurchasePrice,
    required this.sliceSalePrice,
    required this.totalCabinetSlices,
    required this.totalWasteSlices,
    required this.totalWasteCost,
    required this.potentialRevenue,
  });

  factory CakeSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return CakeSummary(
      id: json['id'] as int,
      name: json['name'] as String,
      initialSliceCount:
          json['initialSliceCount'] as int,
      currentSliceStock:
          json['currentSliceStock'] as int,
      slicePurchasePrice:
          (json['slicePurchasePrice'] as num)
              .toDouble(),
      sliceSalePrice:
          (json['sliceSalePrice'] as num)
              .toDouble(),
      totalCabinetSlices:
          json['totalCabinetSlices'] as int,
      totalWasteSlices:
          json['totalWasteSlices'] as int,
      totalWasteCost:
          (json['totalWasteCost'] as num)
              .toDouble(),
      potentialRevenue:
          (json['potentialRevenue'] as num)
              .toDouble(),
    );
  }
}