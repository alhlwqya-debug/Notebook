import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية للتطبيق
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9E97FF);
  static const Color primaryDark = Color(0xFF3D35CC);

  static const Color secondary = Color(0xFFFF6584);
  static const Color accent = Color(0xFF43E97B);

  // خلفيات
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color cardDark = Color(0xFF0F3460);

  // نصوص
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ألوان بطاقات الملاحظات
  static const List<Color> noteColors = [
    Color(0xFFFFFFFF), // أبيض
    Color(0xFFFFD6D6), // وردي فاتح
    Color(0xFFD6F0FF), // أزرق فاتح
    Color(0xFFD6FFD6), // أخضر فاتح
    Color(0xFFFFFFD6), // أصفر فاتح
    Color(0xFFE8D6FF), // بنفسجي فاتح
    Color(0xFFFFE8D6), // برتقالي فاتح
    Color(0xFFD6FFEE), // نعناعي فاتح
    Color(0xFFFFD6F0), // زهري فاتح
    Color(0xFFF0D6FF), // خزامى فاتح
    Color(0xFFD6F0D6), // سبانخ فاتح
    Color(0xFFFFECD6), // خوخي فاتح
  ];

  // ألوان بطاقات الملاحظات (الوضع الداكن)
  static const List<Color> noteColorsDark = [
    Color(0xFF2D2D3A),
    Color(0xFF4A2030),
    Color(0xFF1E3A4A),
    Color(0xFF1E3A2E),
    Color(0xFF3A3A1E),
    Color(0xFF2E1E4A),
    Color(0xFF3A2A1E),
    Color(0xFF1E3A30),
    Color(0xFF3A1E35),
    Color(0xFF301E3A),
    Color(0xFF1E3024),
    Color(0xFF3A2E1E),
  ];

  // ألوان الفئات
  static const List<Color> categoryColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43E97B),
    Color(0xFFFA8231),
    Color(0xFF2BCBBA),
    Color(0xFFF7B731),
    Color(0xFFFC5C7D),
    Color(0xFF6A3093),
    Color(0xFF11998E),
    Color(0xFFEB3349),
    Color(0xFF3498DB),
    Color(0xFF27AE60),
  ];

  // ألوان التصدير
  static const Color exportPdf = Color(0xFFEB3349);
  static const Color exportTxt = Color(0xFF3498DB);
  static const Color exportJson = Color(0xFF27AE60);
  static const Color exportHtml = Color(0xFFFA8231);
  static const Color exportMarkdown = Color(0xFF6C63FF);
  static const Color exportCsv = Color(0xFF2BCBBA);
  static const Color exportZip = Color(0xFF6A3093);
}
