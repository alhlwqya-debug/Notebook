class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Notebook';
  static const String appVersion = '2.0.0';
  static const String appAuthor = 'أحمد عبد الودود الدبعي';
  static const String appCopyright = '© 2025 أحمد عبد الودود الدبعي';

  // Database
  static const String dbName = 'notebook.db';
  static const int dbVersion = 1;

  // Pagination
  static const int pageSize = 20;

  // Auto-save interval in seconds
  static const int autoSaveInterval = 5;

  // Document types
  static const List<Map<String, dynamic>> defaultDocumentTypes = [
    {'id': 1, 'name': 'ملاحظة', 'icon': 'note', 'color': 0xFF4CAF50},
    {'id': 2, 'name': 'دفتر', 'icon': 'book', 'color': 0xFF2196F3},
    {'id': 3, 'name': 'محاضرة', 'icon': 'school', 'color': 0xFF9C27B0},
    {'id': 4, 'name': 'تقرير', 'icon': 'assessment', 'color': 0xFFFF9800},
    {'id': 5, 'name': 'فاتورة', 'icon': 'receipt', 'color': 0xFFF44336},
    {'id': 6, 'name': 'عقد', 'icon': 'description', 'color': 0xFF795548},
    {'id': 7, 'name': 'كتاب', 'icon': 'menu_book', 'color': 0xFF607D8B},
    {'id': 8, 'name': 'برمجة', 'icon': 'code', 'color': 0xFF00BCD4},
    {'id': 9, 'name': 'Markdown', 'icon': 'markdown', 'color': 0xFF3F51B5},
    {'id': 10, 'name': 'HTML', 'icon': 'html', 'color': 0xFFE91E63},
    {'id': 11, 'name': 'نص عادي', 'icon': 'text_snippet', 'color': 0xFF9E9E9E},
    {'id': 12, 'name': 'JSON', 'icon': 'data_object', 'color': 0xFFFF5722},
    {'id': 13, 'name': 'CSV', 'icon': 'table_chart', 'color': 0xFF8BC34A},
    {'id': 14, 'name': 'مخصص', 'icon': 'create', 'color': 0xFFFF4081},
  ];

  // Export formats
  static const List<String> exportFormats = [
    'PDF', 'TXT', 'DOCX', 'HTML', 'Markdown', 'JSON', 'CSV', 'ZIP'
  ];

  // Default categories
  static const List<Map<String, dynamic>> defaultCategories = [
    {'id': 1, 'name': 'عام', 'color': 0xFF9E9E9E},
    {'id': 2, 'name': 'عمل', 'color': 0xFF2196F3},
    {'id': 3, 'name': 'شخصي', 'color': 0xFF4CAF50},
    {'id': 4, 'name': 'دراسة', 'color': 0xFF9C27B0},
    {'id': 5, 'name': 'مشاريع', 'color': 0xFFFF9800},
  ];
}
