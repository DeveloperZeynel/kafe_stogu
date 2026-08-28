class Employee {
  final int id;

  final String username;

  final String role;

  final bool isActive;

  final DateTime createdAt;

  const Employee({
    required this.id,
    required this.username,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  // =========================================================
  // JSON
  // =========================================================

  factory Employee.fromJson(
    Map<String, dynamic> json,
  ) {
    return Employee(
      id: _readInt(
        json['id'],
      ),
      username: _readString(
        json['username'],
      ),
      role: _readString(
        json['role'],
      ),
      isActive: json['isActive'] == true,
      createdAt: _readDateTime(
        json['createdAt'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'isActive': isActive,
      'createdAt':
          createdAt.toIso8601String(),
    };
  }

  // =========================================================
  // YETKİ
  // =========================================================

  bool get isAdmin =>
      role.toLowerCase() == 'admin';

  bool get isEmployee =>
      role.toLowerCase() == 'employee';

  // =========================================================
  // DURUM
  // =========================================================

  String get statusText {
    return isActive
        ? 'Aktif'
        : 'Pasif';
  }

  String get roleText {
    if (isAdmin) {
      return 'Yönetici';
    }

    return 'Çalışan';
  }

  // =========================================================
  // TARİH
  // =========================================================

  String get createdAtText {
    final day =
        createdAt.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final month =
        createdAt.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    final year =
        createdAt.year.toString();

    return '$day.$month.$year';
  }

  // =========================================================
  // PARSE
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
            value.replaceAll(
              ',',
              '.',
            ),
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