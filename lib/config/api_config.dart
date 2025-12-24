class ApiConfig {
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api/$apiVersion';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoints
  static const String health = '/health';
  static const String register = '$apiPrefix/auth/register';
  static const String login = '$apiPrefix/auth/login';
  static const String profile = '$apiPrefix/profile';
  static const String changePassword = '$apiPrefix/change-password';
  static const String superadminDashboard = '$apiPrefix/superadmin/dashboard';
  static const String superadminTenants = '$apiPrefix/superadmin/tenants';

  // Dynamic endpoints
  static String superadminTenantBranches(int tenantId) =>
      '$apiPrefix/superadmin/tenants/$tenantId/branches';
  static String superadminBranchUsers(int branchId) =>
      '$apiPrefix/superadmin/branches/$branchId/users';
}
