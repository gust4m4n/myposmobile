import 'package:flutter/material.dart';

class ScrollableDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double? maxHeight;
  final double? columnSpacing;
  final Color? headingRowColor;

  const ScrollableDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.maxHeight,
    this.columnSpacing,
    this.headingRowColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultHeadingColor =
        headingRowColor ?? theme.colorScheme.primary.withOpacity(0.1);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.4,
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            overscroll: false,
            physics: const ClampingScrollPhysics(),
          ),
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(defaultHeadingColor),
              columnSpacing: columnSpacing ?? 16,
              columns: columns,
              rows: rows,
            ),
          ),
        ),
      ),
    );
  }
}

class DataTableColumn {
  static DataColumn buildColumn({
    required BuildContext context,
    required String label,
    bool numeric = false,
    Color? labelColor,
  }) {
    final theme = Theme.of(context);
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: labelColor ?? theme.colorScheme.primary,
        ),
      ),
      numeric: numeric,
    );
  }
}
