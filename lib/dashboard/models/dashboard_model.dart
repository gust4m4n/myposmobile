class DashboardModel {
  final int totalTenants;
  final int totalBranches;
  final int totalUsers;
  final int totalProducts;
  final TransactionsStats transactions;

  DashboardModel({
    required this.totalTenants,
    required this.totalBranches,
    required this.totalUsers,
    required this.totalProducts,
    required this.transactions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalTenants: json['total_tenants'] ?? 0,
      totalBranches: json['total_branches'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      totalProducts: json['total_products'] ?? 0,
      transactions: TransactionsStats.fromJson(json['transactions'] ?? {}),
    );
  }
}

class TransactionsStats {
  final double allTime;
  final double today;
  final double thisWeek;
  final double thisMonth;
  final double last7Days;
  final double last30Days;
  final double last90Days;
  final double last180Days;
  final double last360Days;

  TransactionsStats({
    required this.allTime,
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.last7Days,
    required this.last30Days,
    required this.last90Days,
    required this.last180Days,
    required this.last360Days,
  });

  factory TransactionsStats.fromJson(Map<String, dynamic> json) {
    return TransactionsStats(
      allTime: (json['all_time'] ?? 0).toDouble(),
      today: (json['today'] ?? 0).toDouble(),
      thisWeek: (json['this_week'] ?? 0).toDouble(),
      thisMonth: (json['this_month'] ?? 0).toDouble(),
      last7Days: (json['last_7_days'] ?? 0).toDouble(),
      last30Days: (json['last_30_days'] ?? 0).toDouble(),
      last90Days: (json['last_90_days'] ?? 0).toDouble(),
      last180Days: (json['last_180_days'] ?? 0).toDouble(),
      last360Days: (json['last_360_days'] ?? 0).toDouble(),
    );
  }
}
