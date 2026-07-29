import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/document.dart';
import '../../providers/document_provider.dart';
import '../../widgets/document_card.dart';
import '../../widgets/app_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentDocumentsProvider);
    final favorites = ref.watch(favoritesProvider);
    final docs = ref.watch(documentsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('الرئيسية'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.push(AppRoutes.search),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(recentDocumentsProvider);
            ref.invalidate(favoritesProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Stats row
              SliverToBoxAdapter(
                child: _StatsRow(totalDocs: docs.documents.length),
              ),

              // Quick actions
              SliverToBoxAdapter(
                child: _QuickActions(),
              ),

              // Recent documents
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المستندات الأخيرة',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.documents),
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                ),
              ),

              recent.when(
                data: (list) => list.isEmpty
                    ? const SliverToBoxAdapter(child: _EmptyRecent())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => DocumentCard(
                            document: list[index],
                            onTap: () => context.push(
                              '/documents/${list[index].id}',
                            ),
                          ),
                          childCount: list.length > 5 ? 5 : list.length,
                        ),
                      ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(child: Text(e.toString())),
                ),
              ),

              // Favorites
              favorites.when(
                data: (list) => list.isEmpty
                    ? const SliverToBoxAdapter(child: SizedBox.shrink())
                    : SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'المفضلة',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  TextButton(
                                    onPressed: () => context.go(AppRoutes.favorites),
                                    child: const Text('عرض الكل'),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: list.length > 5 ? 5 : list.length,
                                itemBuilder: (ctx, i) =>
                                    _FavoriteChip(document: list[i]),
                              ),
                            ),
                          ],
                        ),
                      ),
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.editor),
          icon: const Icon(Icons.add),
          label: const Text('مستند جديد', style: TextStyle(fontFamily: 'Cairo')),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int totalDocs;
  const _StatsRow({required this.totalDocs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'إجمالي المستندات',
            value: totalDocs.toString(),
            icon: Icons.description,
          ),
          _StatItem(
            label: 'اليوم',
            value: AppDateUtils.formatDate(DateTime.now()),
            icon: Icons.today,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontFamily: 'Cairo', fontSize: 11)),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action('ملاحظة', Icons.note_add, AppColors.noteColor),
      _Action('دفتر', Icons.book, AppColors.notebookColor),
      _Action('محاضرة', Icons.school, AppColors.lectureColor),
      _Action('تقرير', Icons.assessment, AppColors.reportColor),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('إنشاء سريع', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: actions
                .map((a) => _QuickActionBtn(action: a, context: context))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  const _Action(this.label, this.icon, this.color);
}

class _QuickActionBtn extends StatelessWidget {
  final _Action action;
  final BuildContext context;
  const _QuickActionBtn({required this.action, required this.context});

  @override
  Widget build(BuildContext _) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.editor),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: action.color.withOpacity(0.3)),
            ),
            child: Icon(action.icon, color: action.color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(action.label,
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 12, color: action.color)),
        ],
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('لا توجد مستندات بعد',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text('ابدأ بإنشاء أول مستند لك',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _FavoriteChip extends StatelessWidget {
  final Document document;
  const _FavoriteChip({required this.document});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/documents/${document.id}'),
      child: Container(
        width: 100,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(height: 8),
            Text(
              document.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
