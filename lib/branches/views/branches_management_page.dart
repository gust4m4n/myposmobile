import 'package:flutter/material.dart';

import '../../shared/widgets/data_table_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/gray_button_x.dart';
import '../../shared/widgets/page_x.dart';
import '../../shared/widgets/red_button_x.dart';
import '../../translations/translation_extension.dart';
import '../models/branch_model.dart';
import '../services/branches_management_service.dart';
import 'add_branch_dialog.dart';
import 'edit_branch_dialog.dart';

class BranchesManagementPage extends StatefulWidget {
  final String languageCode;

  const BranchesManagementPage({super.key, required this.languageCode});

  @override
  State<BranchesManagementPage> createState() => _BranchesManagementPageState();
}

class _BranchesManagementPageState extends State<BranchesManagementPage> {
  List<BranchModel> _branches = [];
  bool _isLoadingBranches = false;
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
    _loadBranches();
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
        _loadMoreBranches();
      }
    }
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoadingBranches = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    final service = BranchesManagementService();
    final response = await service.getBranchesForCurrentTenant(
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final branchList = response.data!;
      setState(() {
        _branches = branchList.data;
        _hasMoreData = branchList.page < branchList.totalPages;
        _isLoadingBranches = false;
      });
    } else {
      setState(() {
        _isLoadingBranches = false;
      });
    }
  }

  Future<void> _loadMoreBranches() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    final service = BranchesManagementService();
    final response = await service.getBranchesForCurrentTenant(
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final branchList = response.data!;
      setState(() {
        _branches.addAll(branchList.data);
        _hasMoreData = branchList.page < branchList.totalPages;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
    }
  }

  void _showDeleteConfirmation(BranchModel branch) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => DialogX(
        title: 'deleteBranch'.tr,
        content: Text('${'deleteBranchConfirmation'.tr} "${branch.name}"?'),
        actions: [
          GrayButtonX(
            onClicked: () => Navigator.pop(context, false),
            title: 'cancel'.tr,
          ),
          RedButtonX(
            onClicked: () => Navigator.pop(context, true),
            title: 'delete'.tr,
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

    return PageX(
      title: 'branchesManagement'.tr,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (context) =>
                  AddBranchDialog(languageCode: widget.languageCode),
            );
            if (result == true) {
              _loadBranches();
            }
          },
          tooltip: 'addBranch'.tr,
        ),
      ],
      body: _isLoadingBranches
          ? const Center(child: CircularProgressIndicator())
          : _branches.isEmpty
          ? Center(
              child: Text(
                'noBranchesFound'.tr,
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
                                _loadMoreBranches();
                              }
                            }
                            return false;
                          },
                          child: DataTableX(
                            maxHeight: double.infinity,
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
                                              _getImageUrl(branch.image!),
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      width: 40,
                                                      height: 40,
                                                      color: Colors.grey[300],
                                                      child: Icon(
                                                        Icons.store,
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
                                            ? Colors.green.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
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
                                                        languageCode:
                                                            widget.languageCode,
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
