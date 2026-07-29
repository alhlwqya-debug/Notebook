import 'package:flutter/material.dart';

import '../../domain/entities/folder.dart';

class FolderCard extends StatelessWidget {
  final Folder folder;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FolderCard({
    super.key,
    required this.folder,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(folder.color);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder, color: color, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    folder.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${folder.documentCount} مستند',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[500]),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') _confirmDelete(context);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('تعديل', style: TextStyle(fontFamily: 'Cairo')),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف المجلد', style: TextStyle(fontFamily: 'Cairo')),
          content: Text('هل تريد حذف "${folder.name}"? سيتم نقل المستندات إلى الجذر.', style: const TextStyle(fontFamily: 'Cairo')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () { Navigator.pop(ctx); onDelete(); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
