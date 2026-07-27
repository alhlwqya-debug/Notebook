import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../constants/app_colors.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';
import '../utils/importers/import_service.dart';
import '../widgets/note_card.dart';
import '../widgets/custom_app_bar.dart';
import 'editor/rich_note_editor_screen.dart';
import 'template_designer/template_designer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabController;
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar(provider: provider),
          body: Column(
            children: [
              // شريط البحث
              if (provider.searchQuery.isNotEmpty || true)
                _buildSearchAndFilter(provider),
              // شريط التصنيفات
              _buildCategoryFilter(provider),
              // قائمة الملاحظات
              Expanded(
                child: _buildNotesList(provider),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(provider),
          floatingActionButton: _buildFab(provider),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        );
      },
    );
  }

  Widget _buildSearchAndFilter(NoteProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث في ملاحظاتك...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: provider.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: provider.clearSearch,
                )
              : null,
        ),
        onChanged: provider.setSearchQuery,
      ),
    );
  }

  Widget _buildCategoryFilter(NoteProvider provider) {
    final categories = [
      {'name': 'الكل', 'value': null},
      ...provider.categories.map((c) => {'name': c['name'], 'value': c['name']}),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = provider.selectedCategory == cat['value'];
          return GestureDetector(
            onTap: () => provider.setCategory(cat['value'] as String?),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Text(
                cat['name'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primary,
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotesList(NoteProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.notes.isEmpty) {
      return _buildEmptyState(provider);
    }

    if (provider.isGridView) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: provider.notes.length,
          itemBuilder: (context, index) {
            return AnimatedNoteCard(
              note: provider.notes[index],
              onTap: () => _openNote(provider.notes[index]),
              index: index,
            );
          },
        ),
      );
    } else {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
        itemCount: provider.notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return AnimatedNoteCard(
            note: provider.notes[index],
            onTap: () => _openNote(provider.notes[index]),
            index: index,
            isListView: true,
          );
        },
      );
    }
  }

  Widget _buildEmptyState(NoteProvider provider) {
    String message;
    String submessage;
    IconData icon;

    switch (provider.currentFilter) {
      case NoteFilter.pinned:
        icon = Icons.push_pin_outlined;
        message = 'لا توجد ملاحظات مثبتة';
        submessage = 'قم بتثبيت الملاحظات المهمة لتظهر هنا';
        break;
      case NoteFilter.favorites:
        icon = Icons.favorite_outline;
        message = 'لا توجد ملاحظات مفضلة';
        submessage = 'أضف ملاحظاتك المفضلة لتظهر هنا';
        break;
      case NoteFilter.templates:
        icon = Icons.dashboard_customize_outlined;
        message = 'لا توجد ملاحظات بقوالب';
        submessage = 'أنشئ ملاحظة واختر قالباً لتظهر هنا';
        break;
      default:
        icon = Icons.note_add_outlined;
        message = provider.searchQuery.isNotEmpty ? 'لم يُعثر على نتائج' : 'لا توجد ملاحظات بعد';
        submessage = provider.searchQuery.isNotEmpty
            ? 'جرّب كلمات بحث مختلفة'
            : 'اضغط + لإنشاء ملاحظتك الأولى';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            submessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(NoteProvider provider) {
    return BottomNavigationBar(
      currentIndex: provider.currentFilter.index,
      onTap: (index) => provider.setFilter(NoteFilter.values[index]),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.notes_outlined),
          activeIcon: const Icon(Icons.notes),
          label: 'الكل (${provider.totalNotes})',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.push_pin_outlined),
          activeIcon: const Icon(Icons.push_pin),
          label: 'المثبتة (${provider.pinnedCount})',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite_outline),
          activeIcon: const Icon(Icons.favorite),
          label: 'المفضلة (${provider.favoritesCount})',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_customize_outlined),
          activeIcon: Icon(Icons.dashboard_customize),
          label: 'القوالب',
        ),
      ],
    );
  }

  Widget _buildFab(NoteProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // خيارات FAB الموسعة
        if (_isFabExpanded) ...[
          _buildFabOption(
            icon: Icons.file_download_outlined,
            label: 'استيراد ملف',
            onTap: () async {
              _toggleFab();
              await _importFile(provider);
            },
          ),
          const SizedBox(height: 8),
          _buildFabOption(
            icon: Icons.dashboard_customize_outlined,
            label: 'قالب جديد',
            onTap: () {
              _toggleFab();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TemplateDesignerScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildFabOption(
            icon: Icons.note_add_outlined,
            label: 'ملاحظة جديدة',
            onTap: () {
              _toggleFab();
              _createNewNote();
            },
          ),
          const SizedBox(height: 8),
        ],
        // زر FAB الرئيسي
        FloatingActionButton(
          onPressed: _isFabExpanded ? _toggleFab : _createNewNote,
          child: AnimatedRotation(
            turns: _isFabExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createNewNote() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const RichNoteEditorScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );
        },
      ),
    );
  }

  void _openNote(NoteModel note) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => RichNoteEditorScreen(note: note),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _importFile(NoteProvider provider) async {
    try {
      final notes = await ImportService.instance.pickAndImportFile();
      if (notes != null && notes.isNotEmpty && mounted) {
        await provider.importNotes(notes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم استيراد ${notes.length} ملاحظة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الاستيراد: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
