import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../shared/widgets/app_bar_x.dart';
import '../../shared/widgets/dialog_x.dart';
import '../../shared/widgets/green_button.dart';
import '../../translations/translation_extension.dart';
import '../services/tnc_service.dart';

class TncPage extends StatefulWidget {
  final String languageCode;

  const TncPage({super.key, required this.languageCode});

  @override
  State<TncPage> createState() => _TncPageState();
}

class _TncPageState extends State<TncPage> {
  final TncService _tncService = TncService();
  List<dynamic> _tncList = [];
  dynamic _activeTnc;
  bool _isLoading = true;
  bool _showingActive = true;

  @override
  void initState() {
    super.initState();
    _loadActiveTnc();
  }

  Future<void> _loadActiveTnc() async {
    setState(() {
      _isLoading = true;
      _showingActive = true;
    });

    final result = await _tncService.getActiveTnc();

    if (result['success'] == true) {
      final data = result['data'];
      // Parse the response - check if data contains 'data' key or is directly the object
      dynamic tncData;
      if (data is Map && data.containsKey('data')) {
        tncData = data['data'];
      } else {
        tncData = data;
      }
      setState(() {
        _activeTnc = tncData;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadAllTnc() async {
    setState(() {
      _isLoading = true;
      _showingActive = false;
    });

    final result = await _tncService.getAllTnc();

    if (result['success'] == true) {
      final data = result['data'];
      // Parse the response - check if data contains 'data' key or is directly the list
      List<dynamic> tncList;
      if (data is Map && data.containsKey('data')) {
        tncList = data['data'] as List<dynamic>;
      } else if (data is List) {
        tncList = data;
      } else {
        tncList = [];
      }

      setState(() {
        _tncList = tncList;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showTncDetail(dynamic tnc) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => DialogX(
        title: tnc['title'],
        width: 700,
        onClose: () => Navigator.pop(context),
        content: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Version and status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.label,
                          size: 14,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'v${tnc['version']}',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (tnc['is_active'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.green[700],
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Content with Markdown support
              Container(
                constraints: const BoxConstraints(maxHeight: 500),
                child: Markdown(
                  physics: const ClampingScrollPhysics(),
                  data: tnc['content'],
                  shrinkWrap: true,
                  styleSheet: MarkdownStyleSheet(
                    h1: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    h2: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    h3: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    p: TextStyle(
                      fontSize: 16.0,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    listBullet: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Timestamps
              Text(
                'Created: ${tnc['created_at']}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Updated: ${tnc['updated_at']}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        actions: [
          GreenButton(
            onClicked: () => Navigator.pop(context),
            title: 'close'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTncView() {
    final theme = Theme.of(context);

    if (_activeTnc == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No active Terms & Conditions',
              style: TextStyle(
                fontSize: 16.0,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.description,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _activeTnc['title'],
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Version and status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.label,
                          size: 14,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Version ${_activeTnc['version']}',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'active'.tr,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.green[700],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              // Content with Markdown
              MarkdownBody(
                data: _activeTnc['content'],
                styleSheet: MarkdownStyleSheet(
                  h1: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  h2: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  h3: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  p: TextStyle(
                    fontSize: 16.0,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                  listBullet: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Timestamps
              Text(
                'Last updated: ${_activeTnc['updated_at']}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllTncView() {
    final theme = Theme.of(context);

    if (_tncList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Terms & Conditions found',
              style: TextStyle(
                fontSize: 16.0,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _tncList.length,
      itemBuilder: (context, index) {
        final tnc = _tncList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showTncDetail(tnc),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tnc['title'],
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'v${tnc['version']}',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (tnc['is_active'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.green[700],
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updated: ${tnc['updated_at']}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBarX(
        title: 'termsAndConditions'.tr,
        actions: [
          // Toggle view button
          TextButton.icon(
            onPressed: () {
              if (_showingActive) {
                _loadAllTnc();
              } else {
                _loadActiveTnc();
              }
            },
            icon: Icon(
              _showingActive ? Icons.list : Icons.star,
              color: theme.colorScheme.onPrimary,
            ),
            label: Text(
              _showingActive ? 'viewAll'.tr : 'viewActive'.tr,
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showingActive
          ? _buildActiveTncView()
          : _buildAllTncView(),
    );
  }
}
