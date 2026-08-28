class CakeCabinet {
  final int id;

  final int cakeId;

  final String cakeName;

  // Dolaba ilk konulan dilim miktarı
  final int sliceQuantity;

  // Halen dolapta bulunan dilim
  final int remainingQuantity;

  // Satılmış dilim
  final int soldQuantity;

  // Zayi olan dilim
  final int wastedQuantity;

  // Dolaba konulduğu andaki dilim satış fiyatı
  final double sliceSalePrice;

  // İlk girişteki potansiyel ciro
  final double potentialRevenue;

  // Gerçekleşen satış cirosu
  final double realizedRevenue;

  // Dolaba konulma tarihi
  final DateTime createdAt;

  // Bu partinin dolapta geçirdiği gün sayısı
  final int daysInCabinet;

  const CakeCabinet({
    required this.id,
    required this.cakeId,
    required this.cakeName,
    required this.sliceQuantity,
    required this.remainingQuantity,
    required this.soldQuantity,
    required this.wastedQuantity,
    required this.sliceSalePrice,
    required this.potentialRevenue,
    required this.realizedRevenue,
    required this.createdAt,
    required this.daysInCabinet,
  });

  // =========================================================
  // JSON'DAN MODEL OLUŞTUR
  // =========================================================

  factory CakeCabinet.fromJson(
    Map<String, dynamic> json,
  ) {
    return CakeCabinet(
      id: _readInt(
        json['id'],
      ),

      cakeId: _readInt(
        json['cakeId'],
      ),

      cakeName: _readString(
        json['cakeName'],
      ),

      sliceQuantity: _readInt(
        json['sliceQuantity'],
      ),

      remainingQuantity: _readInt(
        json['remainingQuantity'],
      ),

      soldQuantity: _readInt(
        json['soldQuantity'],
      ),

      wastedQuantity: _readInt(
        json['wastedQuantity'],
      ),

      sliceSalePrice: _readDouble(
        json['sliceSalePrice'],
      ),

      potentialRevenue: _readDouble(
        json['potentialRevenue'],
      ),

      realizedRevenue: _readDouble(
        json['realizedRevenue'],
      ),

      createdAt: _readDateTime(
        json['createdAt'],
      ),

      daysInCabinet: _readInt(
        json['daysInCabinet'],
      ),
    );
  }

  // =========================================================
  // INT OKUMA
  // =========================================================

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

  // =========================================================
  // DOUBLE OKUMA
  // =========================================================

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

  // =========================================================
  // STRING OKUMA
  // =========================================================

  static String _readString(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // =========================================================
  // TARİH OKUMA
  // =========================================================

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

  // =========================================================
  // YARDIMCI: KALAN DİLİM
  // =========================================================

  bool get hasRemainingSlices {
    return remainingQuantity > 0;
  }

  // =========================================================
  // YARDIMCI: PARTİ TAMAMLANDI MI?
  // =========================================================

  bool get isCompleted {
    return remainingQuantity <= 0;
  }

  // =========================================================
  // YARDIMCI: DOLAPTA KAÇ GÜNDÜR
  // =========================================================

  String get cabinetDurationText {
    if (daysInCabinet <= 0) {
      return 'Bugün dolaba konuldu';
    }

    if (daysInCabinet == 1) {
      return '1 gündür dolapta';
    }

    return '$daysInCabinet gündür dolapta';
  }

  // =========================================================
  // YARDIMCI: DİLİM DURUMU
  // =========================================================

  String get quantityStatusText {
    if (remainingQuantity <= 0) {
      return 'Partide kalan yok';
    }

    return '$remainingQuantity dilim dolapta';
  }

  // =========================================================
  // JSON'A DÖNÜŞ
  // =========================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cakeId': cakeId,
      'cakeName': cakeName,
      'sliceQuantity': sliceQuantity,
      'remainingQuantity':
          remainingQuantity,
      'soldQuantity': soldQuantity,
      'wastedQuantity':
          wastedQuantity,
      'sliceSalePrice':
          sliceSalePrice,
      'potentialRevenue':
          potentialRevenue,
      'realizedRevenue':
          realizedRevenue,
      'createdAt':
          createdAt.toIso8601String(),
      'daysInCabinet':
          daysInCabinet,
    };
  }
}
