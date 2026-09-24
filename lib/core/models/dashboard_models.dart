class DashboardResponse {
  const DashboardResponse({
    required this.todaysGrossSales,
    required this.activeOrderCount,
    required this.pendingCount,
    required this.preparingCount,
    required this.readyCount,
    required this.avgPrepMinutes,
  });

  final double todaysGrossSales;
  final int activeOrderCount;
  final int pendingCount;
  final int preparingCount;
  final int readyCount;
  final double avgPrepMinutes;

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      todaysGrossSales: (json['todaysGrossSales'] as num?)?.toDouble() ?? 0.0,
      activeOrderCount: (json['activeOrderCount'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
      preparingCount: (json['preparingCount'] as num?)?.toInt() ?? 0,
      readyCount: (json['readyCount'] as num?)?.toInt() ?? 0,
      avgPrepMinutes: (json['avgPrepMinutes'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
