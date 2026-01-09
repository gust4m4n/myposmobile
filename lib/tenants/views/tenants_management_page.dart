import 'package:flutter/material.dart';

import '../../shared/widgets/data_table_x.dart';
import '../../shared/widgets/page_x.dart';
import '../../translations/translation_extension.dart';
import '../models/tenant_model.dart';
import '../services/tenants_management_service.dart';
import 'add_tenant_dialog.dart';
import 'edit_tenant_dialog.dart';

class TenantsManagementPage extends StatefulWidget {
  final String languageCode;

  const TenantsManagementPage({super.key, required this.languageCode});

  @override
  State<TenantsManagementPage> createState() => _TenantsManagementPageState();
}

class _TenantsManagementPageState extends State<TenantsManagementPage> {
  List<TenantModel> _tenants = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 32;
  final ScrollController _scrollController = ScrollController();

  /// Helper function to get correct image URL
  String _getImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return 'http://localhost:8080$imageUrl';
  }

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);
    _loadTenants();
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
        _loadMoreTenants();
      }
    }
  }

  Future<void> _loadTenants() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    final service = TenantsManagementService();
    final response = await service.getTenants(
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final tenants = response.data!.data;
      setState(() {
        _tenants = tenants;
        _hasMoreData = response.data!.page < response.data!.totalPages;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTenants() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    final service = TenantsManagementService();
    final response = await service.getTenants(
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final newTenants = response.data!.data;
      setState(() {
        _tenants.addAll(newTenants);
        _hasMoreData = response.data!.page < response.data!.totalPages;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageX(
      title: 'tenantsManagement'.tr,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (context) =>
                  AddTenantDialog(languageCode: widget.languageCode),
            );
            if (result == true) {
              _loadTenants();
            }
          },
          tooltip: 'addTenant'.tr,
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tenants.isEmpty
          ? Center(
              child: Text(
                'noTenantsFound'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200) {
                              if (!_isLoadingMore && _hasMoreData) {
                                _loadMoreTenants();
                              }
                            }
                            return false;
                          },
                          child: DataTableX(
                            maxHeight: double.infinity,
                            columns: [
                              DataColumn(label: Text('tenantName'.tr)),
                              DataColumn(label: Text('email'.tr)),
                              DataColumn(label: Text('phone'.tr)),
                            ],
                            rows: _tenants.map((tenant) {
                              return DataRow(
                                onSelectChanged: (_) async {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => EditTenantDialog(
                                      languageCode: widget.languageCode,
                                      tenant: tenant,
                                    ),
                                  );
                                  if (result == true) {
                                    _loadTenants();
                                  }
                                },
                                cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child:
                                              tenant.image != null &&
                                                  tenant.image!.isNotEmpty
                                              ? Image.network(
                                                  _getImageUrl(tenant.image!),
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
                                                          color:
                                                              Colors.grey[300],
                                                          child: Icon(
                                                            Icons.business,
                                                            size: 24,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        );
                                                      },
                                                )
                                              : Container(
                                                  width: 40,
                                                  height: 40,
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    Icons.business,
                                                    size: 24,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            tenant.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(tenant.email ?? '-')),
                                  DataCell(Text(tenant.phone ?? '-')),
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
