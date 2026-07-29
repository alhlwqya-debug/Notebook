import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/folder.dart';
import '../../providers/document_provider.dart';
import '../../providers/folder_provider.dart';
import '../../widgets/folder_card.dart';

class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(foldersProvider);
    final notifier = ref.read(foldersProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المجلدات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.create_new_folder),
              onPressed: () => _showCreateFolderDialog(context, notifier),
            ),
          ],
        ),
        body: foldersAsync.when(
          data: (folders) => folders.isEmpty
              ? _EmptyFolders(onCreateTap: () => _showCreateFolderDialog(context, notifier))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: folders.length,
                  itemBuilder: (ctx, i) => FolderCard(
                    folder: folders[i],
                    onTap: () => _openFolder(context, ref, folders[i]),
                    onEdit: () => _showEditFolderDialog(context, notifier, folders[i]),
                    onDelete: () => notifier.deleteFolder(folders[i].id!),
                  ),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateFolderDialog(context, notifier),
          child: const Icon(Icons.create_new_folder),
        ),
      ),
    );
  }

  void _openFolder(BuildContext context, WidgetRef ref, Folder folder) {
    ref.read(documentsProvider.notifier).setFolderFilter(folder.id);
    context.go('/documents');
  }

  void _showCreateFolderDialog(BuildContext context, FoldersNotifier notifier) {
    final nameController = TextEditingController();
    int selectedColor = 0xFFFF9800;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('مجلد جديد', style: TextStyle(fontFamily: 'Cairo')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'اسم المجلد',
                  prefixIcon: Icon(Icons.folder),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              _ColorPicker(
                selected: selectedColor,
                onSelect: (c) => selectedColor = c,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  notifier.createFolder(
                    name: nameController.text.trim(),
                    color: selectedColor,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('إنشاء'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFolderDialog(BuildContext context, FoldersNotifier notifier, Folder folder) {
    final nameController = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعديل المجلد', style: TextStyle(fontFamily: 'Cairo')),
          content: TextField(
            controller: nameController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(labelText: 'اسم المجلد'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  notifier.updateFolder(folder.copyWith(name: nameController.text.trim()));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFolders extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyFolders({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('لا توجد مجلدات', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.create_new_folder),
            label: const Text('إنشاء مجلد'),
          ),
        ],
      ),
    );
  }
}

class _ColorPicker extends StatefulWidget {
  final int selected;
  final void Function(int) onSelect;
  const _ColorPicker({required this.selected, required this.onSelect});

  @override
  State<_ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<_ColorPicker> {
  late int _selected;
  final colors = [0xFFFF9800, 0xFF2196F3, 0xFF4CAF50, 0xFFF44336, 0xFF9C27B0, 0xFF00BCD4, 0xFF795548];

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors.map((c) {
        return GestureDetector(
          onTap: () { setState(() => _selected = c); widget.onSelect(c); },
          child: Container(
            margin: const EdgeInsets.all(4),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Color(c),
              shape: BoxShape.circle,
              border: _selected == c ? Border.all(color: Colors.black, width: 2) : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
