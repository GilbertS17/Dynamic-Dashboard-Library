import 'package:flutter/material.dart';

class DashboardDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final List<String> columns;
  final TextStyle? cellTextStyle;

  DashboardDataSource({
    required this.data,
    required this.columns,
    this.cellTextStyle,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;

    final row = data[index];

    return DataRow(
      cells: columns.map((col) {
        return DataCell(
          Text(
            row[col]?.toString() ?? '',
            style: cellTextStyle,
          ),
        );
      }).toList(),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

