import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        child: Column(
          children: [
            // Header
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.menu_book_rounded, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  const Text(
                    'Notebook',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'إدارة مستنداتك بسهولة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.home,
                    title: 'الرئيسية',
                    onTap: () { Navigator.pop(context); context.go(AppRoutes.home); },
                  ),
                  _DrawerItem(
                    icon: Icons.description,
                    title: 'المستندات',
                    onTap: () { Navigator.pop(context); context.go(AppRoutes.documents); },
                  ),
                  _DrawerItem(
                    icon: Icons.library_books,
                    title: 'القوالب',
                    onTap: () { Navigator.pop(context); context.go(AppRoutes.templates); },
                  ),
                  _DrawerItem(
                    icon: Icons.folder,
                    title: 'المجلدات',
                    onTap: () { Navigator.pop(context); context.go(AppRoutes.folders); },
                  ),
                  const Divider(),
                  _DrawerItem(
                    icon: Icons.star,
                    title: 'المفضلة',
                    onTap: () { Navigator.pop(context); context.go(AppRoutes.favorites); },
                  ),
                  _DrawerItem(
                    icon: Icons.archive,
                    title: 'الأرشيف',
                    onTap: () { Navigator.pop(context); context.go(AppRoutes.archive); },
                  ),
                  _DrawerItem(
                    icon: Icons.delete,
                    title: 'سلة المحذوفات',
                    onTap: () { Navigator.pop(context); context.go(AppRoutes.trash); },
                  ),
                  const Divider(),
                  _DrawerItem(
                    icon: Icons.settings,
                    title: 'الإعدادات',
                    onTap: () { Navigator.pop(context); context.go(AppRoutes.settings); },
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppConstants.appCopyright,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontFamily: 'Cairo')),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
