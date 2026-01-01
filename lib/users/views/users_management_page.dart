import 'package:flutter/material.dart';

import '../../shared/widgets/app_bar_x.dart';
import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/data_table_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../../translations/translation_extension.dart';
import '../services/users_management_service.dart';
import 'add_user_dialog.dart';
import 'edit_user_dialog.dart';

class UsersManagementPage extends StatefulWidget {
  final String languageCode;

  const UsersManagementPage({super.key, required this.languageCode});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 32;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreUsers();
      }
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    final response = await UsersManagementService.getUsers(
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is List) {
        setState(() {
          _users = data.cast<Map<String, dynamic>>();
          _hasMoreData = data.length >= _pageSize;
        });
      } else if (data is Map && data['data'] is List) {
        final dataList = data['data'] as List;
        setState(() {
          _users = dataList.cast<Map<String, dynamic>>();
          _hasMoreData = dataList.length >= _pageSize;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    final response = await UsersManagementService.getUsers(
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      List<Map<String, dynamic>> newUsers = [];

      if (data is List) {
        newUsers = data.cast<Map<String, dynamic>>();
      } else if (data is Map && data['data'] is List) {
        newUsers = (data['data'] as List).cast<Map<String, dynamic>>();
      }

      setState(() {
        _users.addAll(newUsers);
        _hasMoreData = newUsers.length >= _pageSize;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(
        languageCode: widget.languageCode,
        onSuccess: () {
          _loadUsers();
        },
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(
        user: user,
        languageCode: widget.languageCode,
        onSuccess: () {
          _loadUsers();
        },
      ),
    );
  }

  Future<void> _deleteUser(int userId, String email) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => DialogX(
        title: 'deleteUser'.tr,
        content: Text('confirmDeleteUser'.tr.replaceAll('{username}', email)),
        actions: [
          ButtonX(
            onPressed: () => Navigator.pop(context, false),
            label: 'cancel'.tr,
            backgroundColor: Colors.grey,
          ),
          ButtonX(
            onPressed: () => Navigator.pop(context, true),
            label: 'delete'.tr,
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await UsersManagementService.deleteUser(userId);

    if (!mounted) return;

    if (response.statusCode == 200) {
      ToastX.success(context, 'userDeletedSuccess'.tr);
      _loadUsers();
    } else {
      ToastX.error(context, response.message ?? 'userDeleteFailed'.tr);
    }
  }

  String _getRoleBadgeColor(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return '#FF0000';
      case 'tenantadmin':
        return '#FF6B00';
      case 'branchadmin':
        return '#0066FF';
      case 'user':
      default:
        return '#00CC66';
    }
  }

  @override
  Widget build(BuildContext context) {
    TranslationService.setLanguage(widget.languageCode);

    return Scaffold(
      appBar: AppBarX(
        title: 'userManagement'.tr,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'noUsers'.tr,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'totalUsers'.tr.replaceAll(
                          '{count}',
                          _users.length.toString(),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ButtonX(
                        onPressed: _showAddUserDialog,
                        icon: Icons.add,
                        label: 'addUser'.tr,
                        backgroundColor: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 200) {
                                if (!_isLoadingMore && _hasMoreData) {
                                  _loadMoreUsers();
                                }
                              }
                              return false;
                            },
                            child: DataTableX(
                              maxHeight: double.infinity,
                              columnSpacing: 16,
                              columns: [
                                DataTableColumn.buildColumn(
                                  context: context,
                                  label: 'image'.tr,
                                ),
                                DataTableColumn.buildColumn(
                                  context: context,
                                  label: 'fullName'.tr,
                                ),
                                DataTableColumn.buildColumn(
                                  context: context,

                                  label: 'email'.tr,
                                ),
                                DataTableColumn.buildColumn(
                                  context: context,
                                  label: 'role'.tr,
                                ),
                                DataTableColumn.buildColumn(
                                  context: context,
                                  label: 'status'.tr,
                                ),
                                DataTableColumn.buildColumn(
                                  context: context,
                                  label: 'actions'.tr,
                                ),
                              ],
                              rows: _users.map((user) {
                                final fullName = user['full_name'] ?? '';
                                final email = user['email'] ?? '';
                                final role = user['role'] ?? 'user';
                                final isActive = user['is_active'] ?? false;
                                final userId = user['id'] as int;
                                final image = user['image'] as String?;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: image != null && image.isNotEmpty
                                            ? Image.network(
                                                'http://localhost:8080$image',
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                              color: Colors
                                                                  .grey[300],
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 24,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      );
                                                    },
                                              )
                                            : Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 24,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                      ),
                                    ),
                                    DataCell(Text(fullName)),
                                    DataCell(Text(email)),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(
                                            int.parse(
                                              _getRoleBadgeColor(
                                                role,
                                              ).replaceFirst('#', '0xFF'),
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          role,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          isActive
                                              ? 'active'.tr
                                              : 'inactive'.tr,
                                          style: TextStyle(
                                            color: isActive
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 20,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () =>
                                                _showEditUserDialog(user),
                                            tooltip: 'edit'.tr,
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 20,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _deleteUser(userId, email),
                                            tooltip: 'delete'.tr,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        if (_isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (!_hasMoreData && _users.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'noMoreData'.tr,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
