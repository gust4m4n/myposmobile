import 'package:flutter/material.dart';

import '../../shared/widgets/data_table_x.dart';
import '../../shared/widgets/page_x.dart';
import '../../translations/translation_extension.dart';
import '../models/category_model.dart';
import '../services/categories_management_service.dart';
import 'add_category_dialog.dart';
import 'edit_category_dialog.dart';

class CategoriesManagementPage extends StatefulWidget {
  final String languageCode;

  const CategoriesManagementPage({super.key, required this.languageCode});

  @override
  State<CategoriesManagementPage> createState() =>
      _CategoriesManagementPageState();
}

class _CategoriesManagementPageState extends State<CategoriesManagementPage> {
  List<CategoryModel> _categories = [];
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
    _loadCategories();
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
        _loadMoreCategories();
      }
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    final service = CategoriesManagementService();
    final response = await service.getCategories(
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final categories = response.data!.data;
      setState(() {
        _categories = categories;
        _hasMoreData = response.data!.page < response.data!.totalPages;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _categories = [];
      });
    }
  }

  Future<void> _loadMoreCategories() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    final service = CategoriesManagementService();
    final response = await service.getCategories(
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final newCategories = response.data!.data;
      setState(() {
        _categories.addAll(newCategories);
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
      title: 'categoriesManagement'.tr,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (context) =>
                  AddCategoryDialog(languageCode: widget.languageCode),
            );
            if (result == true) {
              _loadCategories();
            }
          },
          tooltip: 'addCategory'.tr,
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
          ? Center(
              child: Text(
                'noCategoriesFound'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200) {
                        if (!_isLoadingMore && _hasMoreData) {
                          _loadMoreCategories();
                        }
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: DataTableX(
                        maxHeight: double.infinity,
                        columns: [
                          DataColumn(label: Text('categoryName'.tr)),
                          DataColumn(label: Text('description'.tr)),
                        ],
                        rows: _categories.map((category) {
                          return DataRow(
                            onSelectChanged: (_) async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => EditCategoryDialog(
                                  languageCode: widget.languageCode,
                                  category: category,
                                ),
                              );
                              if (result == true) {
                                _loadCategories();
                              }
                            },
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:
                                          category.image != null &&
                                              category.image!.isNotEmpty
                                          ? Image.network(
                                              _getImageUrl(category.image!),
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
                                                        Icons.category,
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
                                                Icons.category,
                                                size: 24,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        category.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  category.description ?? '-',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
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
    );
  }
}
