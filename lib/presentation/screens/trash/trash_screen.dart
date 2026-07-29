import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/repositories/document_repository.dart';
import '../../providers/document_provider.dart';
import '../../widgets/document_card.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashAsync = ref.watch(trashedDocumentsProvider);
    final repo = ref.read(documentRepositoryProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سلة المحذوفات'),
          actions: [
            trashAsync.when(
              data: (docs) => docs.isEmpty
                  ? const SizedBox.shrink()
                  : TextButton.icon(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text('حذف الكل', style: TextStyle(color: Colors.red)),
                      onPressed: () => _confirmEmptyTrash(context, ref, repo),
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        body: trashAsync.when(
          data: (docs) => docs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('سلة المحذوفات فارغة',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final doc = docs[i];
                    return DocumentCard(
                      document: doc,
                      onTap: () {},
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore, color: Colors.green),
                            tooltip: 'استعادة',
                            onPressed: () async {
                              await repo.restoreDocument(doc.id!);
                              ref.invalidate(trashedDocumentsProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تمت الاستعادة')),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                            tooltip: 'حذف نهائي',
                            onPressed: () async {
                              await repo.permanentlyDeleteDocument(doc.id!);
                              ref.invalidate(trashedDocumentsProvider);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }

  void _confirmEmptyTrash(BuildContext context, WidgetRef ref, DocumentRepository repo) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تفريغ سلة المحذوفات', style: TextStyle(fontFamily: 'Cairo')),
          content: const Text('سيتم حذف جميع المستندات نهائياً ولا يمكن التراجع. هل أنت متأكد؟', style: TextStyle(fontFamily: 'Cairo')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                await repo.emptyTrash();
                ref.invalidate(trashedDocumentsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف نهائي', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
