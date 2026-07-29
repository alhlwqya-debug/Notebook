import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/document_provider.dart';
import '../../widgets/document_card.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archiveAsync = ref.watch(archivedDocumentsProvider);
    final notifier = ref.read(documentsProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الأرشيف')),
        body: archiveAsync.when(
          data: (docs) => docs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.archive_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('الأرشيف فارغ',
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
                      onTap: () => context.push('/documents/${doc.id}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.unarchive),
                        tooltip: 'استعادة',
                        onPressed: () {
                          notifier.archiveDocument(doc.id!);
                          ref.invalidate(archivedDocumentsProvider);
                        },
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
}
