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
    final spacing = columnSpacing ?? 16;
    final isFullHeight = maxHeight == double.infinity;

    return Column(
      mainAxisSize: isFullHeight ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed header
        Container(
          color: defaultHeadingColor,
          child: Row(
            children: columns.asMap().entries.map((entry) {
              final column = entry.value;
              final isLast = entry.key == columns.length - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: entry.key == 0 ? 12 : spacing / 2,
                    right: isLast ? 12 : spacing / 2,
                    top: 12,
                    bottom: 12,
                  ),
                  child: Align(
                    alignment: column.numeric
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: column.label,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Scrollable body
        if (isFullHeight)
          Expanded(
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
                    headingRowHeight: 0,
                    showCheckboxColumn: false,
                    columnSpacing: spacing,
                    columns: columns.map((col) {
                      return DataColumn(
                        label: const SizedBox.shrink(),
                        numeric: col.numeric,
                      );
                    }).toList(),
                    rows: rows,
                  ),
                ),
              ),
            ),
          )
        else
          ConstrainedBox(
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
                    headingRowHeight: 0,
                    showCheckboxColumn: false,
                    columnSpacing: spacing,
                    columns: columns.map((col) {
                      return DataColumn(
                        label: const SizedBox.shrink(),
                        numeric: col.numeric,
                      );
                    }).toList(),
                    rows: rows,
                  ),
                ),
              ),
            ),
          ),
      ],
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
