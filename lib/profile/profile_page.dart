import 'package:flutter/material.dart';

import '../shared/api_models.dart';
import '../shared/config/api_config.dart';
import '../shared/widgets/app_bar_x.dart';
import '../translations/translation_extension.dart';
import 'edit_profile_dialog.dart';
import 'profile_service.dart';
import 'upload_profile_photo_dialog.dart';

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

  Future<void> _showEditProfileDialog() async {
    if (_profile == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditProfileDialog(
        languageCode: widget.languageCode,
        currentFullName: _profile!.user.fullName,
        currentEmail: _profile!.user.email,
      ),
    );

    // Reload profile if update was successful
    if (result == true) {
      await _loadProfile();
    }
  }

  Future<void> _showUploadPhotoDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => UploadProfilePhotoDialog(
        languageCode: widget.languageCode,
        currentImageUrl: _profile?.user.image,
      ),
    );

    // Reload profile if photo was uploaded/deleted
    if (result == true) {
      await _loadProfile();
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
                        // Edit Profile Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () => _showEditProfileDialog(),
                            icon: const Icon(Icons.edit, size: 18),
                            label: Text('editProfile'.tr),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

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
                                // Profile Photo
                                Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: _profile!.user.image != null
                                          ? ClipOval(
                                              child: Image.network(
                                                '${ApiConfig.baseUrl}${_profile!.user.image}',
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Icon(
                                                        Icons.person,
                                                        size: 40,
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                      );
                                                    },
                                              ),
                                            )
                                          : Icon(
                                              Icons.person,
                                              size: 40,
                                              color: theme.colorScheme.primary,
                                            ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.colorScheme.surface,
                                            width: 2,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: _showUploadPhotoDialog,
                                          icon: const Icon(
                                            Icons.camera_alt,
                                            size: 16,
                                          ),
                                          iconSize: 16,
                                          padding: const EdgeInsets.all(4),
                                          constraints: const BoxConstraints(),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
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
