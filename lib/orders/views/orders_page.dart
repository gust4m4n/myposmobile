import 'package:flutter/material.dart';

import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/data_table_x.dart';
import '../../shared/widgets/page_x.dart';
import '../../translations/translation_extension.dart';
import '../services/orders_service.dart';
import 'order_detail_dialog.dart';

class OrdersPage extends StatefulWidget {
  final String languageCode;

  const OrdersPage({super.key, required this.languageCode});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _perPage = 32;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadOrders();
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
        _loadMoreOrders();
      }
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    final response = await OrdersService.getOrders(
      page: _currentPage,
      perPage: _perPage,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final dataObj = data['data'] as Map<String, dynamic>?;
      final items = dataObj?['items'] as List?;
      final pagination = dataObj?['pagination'] as Map<String, dynamic>?;

      setState(() {
        _orders = items?.cast<Map<String, dynamic>>() ?? [];
        final currentPage = pagination?['page'] ?? 1;
        final totalPages = pagination?['total_pages'] ?? 1;
        _hasMoreData = currentPage < totalPages;
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreOrders() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    final response = await OrdersService.getOrders(
      page: _currentPage,
      perPage: _perPage,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final dataObj = data['data'] as Map<String, dynamic>?;
      final items = dataObj?['items'] as List?;
      final pagination = dataObj?['pagination'] as Map<String, dynamic>?;

      final newOrders = items?.cast<Map<String, dynamic>>() ?? [];
      setState(() {
        _orders.addAll(newOrders);
        final currentPage = pagination?['page'] ?? _currentPage;
        final totalPages = pagination?['total_pages'] ?? 1;
        _hasMoreData = currentPage < totalPages;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
    }
  }

  void _showOrderDetail(Map<String, dynamic> order) async {
    final orderId = order['id'];
    if (orderId == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await OrdersService.getOrderById(orderId);

    if (!mounted) return;

    // Close loading dialog
    Navigator.pop(context);

    if (response.statusCode == 200 && response.data != null) {
      // Show order detail dialog with fetched data
      showDialog(
        context: context,
        builder: (context) => OrderDetailDialog(
          order: response.data!,
          languageCode: widget.languageCode,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TranslationService.setLanguage(widget.languageCode);

    return PageX(
      title: 'orders'.tr,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'noOrders'.tr,
                    style: const TextStyle(color: Colors.grey, fontSize: 16.0),
                  ),
                ],
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
                                _loadMoreOrders();
                              }
                            }
                            return false;
                          },
                          child: DataTableX(
                            maxHeight: double.infinity,
                            columnSpacing: 20,
                            columns: [
                              DataTableColumn.buildColumn(
                                context: context,
                                label: 'orderNumber'.tr,
                              ),
                              DataTableColumn.buildColumn(
                                context: context,
                                label: 'totalAmount'.tr,
                                numeric: true,
                              ),
                              DataTableColumn.buildColumn(
                                context: context,
                                label: 'status'.tr,
                              ),
                              DataTableColumn.buildColumn(
                                context: context,
                                label: 'createdAt'.tr,
                              ),
                            ],
                            rows: _orders.map((order) {
                              final orderNumber =
                                  order['order_number'] ?? 'N/A';
                              final totalAmount = order['total_amount'] ?? 0;
                              final status = order['status'] ?? 'pending';
                              final createdAt = order['created_at'] ?? '';

                              return DataRow(
                                onSelectChanged: (_) => _showOrderDetail(order),
                                cells: [
                                  DataCell(
                                    Text(
                                      orderNumber,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      CurrencyFormatter.format(
                                        totalAmount.toDouble(),
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          status,
                                        ).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _getStatusColor(status),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          color: _getStatusColor(status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      createdAt,
                                      style: const TextStyle(fontSize: 16.0),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
