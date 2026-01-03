import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../shared/widgets/page_x.dart';
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
  dynamic _tnc;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTnc();
  }

  Future<void> _loadTnc() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _tncService.getAllTnc();

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
        _tnc = tncData;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildTncView() {
    final theme = Theme.of(context);

    if (_tnc == null) {
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
              'No Terms & Conditions available',
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
        elevation: 0,
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
                      _tnc['title'],
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              // Content with Markdown
              MarkdownBody(
                data: _tnc['content'],
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageX(
      title: 'termsAndConditions'.tr,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTncView(),
    );
  }
}
