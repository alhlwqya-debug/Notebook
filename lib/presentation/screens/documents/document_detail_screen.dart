import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../providers/document_provider.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final int documentId;
  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docAsync = ref.watch(documentByIdProvider(documentId));
    final notifier = ref.read(documentsProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: docAsync.when(
        data: (doc) {
          if (doc == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('المستند غير موجود')),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(doc.title),
              leading: BackButton(onPressed: () => context.pop()),
              actions: [
                // Favorite
                IconButton(
                  icon: Icon(
                    doc.isFavorite ? Icons.star : Icons.star_border,
                    color: doc.isFavorite ? Colors.amber : null,
                  ),
                  onPressed: () {
                    notifier.toggleFavorite(documentId);
                    ref.invalidate(documentByIdProvider(documentId));
                  },
                ),
                // Edit
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push(
                    AppRoutes.editor,
                    extra: {'documentId': documentId},
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (val) => _handleAction(context, ref, val, notifier),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'share', child: Text('مشاركة', style: TextStyle(fontFamily: 'Cairo'))),
                    const PopupMenuItem(value: 'duplicate', child: Text('نسخ', style: TextStyle(fontFamily: 'Cairo'))),
                    const PopupMenuItem(value: 'archive', child: Text('أرشفة', style: TextStyle(fontFamily: 'Cairo'))),
                    const PopupMenuItem(value: 'delete', child: Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: Colors.red))),
                  ],
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _MetaItem(
                          icon: Icons.calendar_today,
                          label: 'إنشاء',
                          value: AppDateUtils.formatDate(doc.createdAt),
                        ),
                        _MetaItem(
                          icon: Icons.update,
                          label: 'تعديل',
                          value: AppDateUtils.formatRelative(doc.updatedAt),
                        ),
                        _MetaItem(
                          icon: Icons.text_fields,
                          label: 'كلمات',
                          value: doc.wordCount.toString(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Type chip
                  if (doc.typeName != null)
                    Chip(
                      label: Text(doc.typeName!,
                          style: const TextStyle(fontFamily: 'Cairo')),
                      avatar: const Icon(Icons.label_outline, size: 16),
                    ),

                  const SizedBox(height: 16),

                  // Content
                  SelectableText(
                    doc.content.isEmpty ? 'لا يوجد محتوى' : doc.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.8,
                          color: doc.content.isEmpty ? Colors.grey : null,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref,
      String action, DocumentsNotifier notifier) {
    switch (action) {
      case 'share':
        ref.read(documentByIdProvider(documentId)).whenData((doc) {
          if (doc != null) Share.share('${doc.title}\n\n${doc.content}');
        });
        break;
      case 'duplicate':
        notifier.duplicateDocument(documentId);
        context.pop();
        break;
      case 'archive':
        notifier.archiveDocument(documentId);
        context.pop();
        break;
      case 'delete':
        notifier.deleteDocument(documentId);
        context.pop();
        break;
    }
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _MetaItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
