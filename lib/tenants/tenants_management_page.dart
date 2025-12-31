import 'package:flutter/material.dart';

import '../shared/widgets/data_table_x.dart';
import '../translations/translation_extension.dart';
import 'add_tenant_dialog.dart';
import 'edit_tenant_dialog.dart';
import 'tenant_model.dart';
import 'tenants_management_service.dart';

class TenantsManagementPage extends StatefulWidget {
  final String languageCode;

  const TenantsManagementPage({super.key, required this.languageCode});

  @override
  State<TenantsManagementPage> createState() => _TenantsManagementPageState();
}

class _TenantsManagementPageState extends State<TenantsManagementPage> {
  List<TenantModel> _tenants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    setState(() {
      _isLoading = true;
    });

    final service = TenantsManagementService();
    final response = await service.getTenants();

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      setState(() {
        _tenants = response.data!.cast<TenantModel>();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(response.message ?? 'loadTenantsFailed'.tr),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      // }
    }
  }

  void _showDeleteConfirmation(TenantModel tenant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deleteTenant'.tr),
        content: Text('${'deleteTenantConfirmation'.tr} "${tenant.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteTenant(tenant.id!);
    }
  }

  Future<void> _deleteTenant(int id) async {
    final service = TenantsManagementService();
    final response = await service.deleteTenant(id);

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('tenantDeletedSuccess'.tr),
          backgroundColor: Colors.green,
        ),
      );
      _loadTenants();
    } // else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(response.message ?? 'tenantDeleteFailed'.tr),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('tenantsManagement'.tr),
        backgroundColor: theme.colorScheme.surface,
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tenants.isEmpty
          ? Center(
              child: Text(
                'noTenantsFound'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: DataTableX(
                  columns: [
                    DataColumn(label: Text('image'.tr)),
                    DataColumn(label: Text('tenantName'.tr)),
                    DataColumn(label: Text('email'.tr)),
                    DataColumn(label: Text('phone'.tr)),
                    DataColumn(label: Text('status'.tr)),
                    DataColumn(label: Text('actions'.tr)),
                  ],
                  rows: _tenants.map((tenant) {
                    return DataRow(
                      cells: [
                        DataCell(
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                tenant.image != null && tenant.image!.isNotEmpty
                                ? Image.network(
                                    'http://localhost:8080${tenant.image}',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.business,
                                          size: 24,
                                          color: Colors.grey[600],
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
                        ),
                        DataCell(Text(tenant.name)),
                        DataCell(Text(tenant.email ?? '-')),
                        DataCell(Text(tenant.phone ?? '-')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: tenant.isActive == true
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tenant.isActive == true
                                  ? 'active'.tr
                                  : 'inactive'.tr,
                              style: TextStyle(
                                color: tenant.isActive == true
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () async {
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
                                tooltip: 'edit'.tr,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () =>
                                    _showDeleteConfirmation(tenant),
                                tooltip: 'delete'.tr,
                                color: Colors.red,
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
    );
  }
}
