import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/documents/documents_screen.dart';
import '../../presentation/screens/documents/document_detail_screen.dart';
import '../../presentation/screens/editor/editor_screen.dart';
import '../../presentation/screens/folders/folders_screen.dart';
import '../../presentation/screens/templates/templates_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/archive/archive_screen.dart';
import '../../presentation/screens/trash/trash_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.documents,
            builder: (context, state) => const DocumentsScreen(),
          ),
          GoRoute(
            path: AppRoutes.folders,
            builder: (context, state) => const FoldersScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: AppRoutes.archive,
            builder: (context, state) => const ArchiveScreen(),
          ),
          GoRoute(
            path: AppRoutes.trash,
            builder: (context, state) => const TrashScreen(),
          ),
          GoRoute(
            path: AppRoutes.templates,
            builder: (context, state) => const TemplatesScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.documentDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DocumentDetailScreen(documentId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.editor,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return EditorScreen(
            documentId: extra?['documentId'] as int?,
            templateId: extra?['templateId'] as int?,
            typeId: extra?['typeId'] as int?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
    ],
  );
});

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String documents = '/documents';
  static const String documentDetail = '/documents/:id';
  static const String editor = '/editor';
  static const String folders = '/folders';
  static const String templates = '/templates';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String archive = '/archive';
  static const String trash = '/trash';
  static const String settings = '/settings';
}

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<String> _routes = [
    AppRoutes.home,
    AppRoutes.documents,
    AppRoutes.folders,
    AppRoutes.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 2) {
            // FAB action - create new
            _showCreateBottomSheet(context);
            return;
          }
          final routeIndex = index > 2 ? index - 1 : index;
          context.go(_routes[routeIndex]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'المستندات',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'جديد',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'المجلدات',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }

  void _showCreateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const CreateBottomSheet(),
    );
  }
}

class CreateBottomSheet extends StatelessWidget {
  const CreateBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'إنشاء جديد',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CreateOption(
                  icon: Icons.description,
                  label: 'مستند',
                  color: const Color(0xFF2196F3),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.editor);
                  },
                ),
                _CreateOption(
                  icon: Icons.create_new_folder,
                  label: 'مجلد',
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.folders);
                  },
                ),
                _CreateOption(
                  icon: Icons.library_books,
                  label: 'قالب',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.templates);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
