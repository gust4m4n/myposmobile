import 'package:flutter/material.dart';

import '../shared/widgets/data_table_x.dart';
import '../tenants/tenant_model.dart';
import '../tenants/tenants_management_service.dart';
import '../translations/translation_extension.dart';
import 'add_branch_dialog.dart';
import 'branch_model.dart';
import 'branches_management_service.dart';
import 'edit_branch_dialog.dart';

class BranchesManagementPage extends StatefulWidget {
  final String languageCode;

  const BranchesManagementPage({super.key, required this.languageCode});

  @override
  State<BranchesManagementPage> createState() => _BranchesManagementPageState();
}

class _BranchesManagementPageState extends State<BranchesManagementPage> {
  List<TenantModel> _tenants = [];
  List<BranchModel> _branches = [];
  TenantModel? _selectedTenant;
  bool _isLoadingTenants = true;
  bool _isLoadingBranches = false;

  @override
  void initState() {
    super.initState();
    TranslationService.setLanguage(widget.languageCode);
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    setState(() {
      _isLoadingTenants = true;
    });

    final service = TenantsManagementService();
    final response = await service.getTenants();

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final tenants = response.data!.cast<TenantModel>();
      setState(() {
        _tenants = tenants;
        _isLoadingTenants = false;
        if (tenants.isNotEmpty) {
          _selectedTenant = tenants.first;
          _loadBranches();
        }
      });
    } else {
      setState(() {
        _isLoadingTenants = false;
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

  Future<void> _loadBranches() async {
    if (_selectedTenant == null) return;

    setState(() {
      _isLoadingBranches = true;
    });

    final service = BranchesManagementService();
    final response = await service.getBranches(_selectedTenant!.id!);

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      setState(() {
        _branches = response.data!.cast<BranchModel>();
        _isLoadingBranches = false;
      });
    } else {
      setState(() {
        _isLoadingBranches = false;
      });
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(response.message ?? 'loadBranchesFailed'.tr),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      // }
    }
  }

  void _showDeleteConfirmation(BranchModel branch) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deleteBranch'.tr),
        content: Text('${'deleteBranchConfirmation'.tr} "${branch.name}"?'),
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
      await _deleteBranch(branch.id!);
    }
  }

  Future<void> _deleteBranch(int id) async {
    final service = BranchesManagementService();
    final response = await service.deleteBranch(id);

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('branchDeletedSuccess'.tr),
          backgroundColor: Colors.green,
        ),
      );
      _loadBranches();
    } // else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(response.message ?? 'branchDeleteFailed'.tr),
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
        title: Text('branchesManagement'.tr),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          if (_selectedTenant != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => AddBranchDialog(
                    languageCode: widget.languageCode,
                    tenant: _selectedTenant!,
                  ),
                );
                if (result == true) {
                  _loadBranches();
                }
              },
              tooltip: 'addBranch'.tr,
            ),
        ],
      ),
      body: _isLoadingTenants
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tenant selector
                Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.surface,
                  child: Row(
                    children: [
                      Text(
                        'selectTenant'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<TenantModel>(
                          value: _selectedTenant,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: _tenants.map((tenant) {
                            return DropdownMenuItem<TenantModel>(
                              value: tenant,
                              child: Text(tenant.name),
                            );
                          }).toList(),
                          onChanged: (tenant) {
                            setState(() {
                              _selectedTenant = tenant;
                              _branches = [];
                            });
                            _loadBranches();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Branches list
                Expanded(
                  child: _isLoadingBranches
                      ? const Center(child: CircularProgressIndicator())
                      : _branches.isEmpty
                      ? Center(
                          child: Text(
                            'noBranchesFound'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: DataTableX(
                              columns: [
                                DataColumn(label: Text('image'.tr)),
                                DataColumn(label: Text('branchName'.tr)),
                                DataColumn(label: Text('email'.tr)),
                                DataColumn(label: Text('phone'.tr)),
                                DataColumn(label: Text('status'.tr)),
                                DataColumn(label: Text('actions'.tr)),
                              ],
                              rows: _branches.map((branch) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            branch.image != null &&
                                                branch.image!.isNotEmpty
                                            ? Image.network(
                                                'http://localhost:8080${branch.image}',
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
                                                        color: Colors.grey[300],
                                                        child: Icon(
                                                          Icons.store,
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
                                                color: Colors.grey[300],
                                                child: Icon(
                                                  Icons.store,
                                                  size: 24,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                      ),
                                    ),
                                    DataCell(Text(branch.name)),
                                    DataCell(Text(branch.email ?? '-')),
                                    DataCell(Text(branch.phone ?? '-')),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: branch.isActive == true
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          branch.isActive == true
                                              ? 'active'.tr
                                              : 'inactive'.tr,
                                          style: TextStyle(
                                            color: branch.isActive == true
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
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              final result =
                                                  await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) =>
                                                        EditBranchDialog(
                                                          languageCode: widget
                                                              .languageCode,
                                                          tenant:
                                                              _selectedTenant!,
                                                          branch: branch,
                                                        ),
                                                  );
                                              if (result == true) {
                                                _loadBranches();
                                              }
                                            },
                                            tooltip: 'edit'.tr,
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _showDeleteConfirmation(branch),
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
                ),
              ],
            ),
    );
  }
}
