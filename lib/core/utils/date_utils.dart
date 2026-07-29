import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'ar').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'ar').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    if (diff.inDays < 365) return 'منذ ${(diff.inDays / 30).floor()} شهر';
    return 'منذ ${(diff.inDays / 365).floor()} سنة';
  }

  static String toIso(DateTime date) => date.toIso8601String();

  static DateTime fromIso(String iso) => DateTime.parse(iso);
}
