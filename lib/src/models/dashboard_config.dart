import 'package:flutter/material.dart';

class DashboardConfig {
  final Color headerBgColor;
  final Color searchBgColor;
  final TextStyle? headerTextStyle;
  final TextStyle? cellTextStyle;
  final List<String>? searchableFields;
  final dynamic searchWidth;
  final double? tableHeight;
  final double? tableWidth;
  final int? rowsPerPage;

  const DashboardConfig({
    this.headerBgColor = Colors.blue,
    this.searchBgColor = Colors.grey,
    this.headerTextStyle,
    this.cellTextStyle,
    this.searchableFields,
    this.searchWidth,
    this.tableHeight,
    this.tableWidth,
    this.rowsPerPage,
  });
}