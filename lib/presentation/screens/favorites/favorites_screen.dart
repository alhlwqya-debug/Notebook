import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/document_provider.dart';
import '../../widgets/document_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoritesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المفضلة')),
        body: favAsync.when(
          data: (docs) => docs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_border, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('لا توجد مستندات مفضلة',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('اضغط على ⭐ لإضافة مستند للمفضلة',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) => DocumentCard(
                    document: docs[i],
                    onTap: () => context.push('/documents/${docs[i].id}'),
                  ),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }
}
