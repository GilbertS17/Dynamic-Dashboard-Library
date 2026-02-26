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
  final ScrollController _horizontalScrollController = ScrollController();
  late List<Map<K, V>> filteredData;
  String searchQuery = "";
  int currentPage = 0;
  final GlobalKey _tableKey = GlobalKey();
  double _tableContentWidth = 0;

  int get rowsPerPage => widget.config.rowsPerPage!;

  int get totalPages {
    if (filteredData.isEmpty) return 1;
    return (filteredData.length / rowsPerPage).ceil();
  }

  void _updateTableWidth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _tableKey.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        if (box.size.width != _tableContentWidth) {
          setState(() {
            _tableContentWidth = box.size.width;
          });
        }
      }
    });
  }

  List<Map<K, V>> get paginatedData {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage) > filteredData.length
        ? filteredData.length
        : start + rowsPerPage;

    return filteredData.sublist(start, end);
  }

  void _goToPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  double getSearchWidth(double width) {
    if (width > 1200) return 400;
    if (width > 800) return 300;
    return width; // full width on mobile
  }

  void _filterData(String query) {
    setState(() {
      searchQuery = query;
      currentPage = 0;

      if (query.isEmpty) {
        filteredData = widget.data;
      } else {
        filteredData = widget.data.where((row) {
          final searchableFields = widget.config.searchableFields?.cast<K>() ?? row.keys.toList();

          return searchableFields.any((field) {
            final value = row[field]?.toString().toLowerCase() ?? "";

            final words = query.toLowerCase().split(' ').where((w) => w.isNotEmpty);

            return words.every((word) => value.contains(word));
          });
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose(); // 👈 add this
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    filteredData = widget.data;
    _updateTableWidth();
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
              ? Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth - 32,
                      ),
                      child: DataTable(
                        key: _tableKey,
                        headingRowColor: MaterialStateProperty.all(
                          widget.config.headerBgColor.withOpacity(0.1),
                        ),
                        columns: columns.map((col) {
                          return DataColumn(
                            label: Text(
                              col.toString(),
                              style: widget.config.headerTextStyle ??
                                  TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: widget.config.headerBgColor,
                                  ),
                            ),
                          );
                        }).toList(),
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
                ),
              )
              // Paginated table
              : SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table
                    Expanded(
                      child: Scrollbar(
                        controller: _horizontalScrollController,
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth - 32, // minus container padding
                              ),
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  widget.config.headerBgColor.withOpacity(0.1),
                                ),
                                columns: columns.map(
                                      (col) => DataColumn(
                                    label: Text(
                                      col.toString(),
                                      style: widget.config.headerTextStyle ??
                                          TextStyle(fontWeight: FontWeight.bold, color: widget.config.headerBgColor),
                                    ),
                                  ),
                                ).toList(),
                                rows: paginatedData.map((row) {
                                  return DataRow(
                                    // onSelectChanged: (selected) {
                                    //   if (selected == true) {
                                    //     Navigator.pop(context, row); // return selected row
                                    //   }
                                    // },
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
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Custom Pagination Footer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Previous Button
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: currentPage > 0 ? () => _goToPage(currentPage - 1) : null,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: currentPage > 0 ? widget.config.headerBgColor : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_rounded,
                              size: 16,
                              color: currentPage > 0 ? Colors.white : Colors.grey.shade500,
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Page Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6,),
                          decoration: BoxDecoration(
                            color: widget.config.headerBgColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Page ${currentPage + 1} of $totalPages',
                            style: TextStyle(fontWeight: FontWeight.w600, color: widget.config.headerBgColor,),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Next Button
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: currentPage < totalPages - 1 ? () => _goToPage(currentPage + 1) : null,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: currentPage < totalPages - 1 ? widget.config.headerBgColor : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: currentPage < totalPages - 1 ? Colors.white : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        );
      },
    );
  }
}
