import 'package:flutter/material.dart';
import 'models/dashboard_config.dart';

class DashboardSearch extends StatelessWidget {
  final DashboardConfig config;
  final ValueChanged<String> onChanged;

  const DashboardSearch({
    Key? key,
    required this.config,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText:
        "Search in ${config.searchableFields?.join(", ") ?? "table"}",
        prefixIcon: Icon(Icons.search, color: config.headerBgColor),
        filled: true,
        fillColor: config.searchBgColor.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: onChanged,
    );
  }
}