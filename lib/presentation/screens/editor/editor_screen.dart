import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/document.dart';
import '../../providers/document_provider.dart';
import '../../providers/settings_provider.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final int? documentId;
  final int? templateId;
  final int? typeId;

  const EditorScreen({
    super.key,
    this.documentId,
    this.templateId,
    this.typeId,
  });

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  Document? _document;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _loadDocument();

    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  void _onChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    final settings = ref.read(settingsProvider);
    if (!settings.autoSave) return;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 5), _save);
  }

  Future<void> _loadDocument() async {
    if (widget.documentId != null) {
      final repo = ref.read(documentRepositoryProvider);
      final result = await repo.getDocumentById(widget.documentId!);
      result.fold(
        (_) {},
        (doc) {
          _document = doc;
          _titleController.text = doc.title;
          _contentController.text = doc.content;
        },
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final notifier = ref.read(documentsProvider.notifier);
    final title = _titleController.text.trim().isEmpty
        ? 'مستند بدون عنوان'
        : _titleController.text.trim();
    final content = _contentController.text;
    final wordCount = content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    if (_document != null) {
      final updated = _document!.copyWith(
        title: title,
        content: content,
        wordCount: wordCount,
        charCount: content.length,
        updatedAt: DateTime.now(),
      );
      await notifier.updateDocument(updated);
    } else {
      final now = DateTime.now();
      final newDoc = Document(
        title: title,
        content: content,
        typeId: widget.typeId,
        wordCount: wordCount,
        charCount: content.length,
        createdAt: now,
        updatedAt: now,
      );
      final created = await notifier.createDocument(newDoc);
      if (created != null) _document = created;
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
        _hasChanges = false;
      });
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.removeListener(_onChanged);
    _contentController.removeListener(_onChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_document == null ? 'مستند جديد' : 'تعديل'),
          leading: BackButton(onPressed: () async {
            if (_hasChanges) await _save();
            if (mounted) Navigator.pop(context);
          }),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            else
              IconButton(
                icon: Icon(
                  _hasChanges ? Icons.save : Icons.check_circle,
                  color: _hasChanges ? Colors.amber : Colors.white,
                ),
                onPressed: _save,
                tooltip: 'حفظ',
              ),
            PopupMenuButton<String>(
              onSelected: (v) => _handleAction(context, v),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'export', child: Text('تصدير', style: TextStyle(fontFamily: 'Cairo'))),
                PopupMenuItem(value: 'info', child: Text('معلومات', style: TextStyle(fontFamily: 'Cairo'))),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Title
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: TextField(
                      controller: _titleController,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.headlineSmall,
                      decoration: const InputDecoration(
                        hintText: 'عنوان المستند...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      maxLines: 1,
                    ),
                  ),

                  const Divider(height: 1),

                  // Toolbar
                  _EditorToolbar(contentController: _contentController),

                  const Divider(height: 1),

                  // Content area
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      textDirection: TextDirection.rtl,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: settings.fontSize,
                            height: 1.8,
                          ),
                      decoration: const InputDecoration(
                        hintText: 'ابدأ الكتابة هنا...',
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),

                  // Status bar
                  _StatusBar(
                    wordCount: _contentController.text
                        .split(RegExp(r'\s+'))
                        .where((w) => w.isNotEmpty)
                        .length,
                    charCount: _contentController.text.length,
                    autoSave: settings.autoSave,
                    isSaving: _isSaving,
                  ),
                ],
              ),
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'export':
        _showExportSheet(context);
        break;
      case 'info':
        _showDocumentInfo(context);
        break;
    }
  }

  void _showExportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تصدير المستند', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['PDF', 'TXT', 'HTML', 'Markdown'].map((fmt) {
                  return ActionChip(
                    label: Text(fmt, style: const TextStyle(fontFamily: 'Cairo')),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تصدير إلى $fmt...')),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocumentInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('معلومات المستند', style: TextStyle(fontFamily: 'Cairo')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الكلمات: ${_contentController.text.split(RegExp(r"\s+")).where((w) => w.isNotEmpty).length}'),
              Text('الأحرف: ${_contentController.text.length}'),
              if (_document?.createdAt != null)
                Text('تاريخ الإنشاء: ${_document!.createdAt}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorToolbar extends StatelessWidget {
  final TextEditingController contentController;
  const _EditorToolbar({required this.contentController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ToolBtn(icon: Icons.format_bold, tooltip: 'عريض', onTap: () => _wrap('**', '**')),
          _ToolBtn(icon: Icons.format_italic, tooltip: 'مائل', onTap: () => _wrap('_', '_')),
          _ToolBtn(icon: Icons.format_underlined, tooltip: 'تسطير', onTap: () => _wrap('__', '__')),
          _ToolBtn(icon: Icons.strikethrough_s, tooltip: 'شطب', onTap: () => _wrap('~~', '~~')),
          const VerticalDivider(width: 16),
          _ToolBtn(icon: Icons.format_list_bulleted, tooltip: 'قائمة', onTap: () => _insert('\n- ')),
          _ToolBtn(icon: Icons.format_list_numbered, tooltip: 'قائمة رقمية', onTap: () => _insert('\n1. ')),
          _ToolBtn(icon: Icons.check_box_outline_blank, tooltip: 'مربع اختيار', onTap: () => _insert('\n- [ ] ')),
          const VerticalDivider(width: 16),
          _ToolBtn(icon: Icons.code, tooltip: 'كود', onTap: () => _wrap('`', '`')),
          _ToolBtn(icon: Icons.format_quote, tooltip: 'اقتباس', onTap: () => _insert('\n> ')),
          _ToolBtn(icon: Icons.horizontal_rule, tooltip: 'فاصل', onTap: () => _insert('\n---\n')),
        ],
      ),
    );
  }

  void _wrap(String before, String after) {
    final text = contentController.text;
    final selection = contentController.selection;
    if (!selection.isValid) return;
    final selectedText = selection.textInside(text);
    final newText = text.replaceRange(
      selection.start, selection.end, '$before$selectedText$after',
    );
    contentController.value = contentController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + before.length + selectedText.length + after.length,
      ),
    );
  }

  void _insert(String text) {
    final current = contentController.text;
    final selection = contentController.selection;
    final offset = selection.isValid ? selection.baseOffset : current.length;
    final newText = current.substring(0, offset) + text + current.substring(offset);
    contentController.value = contentController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: offset + text.length),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _ToolBtn({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final int wordCount, charCount;
  final bool autoSave, isSaving;
  const _StatusBar({
    required this.wordCount,
    required this.charCount,
    required this.autoSave,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$wordCount كلمة • $charCount حرف',
              style: Theme.of(context).textTheme.labelSmall),
          if (autoSave)
            Row(
              children: [
                if (isSaving) const SizedBox(
                  width: 12, height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ) else const Icon(Icons.cloud_done_outlined, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(isSaving ? 'يحفظ...' : 'محفوظ',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
        ],
      ),
    );
  }
}
