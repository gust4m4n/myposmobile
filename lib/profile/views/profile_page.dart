import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/api_models.dart';
import '../../shared/config/api_config.dart';
import '../../shared/utils/image_upload_service.dart';
import '../../shared/widgets/image_x.dart';
import '../../shared/widgets/page_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../translations/translation_extension.dart';
import '../services/profile_service.dart';
import 'edit_profile_dialog.dart';

class ProfilePage extends StatefulWidget {
  final String languageCode;

  const ProfilePage({super.key, required this.languageCode});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = ProfileService();
  bool _isLoading = true;
  bool _isUploading = false;
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

  Future<void> _pickAndUploadPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: false,
        dialogTitle: 'Select Photo',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (kDebugMode) {
          print('📸 Selected file path: ${file.path}');
          print('📸 File exists: ${file.existsSync()}');
          print('📸 File size: ${file.lengthSync()} bytes');
        }

        if (!mounted) return;

        // Upload photo
        if (kDebugMode) {
          print('📤 Starting upload...');
        }

        setState(() {
          _isUploading = true;
        });

        final response = await ImageUploadService.uploadProfilePhoto(
          filePath: file.path,
        );

        if (kDebugMode) {
          print('📥 Upload response: statusCode=${response.statusCode}');
          print('📥 Upload response: message=${response.message}');
          print('📥 Upload response: error=${response.error}');
          print('📥 Upload response: data=${response.data}');
        }

        if (!mounted) return;

        setState(() {
          _isUploading = false;
        });

        if (response.statusCode == 200 && response.data != null) {
          if (kDebugMode) {
            print('✅ Upload successful, updating profile...');
          }
          // Update profile with new data from response
          // Response format: {code: 0, message: "...", data: {user, tenant, branch}}
          final profileData = response.data!['data'] as Map<String, dynamic>;
          setState(() {
            _profile = ProfileModel.fromJson(profileData);
          });
          if (kDebugMode) {
            print('✅ Profile updated');
          }
        } else {
          if (kDebugMode) {
            print('❌ Upload failed: ${response.message ?? response.error}');
          }
          ToastX.error(
            context,
            response.message ?? response.error ?? 'Failed to upload photo',
          );
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error picking/uploading image: $e');
        print('❌ Stack trace: $stackTrace');
      }
      if (mounted) {
        ToastX.error(context, 'Failed to pick image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TranslationService.setLanguage(widget.languageCode);

    return PageX(
      title: 'profile'.tr,
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
                                ImageX(
                                  imageUrl: _profile!.user.image,
                                  baseUrl: ApiConfig.baseUrl,
                                  size: 80,
                                  cornerRadius: 40,
                                  onPicked: _pickAndUploadPhoto,
                                  isLoading: _isUploading,
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
