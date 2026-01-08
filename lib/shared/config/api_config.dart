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

  // Category endpoints
  static const String categories = '$apiPrefix/categories';

  // Order endpoints
  static const String orders = '$apiPrefix/orders';

  // Payment endpoints
  static const String payments = '$apiPrefix/payments';

  // PIN endpoints
  static const String pinCreate = '$apiPrefix/pin/create';
  static const String pinChange = '$apiPrefix/pin/change';
  static const String pinCheck = '$apiPrefix/pin/check';

  // Branch endpoints (Tenant Admin)
  static const String branches = '$apiPrefix/branches';

  // Tenant endpoints (Authenticated users - accessible by all authenticated users)
  static const String tenants = '$apiPrefix/tenants';

  // Dashboard endpoint (all authenticated users)
  static const String dashboard = '$apiPrefix/dashboard';

  // FAQ endpoints (public read, authenticated write)
  static const String faq = '$apiPrefix/faq';

  // Terms & Conditions endpoints (public)
  static const String tnc = '$apiPrefix/tnc';

  // Dynamic endpoints
  static String devTenantBranches(int tenantId) =>
      '/dev/tenants/$tenantId/branches';

  // FAQ dynamic endpoints
  static String faqById(int id) => '$apiPrefix/faq/$id';

  // TnC dynamic endpoints
  static String tncById(int id) => '$apiPrefix/tnc/$id';

  // Branch dynamic endpoints (Tenant Admin)
  static String branchById(int id) => '$apiPrefix/branches/$id';
  static String branchUsers(int branchId) =>
      '$apiPrefix/branches/$branchId/users';

  // Tenant dynamic endpoints (Authenticated users)
  static String tenantById(int id) => '$apiPrefix/tenants/$id';
}
