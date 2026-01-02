import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/widgets/button_x.dart';
import '../../shared/widgets/data_table_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/page_x.dart';
import '../../shared/widgets/text_field_x.dart';
import '../../translations/translation_extension.dart';
import '../services/audit_trails_service.dart';
import 'audit_detail_dialog.dart';

class AuditTrailsPage extends StatefulWidget {
  final String languageCode;

  const AuditTrailsPage({super.key, required this.languageCode});

  @override
  State<AuditTrailsPage> createState() => _AuditTrailsPageState();
}

class _AuditTrailsPageState extends State<AuditTrailsPage> {
  List<Map<String, dynamic>> _auditTrails = [];
  bool _isLoading = false;
  int _currentPage = 1;
  final int _limit = 32;

  // Filters
  String? _filterEntityType;
  String? _filterAction;
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _entityIdController = TextEditingController();
  DateTime? _dateFrom;
  DateTime? _dateTo;

  final List<String> _entityTypes = [
    'all',
    'user',
    'product',
    'order',
    'payment',
    'category',
    'faq',
    'tnc',
  ];

  final List<String> _actions = [
    'all',
    'create',
    'update',
    'delete',
    'login',
    'logout',
  ];

  @override
  void initState() {
    super.initState();
    _loadAuditTrails();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _entityIdController.dispose();
    super.dispose();
  }

  Future<void> _loadAuditTrails() async {
    setState(() {
      _isLoading = true;
    });

    final userId = _userIdController.text.trim().isNotEmpty
        ? int.tryParse(_userIdController.text.trim())
        : null;
    final entityId = _entityIdController.text.trim().isNotEmpty
        ? int.tryParse(_entityIdController.text.trim())
        : null;

    final response = await AuditTrailsService.getAuditTrails(
      page: _currentPage,
      limit: _limit,
      userId: userId,
      entityType: _filterEntityType == 'all' ? null : _filterEntityType,
      entityId: entityId,
      action: _filterAction == 'all' ? null : _filterAction,
      dateFrom: _dateFrom != null
          ? DateFormat('yyyy-MM-dd').format(_dateFrom!)
          : null,
      dateTo: _dateTo != null
          ? DateFormat('yyyy-MM-dd').format(_dateTo!)
          : null,
    );

    if (!mounted) return;

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final dataObj = data['data'] as Map<String, dynamic>?;
      final auditData = dataObj?['items'] as List?;

      setState(() {
        _auditTrails = auditData?.cast<Map<String, dynamic>>() ?? [];
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => DialogX(
        title: 'filters'.tr,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User ID Filter
              TextFieldX(
                controller: _userIdController,
                hintText: 'userId'.tr,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Entity Type Filter
              DropdownButtonFormField<String>(
                value: _filterEntityType,
                decoration: InputDecoration(
                  labelText: 'entityType'.tr,
                  border: const OutlineInputBorder(),
                ),
                items: _entityTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type == 'all' ? 'all'.tr : type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _filterEntityType = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Entity ID Filter
              TextFieldX(
                controller: _entityIdController,
                hintText: 'entityId'.tr,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Action Filter
              DropdownButtonFormField<String>(
                value: _filterAction,
                decoration: InputDecoration(
                  labelText: 'action'.tr,
                  border: const OutlineInputBorder(),
                ),
                items: _actions.map((action) {
                  return DropdownMenuItem(
                    value: action,
                    child: Text(action == 'all' ? 'all'.tr : action),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _filterAction = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date From
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('dateFrom'.tr),
                subtitle: Text(
                  _dateFrom != null
                      ? DateFormat('yyyy-MM-dd').format(_dateFrom!)
                      : 'notSet'.tr,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dateFrom ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _dateFrom = date;
                      });
                    }
                  },
                ),
              ),

              // Date To
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('dateTo'.tr),
                subtitle: Text(
                  _dateTo != null
                      ? DateFormat('yyyy-MM-dd').format(_dateTo!)
                      : 'notSet'.tr,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dateTo ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _dateTo = date;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          ButtonX(
            onClicked: () {
              setState(() {
                _filterEntityType = null;
                _filterAction = null;
                _userIdController.clear();
                _entityIdController.clear();
                _dateFrom = null;
                _dateTo = null;
                _currentPage = 1;
              });
              Navigator.pop(context);
              _loadAuditTrails();
            },
            label: 'clearFilters'.tr,
            backgroundColor: Colors.grey,
          ),
          ButtonX(
            onClicked: () {
              Navigator.pop(context);
              setState(() {
                _currentPage = 1;
              });
              _loadAuditTrails();
            },
            label: 'applyFilters'.tr,
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _showAuditDetail(Map<String, dynamic> audit) {
    showDialog(
      context: context,
      builder: (context) =>
          AuditDetailDialog(audit: audit, languageCode: widget.languageCode),
    );
  }

  String _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return '#00CC66';
      case 'update':
        return '#0066FF';
      case 'delete':
        return '#FF0000';
      case 'login':
        return '#00CC66';
      case 'logout':
        return '#999999';
      default:
        return '#666666';
    }
  }

  @override
  Widget build(BuildContext context) {
    TranslationService.setLanguage(widget.languageCode);

    return PageX(
      title: 'auditTrails'.tr,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
          tooltip: 'filters'.tr,
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _auditTrails.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'noAuditTrails'.tr,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : DataTableX(
              maxHeight: double.infinity,
              columnSpacing: 12,
              columns: [
                DataTableColumn.buildColumn(context: context, label: 'user'.tr),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'action'.tr,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'entity'.tr,
                ),
                DataTableColumn.buildColumn(
                  context: context,
                  label: 'timestamp'.tr,
                ),
              ],
              rows: _auditTrails.map((audit) {
                final userName = audit['user_name'] ?? 'Unknown';
                final action = audit['action'] ?? '';
                final entityType = audit['entity_type'] ?? '';
                final entityId = audit['entity_id']?.toString() ?? '';
                final createdAt = audit['created_at'] ?? '';

                return DataRow(
                  onSelectChanged: (_) => _showAuditDetail(audit),
                  cells: [
                    DataCell(Text(userName)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(
                              _getActionColor(action).replaceFirst('#', '0xFF'),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          action,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text('$entityType #$entityId')),
                    DataCell(Text(createdAt)),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
