import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../domain/entities/template.dart';
import '../../providers/template_provider.dart';
import '../../widgets/template_card.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);
    final notifier = ref.read(templatesProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('القوالب'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateTemplateSheet(context, ref),
            ),
          ],
        ),
        body: templatesAsync.when(
          data: (templates) {
            final defaults = templates.where((t) => t.isDefault).toList();
            final custom = templates.where((t) => !t.isDefault).toList();

            return CustomScrollView(
              slivers: [
                if (defaults.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('القوالب الجاهزة',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => TemplateCard(
                        template: defaults[i],
                        onTap: () => context.push(AppRoutes.editor, extra: {'templateId': defaults[i].id}),
                        onDelete: null,
                      ),
                      childCount: defaults.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1,
                    ),
                  ),
                ],
                if (custom.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Text('قوالبي',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => TemplateCard(
                        template: custom[i],
                        onTap: () => context.push(AppRoutes.editor, extra: {'templateId': custom[i].id}),
                        onDelete: () => notifier.deleteTemplate(custom[i].id!),
                      ),
                      childCount: custom.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1,
                    ),
                  ),
                ],
                if (templates.isEmpty)
                  const SliverFillRemaining(child: _EmptyTemplates()),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }

  void _showCreateTemplateSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('قالب جديد', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(labelText: 'اسم القالب *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(labelText: 'وصف القالب'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                textDirection: TextDirection.rtl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'محتوى القالب'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      final now = DateTime.now();
                      ref.read(templatesProvider.notifier).createTemplate(
                        Template(
                          name: nameController.text.trim(),
                          description: descController.text.trim(),
                          content: contentController.text,
                          isDefault: false,
                          createdAt: now,
                          updatedAt: now,
                        ),
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('إنشاء القالب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTemplates extends StatelessWidget {
  const _EmptyTemplates();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('لا توجد قوالب', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}
