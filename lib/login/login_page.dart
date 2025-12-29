import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:package_info_plus/package_info_plus.dart';

import '../faq/faq_page.dart';
import '../shared/controllers/language_controller.dart';
import '../shared/widgets/app_bar_x.dart';
import '../shared/widgets/button_x.dart';
import '../shared/widgets/dialog_x.dart';
import '../tnc/tnc_page.dart';
import '../translations/translation_extension.dart';
import 'login_controller.dart';

class LoginPage extends StatelessWidget {
  final String languageCode;

  const LoginPage({super.key, required this.languageCode});

  @override
  Widget build(BuildContext context) {
    final loginController = Get.put(LoginController());
    final languageCtrl = Get.find<LanguageController>();
    final theme = Theme.of(context);

    // Prefill credentials in debug mode
    if (kDebugMode) {
      loginController.usernameController.text = 'branchadmin';
      loginController.passwordController.text = '123456';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBarX(
        title: 'login'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'language'.tr,
            onPressed: () async {
              TranslationService.setLanguage(languageCtrl.languageCode.value);
              // Show language selection dialog
              final selectedLanguage = await showDialog<String>(
                context: context,
                builder: (context) => DialogX(
                  title: 'selectLanguage'.tr,
                  width: 400,
                  onClose: () => Get.back(),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => ListTile(
                          leading: languageCtrl.languageCode.value == 'en'
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : const Icon(Icons.circle_outlined),
                          title: Text('english'.tr),
                          onTap: () => Get.back(result: 'en'),
                          selected: languageCtrl.languageCode.value == 'en',
                        ),
                      ),
                      Obx(
                        () => ListTile(
                          leading: languageCtrl.languageCode.value == 'id'
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : const Icon(Icons.circle_outlined),
                          title: Text('indonesian'.tr),
                          onTap: () => Get.back(result: 'id'),
                          selected: languageCtrl.languageCode.value == 'id',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    ButtonX(
                      onPressed: () => Get.back(),
                      icon: Icons.close,
                      label: 'close'.tr,
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
                    ),
                  ],
                ),
              );

              if (selectedLanguage != null &&
                  selectedLanguage != languageCtrl.languageCode.value) {
                languageCtrl.toggleLanguage();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: loginController.formKey,
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
                  Obx(() {
                    TranslationService.setLanguage(
                      languageCtrl.languageCode.value,
                    );
                    return Text(
                      'appTitle'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    );
                  }),
                  const SizedBox(height: 48),

                  // Tenant Dropdown
                  _buildTenantDropdown(context, loginController, theme),
                  const SizedBox(height: 16),

                  // Branch Dropdown
                  _buildBranchDropdown(context, loginController, theme),
                  const SizedBox(height: 16),

                  // Username Field
                  _buildUsernameField(context, loginController, theme),
                  const SizedBox(height: 16),

                  // Password Field
                  _buildPasswordField(context, loginController, theme),
                  const SizedBox(height: 32),

                  // Login Button
                  _buildLoginButton(context, loginController, theme),

                  const SizedBox(height: 32),

                  // TnC, FAQ, and App Version
                  _buildFooter(context, languageCtrl, loginController),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTenantDropdown(
    BuildContext context,
    LoginController controller,
    ThemeData theme,
  ) {
    TranslationService.setLanguage(languageCode);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(
      () => DropdownButtonFormField<Map<String, dynamic>>(
        value: controller.selectedTenant.value,
        decoration: InputDecoration(
          labelText: 'tenantCode'.tr,
          prefixIcon: const Icon(Icons.business),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
        ),
        hint: controller.isLoadingTenants.value
            ? Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text('loadingTenants'.tr),
                ],
              )
            : Text('selectTenant'.tr),
        items: controller.tenants.map((tenant) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: tenant,
            child: Text('${tenant['name']} (${tenant['code']})'),
          );
        }).toList(),
        onChanged:
            controller.isLoading.value || controller.isLoadingTenants.value
            ? null
            : (value) {
                controller.selectedTenant.value = value;
                if (value != null) {
                  controller.loadBranches(value['id'] as int);
                }
              },
        validator: (value) {
          if (value == null) {
            return 'pleaseEnterTenantCode'.tr;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildBranchDropdown(
    BuildContext context,
    LoginController controller,
    ThemeData theme,
  ) {
    TranslationService.setLanguage(languageCode);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(
      () => DropdownButtonFormField<Map<String, dynamic>>(
        value: controller.selectedBranch.value,
        decoration: InputDecoration(
          labelText: 'branchCode'.tr,
          prefixIcon: const Icon(Icons.storefront),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
        ),
        hint: controller.isLoadingBranches.value
            ? Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text('loadingBranches'.tr),
                ],
              )
            : Text(
                controller.selectedTenant.value == null
                    ? 'selectTenantFirst'.tr
                    : 'selectBranch'.tr,
              ),
        items: controller.branches.map((branch) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: branch,
            child: Text('${branch['name']} (${branch['code']})'),
          );
        }).toList(),
        onChanged:
            controller.isLoading.value ||
                controller.isLoadingBranches.value ||
                controller.selectedTenant.value == null
            ? null
            : (value) {
                controller.selectedBranch.value = value;
              },
        validator: (value) {
          if (value == null) {
            return 'pleaseEnterBranchCode'.tr;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildUsernameField(
    BuildContext context,
    LoginController controller,
    ThemeData theme,
  ) {
    TranslationService.setLanguage(languageCode);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(
      () => TextFormField(
        controller: controller.usernameController,
        decoration: InputDecoration(
          labelText: 'username'.tr,
          prefixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'pleaseEnterUsername'.tr;
          }
          return null;
        },
        enabled: !controller.isLoading.value,
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context,
    LoginController controller,
    ThemeData theme,
  ) {
    TranslationService.setLanguage(languageCode);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(
      () => TextFormField(
        controller: controller.passwordController,
        obscureText: controller.obscurePassword.value,
        decoration: InputDecoration(
          labelText: 'password'.tr,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(
              controller.obscurePassword.value
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'pleaseEnterPassword'.tr;
          }
          return null;
        },
        enabled: !controller.isLoading.value,
      ),
    );
  }

  Widget _buildLoginButton(
    BuildContext context,
    LoginController controller,
    ThemeData theme,
  ) {
    TranslationService.setLanguage(languageCode);

    return Obx(
      () => SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.login,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.6),
          ),
          child: controller.isLoading.value
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
    );
  }

  Widget _buildFooter(
    BuildContext context,
    LanguageController languageCtrl,
    LoginController loginController,
  ) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final appVersion = snapshot.hasData
            ? 'v${snapshot.data!.version}'
            : 'v1.0.0';
        final theme = Theme.of(context);

        return Obx(() {
          TranslationService.setLanguage(languageCtrl.languageCode.value);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: loginController.isLoading.value
                    ? null
                    : () {
                        Get.to(
                          () => TncPage(
                            languageCode: languageCtrl.languageCode.value,
                          ),
                        );
                      },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                child: Text('termsAndConditions'.tr),
              ),
              Text(
                ' | ',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              TextButton(
                onPressed: loginController.isLoading.value
                    ? null
                    : () {
                        Get.to(
                          () => FaqPage(
                            languageCode: languageCtrl.languageCode.value,
                          ),
                        );
                      },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                child: Text('faq'.tr),
              ),
              Text(
                ' | ',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              Text(
                appVersion,
                style: TextStyle(
                  fontSize: 16.0,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
