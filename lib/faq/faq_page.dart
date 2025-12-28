import 'package:flutter/material.dart';

import '../shared/widgets/app_bar_x.dart';
import '../shared/widgets/button_x.dart';
import '../shared/widgets/dialog_x.dart';
import '../translations/translation_extension.dart';
import 'faq_service.dart';

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
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

      // Extract unique categories
      final categoriesSet = <String>{'All'};
      for (var faq in faqList) {
        if (faq['category'] != null && faq['category'].toString().isNotEmpty) {
          categoriesSet.add(faq['category']);
        }
      }

      setState(() {
        _faqs = faqList;
        _filteredFaqs = faqList;
        _categories = categoriesSet.toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _filterFaqs() {
    setState(() {
      _filteredFaqs = _faqs.where((faq) {
        // Filter by category
        final categoryMatch =
            _selectedCategory == 'All' || faq['category'] == _selectedCategory;

        // Filter by search text
        final searchText = _searchController.text.toLowerCase();
        final textMatch =
            searchText.isEmpty ||
            faq['question'].toString().toLowerCase().contains(searchText) ||
            faq['answer'].toString().toLowerCase().contains(searchText);

        return categoryMatch && textMatch;
      }).toList();
    });
  }

  void _showFaqDetail(dynamic faq) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => DialogX(
        title: 'FAQ',
        width: 600,
        onClose: () => Navigator.pop(context),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category badge
            if (faq['category'] != null &&
                faq['category'].toString().isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  faq['category'],
                  style: TextStyle(
                    fontSize: 16.0,
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Question
            Text(
              faq['question'],
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            // Answer
            Text(
              faq['answer'],
              style: TextStyle(
                fontSize: 16.0,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          ButtonX(
            onPressed: () => Navigator.pop(context),
            icon: Icons.close,
            label: 'close'.tr,
            backgroundColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBarX(title: 'faq'.tr),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and filter section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.surface,
                  child: Column(
                    children: [
                      // Search bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search FAQs...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterFaqs();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) => _filterFaqs(),
                      ),
                      const SizedBox(height: 12),
                      // Category filter
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected = _selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                  _filterFaqs();
                                },
                                selectedColor:
                                    theme.colorScheme.primaryContainer,
                                checkmarkColor:
                                    theme.colorScheme.onPrimaryContainer,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Results count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.3,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${_filteredFaqs.length} FAQ(s) found',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
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
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredFaqs.length,
                          itemBuilder: (context, index) {
                            final faq = _filteredFaqs[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _showFaqDetail(faq),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Category badge
                                      if (faq['category'] != null &&
                                          faq['category'].toString().isNotEmpty)
                                        Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme
                                                .primaryContainer,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            faq['category'],
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: theme
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      // Question
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.help_outline,
                                            size: 20,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              faq['question'],
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Answer preview
                                      Text(
                                        faq['answer'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
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
