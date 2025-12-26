import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class DataTableX extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double? maxHeight;
  final double? columnSpacing;
  final Color? headingRowColor;

  const DataTableX({
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              SizedBox(width: 24), // Match horizontalMargin
              ...columns.asMap().entries.expand((entry) {
                final column = entry.value;
                final isLast = entry.key == columns.length - 1;

                return [
                  Expanded(
                    child: Align(
                      alignment: column.numeric
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: column.label,
                    ),
                  ),
                  if (!isLast) SizedBox(width: spacing),
                ];
              }),
              SizedBox(width: 24), // Match horizontalMargin
            ],
          ),
        ),
        // Scrollable body
        if (isFullHeight)
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
                physics: const ClampingScrollPhysics(),
              ),
              child: DataTable2(
                headingRowHeight: 0,
                showCheckboxColumn: false,
                dividerThickness: 0.2,
                horizontalMargin: 24,
                columnSpacing: spacing,
                columns: columns.map((col) {
                  return DataColumn2(
                    label: const SizedBox.shrink(),
                    numeric: col.numeric,
                  );
                }).toList(),
                rows: rows,
              ),
            ),
          )
        else
          SizedBox(
            height: maxHeight ?? MediaQuery.of(context).size.height * 0.4,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
                physics: const ClampingScrollPhysics(),
              ),
              child: DataTable2(
                headingRowHeight: 0,
                showCheckboxColumn: false,
                dividerThickness: 0.2,
                horizontalMargin: 24,
                columnSpacing: spacing,
                columns: columns.map((col) {
                  return DataColumn2(
                    label: const SizedBox.shrink(),
                    numeric: col.numeric,
                  );
                }).toList(),
                rows: rows,
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
