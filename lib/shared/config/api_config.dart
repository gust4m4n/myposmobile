class ApiConfig {
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api/$apiVersion';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoints
  static const String health = '/health';

  // Dev endpoints (public, no auth)
  static const String devTenants = '/dev/tenants';

  // Auth endpoints
  static const String register = '$apiPrefix/auth/register';
  static const String login = '$apiPrefix/auth/login';

  // User endpoints
  static const String profile = '$apiPrefix/profile';
  static const String changePassword = '$apiPrefix/change-password';

  // Product endpoints
  static const String products = '$apiPrefix/products';

  // Order endpoints
  static const String orders = '$apiPrefix/orders';

  // Payment endpoints
  static const String payments = '$apiPrefix/payments';

  // Superadmin endpoints
  static const String superadminDashboard = '$apiPrefix/superadmin/dashboard';
  static const String superadminTenants = '$apiPrefix/superadmin/tenants';

  // FAQ endpoints (public)
  static const String faq = '$apiPrefix/faq';

  // Superadmin FAQ endpoints
  static const String superadminFaq = '$apiPrefix/superadmin/faq';

  // Terms & Conditions endpoints (public)
  static const String tnc = '$apiPrefix/tnc';
  static const String tncActive = '$apiPrefix/tnc/active';

  // Superadmin TnC endpoints
  static const String superadminTnc = '$apiPrefix/superadmin/tnc';

  // Dynamic endpoints
  static String devTenantBranches(int tenantId) =>
      '/dev/tenants/$tenantId/branches';
  static String superadminTenantBranches(int tenantId) =>
      '$apiPrefix/superadmin/tenants/$tenantId/branches';
  static String superadminBranchUsers(int branchId) =>
      '$apiPrefix/superadmin/branches/$branchId/users';

  // FAQ dynamic endpoints
  static String faqById(int id) => '$apiPrefix/faq/$id';
  static String superadminFaqById(int id) => '$apiPrefix/superadmin/faq/$id';

  // TnC dynamic endpoints
  static String tncById(int id) => '$apiPrefix/tnc/$id';
  static String superadminTncById(int id) => '$apiPrefix/superadmin/tnc/$id';
}
