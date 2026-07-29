import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../domain/entities/document.dart';
import '../../providers/document_provider.dart';
import '../../widgets/document_card.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(documentsProvider);
    final notifier = ref.read(documentsProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('المستندات (${state.documents.length})'),
          actions: [
            // View toggle
            IconButton(
              icon: Icon(
                state.viewMode == ViewMode.list
                    ? Icons.grid_view
                    : Icons.list,
              ),
              onPressed: () => notifier.setViewMode(
                state.viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list,
              ),
            ),
            // Sort
            PopupMenuButton<DocumentSort>(
              icon: const Icon(Icons.sort),
              onSelected: notifier.setSortBy,
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: DocumentSort.updatedAt,
                  child: Text('تاريخ التعديل', style: TextStyle(fontFamily: 'Cairo')),
                ),
                const PopupMenuItem(
                  value: DocumentSort.createdAt,
                  child: Text('تاريخ الإنشاء', style: TextStyle(fontFamily: 'Cairo')),
                ),
                const PopupMenuItem(
                  value: DocumentSort.title,
                  child: Text('الاسم', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ],
            ),
          ],
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? _ErrorView(message: state.error!)
                : state.documents.isEmpty
                    ? _EmptyDocuments()
                    : state.viewMode == ViewMode.list
                        ? _DocumentsList(
                            documents: state.documents,
                            onDelete: (id) => notifier.deleteDocument(id),
                            onFavorite: (id) => notifier.toggleFavorite(id),
                            onArchive: (id) => notifier.archiveDocument(id),
                          )
                        : _DocumentsGrid(documents: state.documents),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.editor),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _DocumentsList extends StatelessWidget {
  final List<Document> documents;
  final void Function(int) onDelete;
  final void Function(int) onFavorite;
  final void Function(int) onArchive;

  const _DocumentsList({
    required this.documents,
    required this.onDelete,
    required this.onFavorite,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: documents.length,
      itemBuilder: (ctx, i) {
        final doc = documents[i];
        return Slidable(
          key: ValueKey(doc.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => onFavorite(doc.id!),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                icon: doc.isFavorite ? Icons.star_off : Icons.star,
                label: doc.isFavorite ? 'إزالة' : 'مفضلة',
              ),
              SlidableAction(
                onPressed: (_) => onArchive(doc.id!),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                icon: Icons.archive,
                label: 'أرشيف',
              ),
              SlidableAction(
                onPressed: (_) => _confirmDelete(context, doc),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'حذف',
              ),
            ],
          ),
          child: DocumentCard(
            document: doc,
            onTap: () => context.push('/documents/${doc.id}'),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Document doc) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف المستند', style: TextStyle(fontFamily: 'Cairo')),
          content: Text('هل تريد نقل "${doc.title}" إلى سلة المحذوفات؟',
              style: const TextStyle(fontFamily: 'Cairo')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onDelete(doc.id!);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentsGrid extends StatelessWidget {
  final List<Document> documents;
  const _DocumentsGrid({required this.documents});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: documents.length,
      itemBuilder: (ctx, i) {
        final doc = documents[i];
        return DocumentCard(
          document: doc,
          isGrid: true,
          onTap: () => context.push('/documents/${doc.id}'),
        );
      },
    );
  }
}

class _EmptyDocuments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('لا توجد مستندات',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Text('اضغط + لإنشاء مستند جديد',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('حدث خطأ: $message'),
        ],
      ),
    );
  }
}
