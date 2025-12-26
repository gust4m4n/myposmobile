import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../shared/widgets/app_bar_x.dart';
import '../translations/translation_extension.dart';
import 'dev_branches_service.dart';
import 'dev_tenants_service.dart';
import 'login_service.dart';

class LoginPage extends StatefulWidget {
  final String languageCode;
  final VoidCallback onLanguageToggle;
  final Function(String token) onLoginSuccess;

  const LoginPage({
    super.key,
    required this.languageCode,
    required this.onLanguageToggle,
    required this.onLoginSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginService = LoginService();

  bool _isLoading = false;
  bool _isLoadingTenants = false;
  bool _isLoadingBranches = false;
  bool _obscurePassword = true;

  // Dropdown data
  List<Map<String, dynamic>> _tenants = [];
  List<Map<String, dynamic>> _branches = [];
  Map<String, dynamic>? _selectedTenant;
  Map<String, dynamic>? _selectedBranch;

  @override
  void initState() {
    super.initState();
    _loadTenants();

    // Prefill credentials in debug mode
    if (kDebugMode) {
      _usernameController.text = 'branchadmin';
      _passwordController.text = '123456';
    }
  }

  Future<void> _loadTenants() async {
    setState(() {
      _isLoadingTenants = true;
    });

    final response = await DevTenantsService.getDevTenants();

    if (!mounted) return;

    if (response.isSuccess && response.data != null) {
      setState(() {
        _tenants = response.data!;
      });
    }

    if (mounted) {
      setState(() {
        _isLoadingTenants = false;
      });
    }
  }

  Future<void> _loadBranches(int tenantId) async {
    setState(() {
      _isLoadingBranches = true;
      _selectedBranch = null;
      _branches = [];
    });

    final response = await DevBranchesService.getDevBranches(tenantId);

    if (!mounted) return;

    if (response.isSuccess && response.data != null) {
      setState(() {
        _branches = response.data!;
      });
    }

    if (mounted) {
      setState(() {
        _isLoadingBranches = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await _loginService.login(
      tenantCode: _selectedTenant!['code'] as String,
      branchCode: _selectedBranch!['code'] as String,
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (response.isSuccess && response.data != null) {
      widget.onLoginSuccess(response.data!.token);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TranslationService.setLanguage(widget.languageCode);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBarX(
        title: 'login'.tr,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: 'language'.tr,
            onSelected: (value) {
              widget.onLanguageToggle();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    if (widget.languageCode == 'en')
                      const Icon(Icons.check, size: 20)
                    else
                      const SizedBox(width: 20),
                    const SizedBox(width: 8),
                    Text('english'.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'id',
                child: Row(
                  children: [
                    if (widget.languageCode == 'id')
                      const Icon(Icons.check, size: 20)
                    else
                      const SizedBox(width: 20),
                    const SizedBox(width: 8),
                    Text('indonesian'.tr),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo/Title
                  Icon(
                    Icons.point_of_sale,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'appTitle'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Tenant Dropdown
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedTenant,
                    decoration: InputDecoration(
                      labelText: 'tenantCode'.tr,
                      prefixIcon: const Icon(Icons.business),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                    ),
                    hint: _isLoadingTenants
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('loadingTenants'.tr),
                            ],
                          )
                        : Text('selectTenant'.tr),
                    items: _tenants.map((tenant) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: tenant,
                        child: Text('${tenant['name']} (${tenant['code']})'),
                      );
                    }).toList(),
                    onChanged: _isLoading || _isLoadingTenants
                        ? null
                        : (value) {
                            setState(() {
                              _selectedTenant = value;
                              _selectedBranch = null;
                              _branches = [];
                            });
                            if (value != null) {
                              _loadBranches(value['id'] as int);
                            }
                          },
                    validator: (value) {
                      if (value == null) {
                        return 'pleaseEnterTenantCode'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Branch Dropdown
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedBranch,
                    decoration: InputDecoration(
                      labelText: 'branchCode'.tr,
                      prefixIcon: const Icon(Icons.storefront),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                    ),
                    hint: _isLoadingBranches
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('loadingBranches'.tr),
                            ],
                          )
                        : Text(
                            _selectedTenant == null
                                ? 'selectTenantFirst'.tr
                                : 'selectBranch'.tr,
                          ),
                    items: _branches.map((branch) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: branch,
                        child: Text('${branch['name']} (${branch['code']})'),
                      );
                    }).toList(),
                    onChanged:
                        _isLoading ||
                            _isLoadingBranches ||
                            _selectedTenant == null
                        ? null
                        : (value) {
                            setState(() {
                              _selectedBranch = value;
                            });
                          },
                    validator: (value) {
                      if (value == null) {
                        return 'pleaseEnterBranchCode'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'username'.tr,
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'pleaseEnterUsername'.tr;
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'password'.tr,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'pleaseEnterPassword'.tr;
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: theme.colorScheme.primary
                            .withOpacity(0.6),
                      ),
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'loggingIn'.tr,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'loginButton'.tr,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Version
                  Text(
                    'v1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
