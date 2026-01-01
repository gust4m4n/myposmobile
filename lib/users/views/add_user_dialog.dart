import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import '../../common/superadmin_branches_service.dart';
import '../../shared/api_models.dart';
import '../../shared/controllers/profile_controller.dart';
import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../translations/translation_extension.dart';
import '../services/users_management_service.dart';

class AddUserDialog extends StatefulWidget {
  final String languageCode;
  final VoidCallback onSuccess;

  const AddUserDialog({
    super.key,
    required this.languageCode,
    required this.onSuccess,
  });

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  String _selectedRole = 'user';
  bool _isActive = true;
  bool _isSubmitting = false;
  File? _selectedImage;

  List<BranchModel> _branches = [];
  BranchModel? _selectedBranch;
  bool _isLoadingBranches = false;

  final List<String> _roles = ['user', 'branchadmin', 'tenantadmin'];

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);

    // Fetch branches after frame is built to avoid context issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBranches();
    });

    // Prefill form in debug mode
    if (kDebugMode) {
      _fullNameController.text =
          'Test User ${DateTime.now().millisecondsSinceEpoch % 1000}';
      _emailController.text =
          'testuser${DateTime.now().millisecondsSinceEpoch % 1000}@example.com';
      _passwordController.text = 'Password123!';
      _selectedRole = 'user';
      _isActive = true;
      print('🐛 Debug mode: Add user form prefilled with test data');
    }
  }

  Future<void> _fetchBranches() async {
    if (!mounted) return;

    setState(() {
      _isLoadingBranches = true;
    });

    try {
      // Get tenant ID from profile controller
      final profileController = Get.find<ProfileController>();

      // Wait for profile if not loaded yet
      if (profileController.profile.value == null) {
        if (kDebugMode) {
          print('⏳ Waiting for profile to load...');
        }
        await profileController.fetchProfile();
      }

      final tenantId = profileController.profile.value?.tenant.id;

      if (kDebugMode) {
        print(
          '🔍 Profile loaded: ${profileController.profile.value?.user.fullName}',
        );
        print('🔍 Tenant ID: $tenantId');
      }

      if (tenantId == null) {
        if (kDebugMode) {
          print('❌ Tenant ID is null from profile');
        }
        if (!mounted) return;
        ToastX.error(context, 'tenantIdNotFound'.tr);
        setState(() {
          _isLoadingBranches = false;
        });
        return;
      }

      final service = SuperadminBranchesService();
      final response = await service.listBranchesByTenant(tenantId);

      if (!mounted) return;

      setState(() {
        _isLoadingBranches = false;
      });

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _branches = response.data!;
          // Auto-select first branch if available
          if (_branches.isNotEmpty) {
            _selectedBranch = _branches.first;
          }
        });

        if (kDebugMode) {
          print('📋 Loaded ${_branches.length} branches');
        }
      } else {
        if (kDebugMode) {
          print('❌ Failed to load branches: ${response.message}');
        }
        ToastX.error(
          context,
          '\${"failedToLoadBranches".tr}: \${response.message}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching branches: $e');
      }
      if (!mounted) return;
      setState(() {
        _isLoadingBranches = false;
      });
      ToastX.error(context, '\${"failedToLoadBranches".tr}: \$e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);

        if (kDebugMode) {
          print('📷 Selected image: $filePath');
          print('📷 File exists: ${file.existsSync()}');
          print('📷 File size: ${file.lengthSync()} bytes');
        }

        // Check file size (max 5MB)
        final fileSize = file.lengthSync();
        if (fileSize > 5 * 1024 * 1024) {
          if (!mounted) return;
          ToastX.error(context, 'fileSizeExceeded'.tr);
          return;
        }

        setState(() {
          _selectedImage = file;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error picking image: $e');
      }
      if (!mounted) return;
      ToastX.error(context, '\${"imagePickFailed".tr}: \$e');
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBranch == null) {
      ToastX.error(context, 'branchRequired'.tr);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final response = await UsersManagementService.createUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _fullNameController.text.trim(),
      role: _selectedRole,
      branchId: _selectedBranch!.id,
      isActive: _isActive,
      imageFile: _selectedImage,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      ToastX.success(context, 'userCreatedSuccess'.tr);
      Navigator.of(context).pop();
      widget.onSuccess();
    } else {
      ToastX.error(context, response.message ?? 'userCreatedFailed'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DialogX(
      title: 'addUser'.tr,
      width: 600,
      onClose: () => Navigator.of(context).pop(),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (_selectedImage != null) ...[
                Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: Image.file(
                          _selectedImage!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Select/Change Image Button
              Center(
                child: ButtonX(
                  onPressed: _pickImage,
                  label: _selectedImage == null
                      ? 'selectImage'.tr
                      : 'changeImage'.tr,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // Full Name Field
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'fullName'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fullNameRequired'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'email'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'emailRequired'.tr;
                  }
                  if (!value.contains('@')) {
                    return 'emailInvalid'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'password'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'passwordRequired'.tr;
                  }
                  if (value.trim().length < 6) {
                    return 'passwordMinLength'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'role'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.security),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Branch Picker
              _isLoadingBranches
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : DropdownButtonFormField<BranchModel>(
                      value: _selectedBranch,
                      decoration: InputDecoration(
                        labelText: 'branch'.tr,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.store),
                      ),
                      items: _branches.map((branch) {
                        return DropdownMenuItem(
                          value: branch,
                          child: Text('${branch.name} (ID: ${branch.id})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedBranch = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'branchRequired'.tr;
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 16),

              // Active Status Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('activeStatus'.tr, style: const TextStyle(fontSize: 16)),
                  Switch(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: ButtonX(
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                icon: Icons.close,
                label: 'cancel'.tr,
                backgroundColor: Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ButtonX(
                onPressed: _isSubmitting ? null : _handleSubmit,
                icon: Icons.save,
                label: _isSubmitting ? 'saving'.tr : 'save'.tr,
                backgroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
