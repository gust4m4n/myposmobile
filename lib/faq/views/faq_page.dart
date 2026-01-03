import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/widgets/page_x.dart';
import '../../shared/widgets/text_field_x.dart';
import '../../translations/translation_extension.dart';
import '../services/faq_service.dart';

class FaqPage extends StatefulWidget {
  final String languageCode;

  const FaqPage({super.key, required this.languageCode});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final FaqService _faqService = FaqService();
  List<dynamic> _faqs = [];
  List<dynamic> _filteredFaqs = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadFaqs();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterFaqs();
    });
  }

  Future<void> _loadFaqs() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _faqService.getAllFaq(activeOnly: true);

    if (result['success'] == true) {
      final data = result['data'];
      print('FAQ Response data: $data'); // Debug print

      // Parse the response - check if data contains 'data' key or is directly the list
      List<dynamic> faqList;
      if (data is Map && data.containsKey('data')) {
        faqList = data['data'] as List<dynamic>;
      } else if (data is List) {
        faqList = data;
      } else {
        faqList = [];
      }

      print('FAQ List count: ${faqList.length}'); // Debug print

      setState(() {
        _faqs = faqList;
        _filteredFaqs = faqList;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _filterFaqs() {
    setState(() {
      final searchText = _searchController.text.toLowerCase();

      if (searchText.isEmpty) {
        _filteredFaqs = _faqs;
      } else {
        _filteredFaqs = _faqs.where((faq) {
          return faq['question'].toString().toLowerCase().contains(
                searchText,
              ) ||
              faq['answer'].toString().toLowerCase().contains(searchText);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageX(
      title: 'faq'.tr,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and filter section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.surface,
                  child: TextFieldX(
                    controller: _searchController,
                    hintText: 'Search FAQs...',
                    prefixIcon: Icons.search,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
                // FAQ list
                Expanded(
                  child: _filteredFaqs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No FAQs found',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredFaqs.length,
                          itemBuilder: (context, index) {
                            final faq = _filteredFaqs[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Question
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme
                                            .primaryContainer
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        faq['question'],
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Answer
                                    Text(
                                      faq['answer'],
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
