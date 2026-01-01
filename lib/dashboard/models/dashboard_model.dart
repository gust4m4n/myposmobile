class DashboardModel {
  final int totalTenants;
  final int totalBranches;
  final int totalUsers;
  final int totalProducts;
  final int totalCategories;
  final OrdersStats orders;
  final PaymentsStats payments;
  final TransactionsStats transactions;
  final List<TenantItem> tenants;

  DashboardModel({
    required this.totalTenants,
    required this.totalBranches,
    required this.totalUsers,
    required this.totalProducts,
    required this.totalCategories,
    required this.orders,
    required this.payments,
    required this.transactions,
    required this.tenants,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalTenants: json['total_tenants'] ?? 0,
      totalBranches: json['total_branches'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      totalProducts: json['total_products'] ?? 0,
      totalCategories: json['total_categories'] ?? 0,
      orders: OrdersStats.fromJson(json['orders'] ?? {}),
      payments: PaymentsStats.fromJson(json['payments'] ?? {}),
      transactions: TransactionsStats.fromJson(json['transactions'] ?? {}),
      tenants:
          (json['tenants'] as List<dynamic>?)
              ?.map((item) => TenantItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class OrdersStats {
  final int allTime;
  final int today;
  final int last7Days;
  final int last30Days;
  final int last90Days;
  final int last180Days;
  final int last360Days;

  OrdersStats({
    required this.allTime,
    required this.today,
    required this.last7Days,
    required this.last30Days,
    required this.last90Days,
    required this.last180Days,
    required this.last360Days,
  });

  factory OrdersStats.fromJson(Map<String, dynamic> json) {
    return OrdersStats(
      allTime: json['all_time'] ?? 0,
      today: json['today'] ?? 0,
      last7Days: json['last_7_days'] ?? 0,
      last30Days: json['last_30_days'] ?? 0,
      last90Days: json['last_90_days'] ?? 0,
      last180Days: json['last_180_days'] ?? 0,
      last360Days: json['last_360_days'] ?? 0,
    );
  }
}

class PaymentsStats {
  final double allTime;
  final double today;
  final double last7Days;
  final double last30Days;
  final double last90Days;
  final double last180Days;
  final double last360Days;

  PaymentsStats({
    required this.allTime,
    required this.today,
    required this.last7Days,
    required this.last30Days,
    required this.last90Days,
    required this.last180Days,
    required this.last360Days,
  });

  factory PaymentsStats.fromJson(Map<String, dynamic> json) {
    return PaymentsStats(
      allTime: (json['all_time'] ?? 0).toDouble(),
      today: (json['today'] ?? 0).toDouble(),
      last7Days: (json['last_7_days'] ?? 0).toDouble(),
      last30Days: (json['last_30_days'] ?? 0).toDouble(),
      last90Days: (json['last_90_days'] ?? 0).toDouble(),
      last180Days: (json['last_180_days'] ?? 0).toDouble(),
      last360Days: (json['last_360_days'] ?? 0).toDouble(),
    );
  }
}

class TransactionsStats {
  final double allTime;
  final double today;
  final double last7Days;
  final double last30Days;
  final double last90Days;
  final double last180Days;
  final double last360Days;

  TransactionsStats({
    required this.allTime,
    required this.today,
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
      last7Days: (json['last_7_days'] ?? 0).toDouble(),
      last30Days: (json['last_30_days'] ?? 0).toDouble(),
      last90Days: (json['last_90_days'] ?? 0).toDouble(),
      last180Days: (json['last_180_days'] ?? 0).toDouble(),
      last360Days: (json['last_360_days'] ?? 0).toDouble(),
    );
  }
}

class TenantItem {
  final int id;
  final String name;
  final String description;
  final String address;
  final String website;
  final String email;
  final String phone;
  final String image;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  TenantItem({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.website,
    required this.email,
    required this.phone,
    required this.image,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TenantItem.fromJson(Map<String, dynamic> json) {
    return TenantItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      website: json['website'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
