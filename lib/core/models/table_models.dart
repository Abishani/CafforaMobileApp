class TableLookupResponse {
  const TableLookupResponse({
    required this.id,
    required this.tableNumber,
  });

  final int id;
  final String tableNumber;

  factory TableLookupResponse.fromJson(Map<String, dynamic> json) {
    return TableLookupResponse(
      id: (json['id'] as num).toInt(),
      tableNumber: json['tableNumber'] as String? ?? '',
    );
  }
}

class CafeTableResponse {
  const CafeTableResponse({
    required this.id,
    required this.tableNumber,
    required this.qrCodeValue,
  });

  final int id;
  final String tableNumber;
  final String qrCodeValue;

  factory CafeTableResponse.fromJson(Map<String, dynamic> json) {
    return CafeTableResponse(
      id: (json['id'] as num).toInt(),
      tableNumber: json['tableNumber'] as String? ?? '',
      qrCodeValue: json['qrCodeValue'] as String? ?? '',
    );
  }
}
