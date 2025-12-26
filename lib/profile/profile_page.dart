import 'package:flutter/material.dart';

import '../shared/api_models.dart';
import '../shared/widgets/app_bar_x.dart';
import '../translations/translation_extension.dart';
import 'profile_service.dart';

class ProfilePage extends StatefulWidget {
  final String languageCode;

  const ProfilePage({super.key, required this.languageCode});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = ProfileService();
  bool _isLoading = true;
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _profileService.getProfile();

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      setState(() {
        _profile = response.data;
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TranslationService.setLanguage(widget.languageCode);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBarX(title: 'profile'.tr),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
          ? Center(child: Text('noProfileData'.tr))
          : ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
                overscroll: false,
                physics: const ClampingScrollPhysics(),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Header
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 36,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _profile!.user.fullName,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _profile!.user.role.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Information Grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 600;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                // User Information
                                SizedBox(
                                  width: isWide
                                      ? (constraints.maxWidth - 16) / 2
                                      : constraints.maxWidth,
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                size: 20,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'User Information',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          _buildCompactInfoRow(
                                            context,
                                            'Username',
                                            _profile!.user.username,
                                          ),
                                          const SizedBox(height: 12),
                                          _buildCompactInfoRow(
                                            context,
                                            'Email',
                                            _profile!.user.email,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Tenant Information
                                SizedBox(
                                  width: isWide
                                      ? (constraints.maxWidth - 16) / 2
                                      : constraints.maxWidth,
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.business,
                                                size: 20,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Tenant',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          _buildCompactInfoRow(
                                            context,
                                            'Name',
                                            _profile!.tenant.name,
                                          ),
                                          const SizedBox(height: 12),
                                          _buildCompactInfoRow(
                                            context,
                                            'Code',
                                            _profile!.tenant.code,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Branch Information
                                SizedBox(
                                  width: constraints.maxWidth,
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.store,
                                                size: 20,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Branch',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          _buildCompactInfoRow(
                                            context,
                                            'Name',
                                            _profile!.branch.name,
                                          ),
                                          const SizedBox(height: 12),
                                          _buildCompactInfoRow(
                                            context,
                                            'Code',
                                            _profile!.branch.code,
                                          ),
                                          const SizedBox(height: 12),
                                          _buildCompactInfoRow(
                                            context,
                                            'Address',
                                            _profile!.branch.address,
                                          ),
                                          const SizedBox(height: 12),
                                          _buildCompactInfoRow(
                                            context,
                                            'Phone',
                                            _profile!.branch.phone,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCompactInfoRow(
    BuildContext context,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
