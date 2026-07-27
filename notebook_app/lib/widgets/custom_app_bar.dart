import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../providers/note_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final NoteProvider provider;

  const CustomAppBar({super.key, required this.provider});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.book_outlined, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'دفتري',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          ),
        ],
      ),
      actions: [
        // زر تبديل العرض
        IconButton(
          icon: Icon(provider.isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: provider.toggleViewMode,
          tooltip: provider.isGridView ? 'عرض قائمة' : 'عرض شبكي',
        ),
        // زر الترتيب
        PopupMenuButton<SortOrder>(
          icon: const Icon(Icons.sort),
          tooltip: 'ترتيب',
          onSelected: provider.setSortOrder,
          itemBuilder: (_) => [
            _buildSortItem(SortOrder.newest, 'الأحدث أولاً', Icons.arrow_downward, provider),
            _buildSortItem(SortOrder.oldest, 'الأقدم أولاً', Icons.arrow_upward, provider),
            _buildSortItem(SortOrder.alphabetical, 'أبجدياً', Icons.sort_by_alpha, provider),
            _buildSortItem(SortOrder.colorGrouped, 'حسب اللون', Icons.palette_outlined, provider),
          ],
        ),
        // قائمة الإعدادات
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'theme',
              child: Row(
                children: [
                  Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(provider.isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
                      style: const TextStyle(fontFamily: 'Tajawal')),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  Icon(Icons.archive_outlined, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('الأرشيف', style: TextStyle(fontFamily: 'Tajawal')),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'about',
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('عن التطبيق', style: TextStyle(fontFamily: 'Tajawal')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<SortOrder> _buildSortItem(
    SortOrder order,
    String label,
    IconData icon,
    NoteProvider provider,
  ) {
    final isSelected = provider.sortOrder == order;
    return PopupMenuItem(
      value: order,
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              color: isSelected ? AppColors.primary : null,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, color: AppColors.primary, size: 18),
          ],
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'theme':
        provider.toggleDarkMode();
        break;
      case 'archive':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الأرشيف قريباً')),
        );
        break;
      case 'about':
        showAboutDialog(
          context: context,
          applicationName: 'دفتري',
          applicationVersion: '1.0.0',
          applicationIcon: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.book_outlined, color: Colors.white, size: 28),
          ),
          children: [
            const Text(
              'دفتري - تطبيق دفتر الملاحظات المتقدم للغة العربية\n\nيتيح إنشاء وتحرير الملاحظات بتنسيقات متقدمة مع دعم كامل للعربية.',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ],
        );
        break;
    }
  }
}
