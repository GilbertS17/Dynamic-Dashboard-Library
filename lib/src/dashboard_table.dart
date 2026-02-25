import 'package:flutter/material.dart';
import 'models/dashboard_config.dart';
import 'dashboard_data_source.dart';
import 'dashboard_search.dart';

class DynamicDashboard<K, V> extends StatefulWidget {
  final List<Map<K, V>> data;
  final DashboardConfig config;

  const DynamicDashboard({
    Key? key,
    required this.data,
    this.config = const DashboardConfig(),
  }) : super(key: key);

  @override
  State<DynamicDashboard<K, V>> createState() => _DynamicDashboardState<K, V>();
}

class _DynamicDashboardState<K, V> extends State<DynamicDashboard<K, V>> {

  late List<Map<K, V>> filteredData;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredData = widget.data;
  }
  double getSearchWidth(double width) {
    if (width > 1200) return 400;
    if (width > 800) return 300;
    return width; // full width on mobile
  }

  void _filterData(String query) {
    setState(() {
      searchQuery = query;

      if (query.isEmpty) {
        filteredData = widget.data;
      } else {
        filteredData = widget.data.where((row) {
          final searchableFields = widget.config.searchableFields?.cast<K>() ?? row.keys.toList();

          return searchableFields.any((field) {
            final value = row[field]?.toString().toLowerCase() ?? "";
            return value.contains(query.toLowerCase());
          });
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(child: Text("No Data"));
    }

    final columns = widget.data.first.keys.toList().cast<K>();
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.config.tableWidth ?? 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: widget.config.searchWidth == 'Auto'
                        ? getSearchWidth(constraints.maxWidth)
                        : widget.config.searchWidth as double?,
                    child: DashboardSearch(
                      config: widget.config,
                      onChanged: _filterData,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            (widget.config.tableHeight == null)
                ? Expanded(child: _buildTable(columns))
                : SizedBox(
                    height: widget.config.tableHeight as double,
                    child: _buildTable(columns),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<K> columns) {
    final dataSource = DashboardDataSource<K, V>(
      data: filteredData,
      columns: columns,
      cellTextStyle: widget.config.cellTextStyle,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: (widget.config.rowsPerPage == null)
              // Non-paginated table
              ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth - 32,
                      ),
                      // match container width minus padding
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          widget.config.headerBgColor.withOpacity(0.1),
                        ),
                        columns: columns
                            .map(
                              (col) => DataColumn(
                                label: Text(
                                  col.toString(),
                                  style:
                                      widget.config.headerTextStyle ??
                                      TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: widget.config.headerBgColor,
                                      ),
                                ),
                              ),
                            )
                            .toList(),
                        rows: filteredData.map((row) {
                          return DataRow(
                            cells: columns.map((col) {
                              return DataCell(
                                Text(
                                  row[col]?.toString() ?? '',
                                  style: widget.config.cellTextStyle,
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              // Paginated table
              : Theme(
            data: Theme.of(context).copyWith(
              cardColor: Colors.white, // 👈 this controls the paginated table's footer/card background
              dataTableTheme: DataTableThemeData(
                headingRowColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) => Colors.white,
                ),
                dataRowColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) => Colors.white,
                ),
              ),
            ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: PaginatedDataTable(
                              // arrowHeadColor: Colors.white,

                    rowsPerPage: widget.config.rowsPerPage!,
                    headingRowColor: MaterialStateProperty.all(
                      widget.config.headerBgColor.withOpacity(0.1),
                    ),
                    columns: columns.map((col) =>
                        DataColumn(
                            label: Text(
                              col.toString(),
                              style:
                                  widget.config.headerTextStyle ??
                                  TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: widget.config.headerBgColor,
                                  ),
                            ),
                          ),
                        )
                        .toList(),
                    source: dataSource,
                  ),
                ),
              ),
        );
      },
    );
  }
}
