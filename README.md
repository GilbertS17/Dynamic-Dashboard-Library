# Dynamic Dashboard Flutter Library

A **dynamic, modern, and customizable dashboard** widget for Flutter applications. It supports:

- Dynamic input data (`List<Map<String, dynamic>>`)
- Search filtering
- Horizontal & vertical scrolling
- Optional pagination
- Customizable colors and text styles
- Responsive layout

---

## Features

- **Dynamic Columns & Rows:** The dashboard automatically adapts to the keys in your input `Map`.
- **Search Functionality:** Filter rows by any field or a subset of fields.
- **Pagination:** Optional paginated view with customizable rows per page.
- **Customizable Styles:** Primary color, accent color, header styles, and cell text styles.
- **Responsive Width:** Table and search bar adjust according to screen size.
- **Modern UI:** Rounded container, shadows, and clean design.

---

## Installation

Add the library to your project (or copy the `dynamic_dashboard` folder into your project).

```yaml
dependencies:
  flutter:
    sdk: flutter
```
## Usage
```dart
import 'package:flutter/material.dart';
import 'dynamic_dashboard/dynamic_dashboard.dart';

final productsList = [
  {
    "productID": "P001",
    "Description": "iPhone 15",
    "qty": 5,
    "unitPrice": 1200
  },
  {
    "productID": "P002",
    "Description": "Samsung S24",
    "qty": 8,
    "unitPrice": 950
  },
];

DynamicDashboard(
  data: productsList,
  config: DashboardConfig(
    primaryColor: Colors.blue,
    accentColor: Colors.orange,
    searchableFields: ['Description', 'productID'],
    rowsPerPage: 10, // optional: set null for non-paginated
    tableHeight: 400, // optional: can be 'Full' or numeric
  ),
)
```
