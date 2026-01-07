import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import '../../audit-trails/views/audit_trails_page.dart';
import '../../branches/views/branches_management_page.dart';
import '../../change-password/views/change_password_dialog.dart';
import '../../dashboard/views/dashboard_page.dart';
import '../../faq/views/faq_page.dart';
import '../../orders/views/orders_page.dart';
import '../../payments/views/payments_page.dart';
import '../../pin/services/pin_service.dart';
import '../../pin/views/pin_dialog.dart';
import '../../products/views/products_management_page.dart';
import '../../profile/views/profile_page.dart';
import '../../shared/api_models.dart';
import '../../shared/controllers/auth_controller.dart';
import '../../shared/controllers/language_controller.dart';
import '../../shared/controllers/profile_controller.dart';
import '../../shared/controllers/theme_controller.dart';
import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/connectivity_indicator.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/gray_button_x.dart';
import '../../shared/widgets/red_button_x.dart';
import '../../shared/widgets/theme_toggle_button.dart';
import '../../tenants/views/tenants_management_page.dart';
import '../../tnc/views/tnc_page.dart';
import '../../translations/translation_extension.dart';
import '../../users/views/users_management_page.dart';

class MenuTab extends StatelessWidget {
  final String languageCode;
  final ProfileModel? profile;
  final VoidCallback onProfileUpdated;
  final VoidCallback onProductsUpdated;

  const MenuTab({
    super.key,
    required this.languageCode,
    required this.profile,
    required this.onProfileUpdated,
    required this.onProductsUpdated,
  });

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TranslationService.setLanguage(languageCode);

    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        // Connectivity & Theme Section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              const ConnectivityIndicator(),
              const Spacer(),
              const ThemeToggleButton(),
              const SizedBox(width: 8),
              // User Profile Photo
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(languageCode: languageCode),
                    ),
                  );
                  onProfileUpdated();
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary,
                  backgroundImage:
                      profile?.user.image != null &&
                          profile!.user.image!.isNotEmpty
                      ? NetworkImage(
                          profile!.user.image!.startsWith('http')
                              ? profile!.user.image!
                              : 'http://localhost:8080${profile!.user.image!}',
                        )
                      : null,
                  child:
                      profile?.user.image == null ||
                          profile!.user.image!.isEmpty
                      ? const Icon(Icons.person, size: 20, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ),
        // Profile Header
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(languageCode: languageCode),
              ),
            ).then((_) => onProfileUpdated());
          },
          child: Container(
            color: theme.colorScheme.primary,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      profile?.user.image != null &&
                          profile!.user.image!.isNotEmpty
                      ? NetworkImage(
                          profile!.user.image!.startsWith('http')
                              ? profile!.user.image!
                              : 'http://localhost:8080${profile!.user.image!}',
                        )
                      : null,
                  child:
                      profile?.user.image == null ||
                          profile!.user.image!.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 24,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.user.fullName ?? 'user'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile?.user.email ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Dashboard
        ListTile(
          leading: Icon(
            Icons.dashboard_outlined,
            color: theme.colorScheme.onSurface,
          ),
          title: const Text('Dashboard'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          },
        ),
        Divider(color: theme.dividerColor, height: 1),
        // Account Section
        _buildSectionHeader(context, 'Account'),
        ListTile(
          leading: Icon(Icons.lock_outline, color: theme.colorScheme.onSurface),
          title: Text('changePassword'.tr),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) =>
                  ChangePasswordDialog(languageCode: languageCode),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.lock_outline, color: theme.colorScheme.onSurface),
          title: Text('changePin'.tr),
          onTap: () async {
            final statusResponse = await PinService.checkPinStatus();
            final hasPin =
                statusResponse.statusCode == 200 &&
                statusResponse.data?['has_pin'] == true;
            if (!context.mounted) return;
            showDialog(
              context: context,
              builder: (context) =>
                  PinDialog(languageCode: languageCode, hasExistingPin: hasPin),
            );
          },
        ),
        Divider(color: theme.dividerColor, height: 1),
        // Transactions Section
        _buildSectionHeader(context, 'Transactions'),
        ListTile(
          leading: Icon(
            Icons.shopping_bag_outlined,
            color: theme.colorScheme.onSurface,
          ),
          title: Text('orders'.tr),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrdersPage(languageCode: languageCode),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(
            Icons.payment_outlined,
            color: theme.colorScheme.onSurface,
          ),
          title: Text('payments'.tr),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentsPage(languageCode: languageCode),
              ),
            );
          },
        ),
        Divider(color: theme.dividerColor, height: 1),
        // Management Section
        _buildSectionHeader(context, 'Management'),
        ListTile(
          leading: Icon(Icons.business, color: theme.colorScheme.onSurface),
          title: Text('tenantsManagement'.tr),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TenantsManagementPage(languageCode: languageCode),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.store, color: theme.colorScheme.onSurface),
          title: Text('branchesManagement'.tr),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BranchesManagementPage(languageCode: languageCode),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(
            Icons.inventory_2_outlined,
            color: theme.colorScheme.onSurface,
          ),
          title: Text('productsManagement'.tr),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductsManagementPage(languageCode: languageCode),
              ),
            );
            onProductsUpdated();
          },
        ),
        ListTile(
          leading: Icon(
            Icons.people_outline,
            color: theme.colorScheme.onSurface,
          ),
          title: Text('userManagement'.tr),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    UsersManagementPage(languageCode: languageCode),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.history, color: theme.colorScheme.onSurface),
          title: Text('auditTrails'.tr),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AuditTrailsPage(languageCode: languageCode),
              ),
            );
          },
        ),
        Divider(color: theme.dividerColor, height: 1),
        // Help & Support Section
        _buildSectionHeader(context, 'Help & Support'),
        ListTile(
          leading: Icon(Icons.help_outline, color: theme.colorScheme.onSurface),
          title: Text('faq'.tr),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FaqPage(languageCode: languageCode),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(
            Icons.description_outlined,
            color: theme.colorScheme.onSurface,
          ),
          title: Text('termsAndConditions'.tr),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TncPage(languageCode: languageCode),
              ),
            );
          },
        ),
        Divider(color: theme.dividerColor, height: 1),
        // Settings Section
        _buildSectionHeader(context, 'Settings'),
        ListTile(
          leading: Icon(Icons.language, color: theme.colorScheme.onSurface),
          title: Row(
            children: [
              Text('language'.tr),
              const SizedBox(width: 8),
              Text(
                languageCode == 'en' ? '(English)' : '(Indonesia)',
                style: TextStyle(
                  fontSize: 14.0,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          onTap: () async {
            final selectedLanguage = await showDialog<String>(
              context: context,
              builder: (context) => DialogX(
                title: 'selectLanguage'.tr,
                width: 400,
                onClose: () => Navigator.pop(context),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: languageCode == 'en'
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.circle_outlined),
                      title: Text('english'.tr),
                      onTap: () => Navigator.pop(context, 'en'),
                      selected: languageCode == 'en',
                    ),
                    ListTile(
                      leading: languageCode == 'id'
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.circle_outlined),
                      title: Text('indonesian'.tr),
                      onTap: () => Navigator.pop(context, 'id'),
                      selected: languageCode == 'id',
                    ),
                  ],
                ),
                actions: [
                  ButtonX(
                    onClicked: () => Navigator.pop(context),
                    label: 'close'.tr,
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                ],
              ),
            );
            if (selectedLanguage != null && selectedLanguage != languageCode) {
              Get.find<LanguageController>().toggleLanguage();
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.brightness_6, color: theme.colorScheme.onSurface),
          title: Row(
            children: [
              const Text('Theme'),
              const Spacer(),
              const ThemeToggleButton(),
            ],
          ),
          onTap: () {
            Get.find<ThemeController>().toggleTheme();
          },
        ),
        Divider(color: theme.dividerColor, height: 1),
        // Logout
        ListTile(
          leading: Icon(Icons.logout, color: theme.colorScheme.error),
          title: Text(
            'logout'.tr,
            style: TextStyle(color: theme.colorScheme.error),
          ),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => DialogX(
                title: 'logout'.tr,
                width: 400,
                onClose: () => Navigator.pop(context, false),
                content: Text('logoutConfirmation'.tr),
                actions: [
                  GrayButtonX(
                    onClicked: () => Navigator.pop(context, false),
                    title: 'cancel'.tr,
                  ),
                  RedButtonX(
                    onClicked: () => Navigator.pop(context, true),
                    title: 'logout'.tr,
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              final authController = Get.find<AuthController>();
              final profileController = Get.find<ProfileController>();
              await authController.logout();
              profileController.clearProfile();
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
