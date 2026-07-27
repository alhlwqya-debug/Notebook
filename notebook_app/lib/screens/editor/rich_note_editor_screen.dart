import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../constants/app_colors.dart';
import '../../models/note_model.dart';
import '../../providers/note_provider.dart';
import '../export/export_screen.dart';

class RichNoteEditorScreen extends StatefulWidget {
  final NoteModel? note;

  const RichNoteEditorScreen({super.key, this.note});

  @override
  State<RichNoteEditorScreen> createState() => _RichNoteEditorScreenState();
}

class _RichNoteEditorScreenState extends State<RichNoteEditorScreen> {
  late QuillController _quillController;
  late TextEditingController _titleController;
  late FocusNode _editorFocusNode;

  String _selectedFontFamily = 'Tajawal';
  int _selectedColorIndex = 0;
  String? _selectedCategory;
  List<String> _tags = [];
  bool _isPinned = false;
  bool _isFavorite = false;
  bool _isPasswordProtected = false;
  String? _password;
  bool _hasChanges = false;

  final List<String> _availableFonts = ['Tajawal', 'Cairo', 'Amiri'];

  @override
  void initState() {
    super.initState();
    _editorFocusNode = FocusNode();
    _titleController = TextEditingController(text: widget.note?.title ?? '');

    // تهيئة المحرر
    if (widget.note != null && widget.note!.content.isNotEmpty) {
      try {
        final deltaJson = jsonDecode(widget.note!.content);
        _quillController = QuillController(
          document: Document.fromJson(deltaJson),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        _quillController = QuillController.basic();
      }
    } else {
      _quillController = QuillController.basic();
    }

    // تحميل بيانات الملاحظة الموجودة
    if (widget.note != null) {
      _selectedFontFamily = widget.note!.fontFamily;
      _selectedColorIndex = widget.note!.colorIndex;
      _selectedCategory = widget.note!.category;
      _tags = List.from(widget.note!.tags);
      _isPinned = widget.note!.isPinned;
      _isFavorite = widget.note!.isFavorite;
      _isPasswordProtected = widget.note!.isPasswordProtected;
      _password = widget.note!.password;
    }

    _quillController.addListener(() => _hasChanges = true);
    _titleController.addListener(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.noteColorsDark : AppColors.noteColors;
    final bgColor = _selectedColorIndex < colors.length ? colors[_selectedColorIndex] : colors[0];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // حقل العنوان
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _titleController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'العنوان...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.headlineMedium?.color,
              ),
            ),
          ),
          // شريط المعلومات
          _buildInfoBar(context),
          const Divider(height: 1),
          // شريط أدوات التنسيق
          _buildQuillToolbar(context),
          const Divider(height: 1),
          // محرر النصوص
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuillEditor.basic(
                controller: _quillController,
                focusNode: _editorFocusNode,
                configurations: QuillEditorConfigurations(
                  placeholder: 'ابدأ الكتابة...',
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  customStyles: DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      TextStyle(
                        fontFamily: _selectedFontFamily,
                        fontSize: 16,
                        height: 1.8,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      HorizontalSpacing.zero,
                      VerticalSpacing.zero,
                      VerticalSpacing.zero,
                      null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => _handleBack(context),
      ),
      actions: [
        // تثبيت
        IconButton(
          icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? AppColors.primary : null),
          onPressed: () => setState(() => _isPinned = !_isPinned),
          tooltip: 'تثبيت',
        ),
        // مفضلة
        IconButton(
          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_outline,
              color: _isFavorite ? AppColors.secondary : null),
          onPressed: () => setState(() => _isFavorite = !_isFavorite),
          tooltip: 'مفضلة',
        ),
        // قائمة الإجراءات
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleAction(context, value),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'export', child: _MenuItem(icon: Icons.file_upload_outlined, label: 'تصدير')),
            const PopupMenuItem(value: 'color', child: _MenuItem(icon: Icons.palette_outlined, label: 'لون الخلفية')),
            const PopupMenuItem(value: 'font', child: _MenuItem(icon: Icons.font_download_outlined, label: 'نوع الخط')),
            const PopupMenuItem(value: 'category', child: _MenuItem(icon: Icons.label_outlined, label: 'التصنيف')),
            const PopupMenuItem(value: 'tags', child: _MenuItem(icon: Icons.tag, label: 'الوسوم')),
            const PopupMenuItem(value: 'password', child: _MenuItem(icon: Icons.lock_outlined, label: 'حماية بكلمة مرور')),
          ],
        ),
        // زر الحفظ
        TextButton.icon(
          onPressed: () => _saveNote(context),
          icon: const Icon(Icons.save_outlined, color: AppColors.primary),
          label: const Text('حفظ', style: TextStyle(fontFamily: 'Tajawal', color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildInfoBar(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          if (_selectedCategory != null) ...[
            _InfoChip(
              label: _selectedCategory!,
              icon: Icons.label_outline,
              color: AppColors.primary,
              onTap: () => _showCategoryPicker(context),
            ),
            const SizedBox(width: 6),
          ],
          if (_isPasswordProtected)
            const _InfoChip(label: 'محمية', icon: Icons.lock, color: Colors.orange),
          ..._tags.take(3).map((tag) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _InfoChip(label: '#$tag', icon: Icons.tag, color: AppColors.primaryLight),
              )),
        ],
      ),
    );
  }

  Widget _buildQuillToolbar(BuildContext context) {
    return QuillSimpleToolbar(
      controller: _quillController,
      configurations: QuillSimpleToolbarConfigurations(
        toolbarSize: 44,
        multiRowsDisplay: false,
        showAlignmentButtons: true,
        showBoldButton: true,
        showItalicButton: true,
        showUnderLineButton: true,
        showStrikeThrough: true,
        showListBullets: true,
        showListNumbers: true,
        showQuote: true,
        showLink: false,
        showSearchButton: false,
        showSubscript: false,
        showSuperscript: false,
        showHeaderStyle: true,
        showFontFamily: false,
        showFontSize: true,
        showColorButton: true,
        showBackgroundColorButton: true,
        showClearFormat: true,
        showDirection: true,
        showIndent: true,
      ),
    );
  }

  Future<void> _saveNote(BuildContext context) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال عنوان للملاحظة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final provider = Provider.of<NoteProvider>(context, listen: false);
    final content = jsonEncode(_quillController.document.toDelta().toJson());

    final note = NoteModel(
      id: widget.note?.id,
      title: _titleController.text.trim(),
      content: content,
      category: _selectedCategory,
      colorIndex: _selectedColorIndex,
      fontFamily: _selectedFontFamily,
      isPinned: _isPinned,
      isFavorite: _isFavorite,
      isPasswordProtected: _isPasswordProtected,
      password: _password,
      tags: _tags,
      createdAt: widget.note?.createdAt,
    );

    if (widget.note?.id != null) {
      await provider.updateNote(note);
    } else {
      await provider.addNote(note);
    }

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleBack(BuildContext context) async {
    if (!_hasChanges || _titleController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حفظ التغييرات؟', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل تريد حفظ التغييرات قبل الخروج؟', style: TextStyle(fontFamily: 'Tajawal')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تجاهل', style: TextStyle(fontFamily: 'Tajawal')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حفظ', style: TextStyle(fontFamily: 'Tajawal')),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await _saveNote(context);
    } else if (result == false && context.mounted) {
      Navigator.pop(context);
    }
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'export':
        if (widget.note != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ExportScreen(note: widget.note!)));
        }
        break;
      case 'color':
        _showColorPicker(context);
        break;
      case 'font':
        _showFontPicker(context);
        break;
      case 'category':
        _showCategoryPicker(context);
        break;
      case 'tags':
        _showTagsEditor(context);
        break;
      case 'password':
        _showPasswordDialog(context);
        break;
    }
  }

  void _showColorPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.noteColorsDark : AppColors.noteColors;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('لون الخلفية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(colors.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColorIndex = index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors[index],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedColorIndex == index ? AppColors.primary : Colors.grey.shade300,
                        width: _selectedColorIndex == index ? 3 : 1,
                      ),
                    ),
                    child: _selectedColorIndex == index
                        ? const Icon(Icons.check, color: AppColors.primary, size: 20)
                        : null,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نوع الخط', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 16),
            ..._availableFonts.map((font) => ListTile(
                  onTap: () {
                    setState(() => _selectedFontFamily = font);
                    Navigator.pop(context);
                  },
                  leading: Radio<String>(
                    value: font,
                    groupValue: _selectedFontFamily,
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      setState(() => _selectedFontFamily = v!);
                      Navigator.pop(context);
                    },
                  ),
                  title: Text(
                    'هذا مثال على الخط $font',
                    style: TextStyle(fontFamily: font, fontSize: 16),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    final provider = Provider.of<NoteProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('التصنيف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.clear, color: Colors.red),
              title: const Text('بدون تصنيف', style: TextStyle(fontFamily: 'Tajawal')),
              onTap: () {
                setState(() => _selectedCategory = null);
                Navigator.pop(context);
              },
            ),
            ...provider.categories.map((cat) => ListTile(
                  leading: Icon(
                    Icons.label,
                    color: AppColors.categoryColors[
                        (cat['colorIndex'] as int? ?? 0) % AppColors.categoryColors.length],
                  ),
                  title: Text(cat['name'].toString(), style: const TextStyle(fontFamily: 'Tajawal')),
                  trailing: _selectedCategory == cat['name'] ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () {
                    setState(() => _selectedCategory = cat['name'].toString());
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showTagsEditor(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الوسوم', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) => Chip(
                  label: Text('#$tag', style: const TextStyle(fontFamily: 'Tajawal')),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() => _tags.remove(tag));
                    setModalState(() {});
                  },
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                )).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(hintText: 'أضف وسماً...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                    onPressed: () {
                      final tag = controller.text.trim();
                      if (tag.isNotEmpty && !_tags.contains(tag)) {
                        setState(() => _tags.add(tag));
                        setModalState(() {});
                        controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final controller = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          _isPasswordProtected ? 'إزالة الحماية' : 'إضافة كلمة مرور',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        content: _isPasswordProtected
            ? const Text('هل تريد إزالة الحماية بكلمة المرور؟', style: TextStyle(fontFamily: 'Tajawal'))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    obscureText: true,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(labelText: 'كلمة المرور'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                  ),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal')),
          ),
          ElevatedButton(
            onPressed: () {
              if (_isPasswordProtected) {
                setState(() {
                  _isPasswordProtected = false;
                  _password = null;
                });
              } else {
                if (controller.text.isEmpty) return;
                if (controller.text != confirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('كلمتا المرور غير متطابقتين')),
                  );
                  return;
                }
                setState(() {
                  _isPasswordProtected = true;
                  _password = controller.text;
                });
              }
              Navigator.pop(context);
            },
            child: Text(_isPasswordProtected ? 'إزالة' : 'تطبيق', style: const TextStyle(fontFamily: 'Tajawal')),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontFamily: 'Tajawal')),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _InfoChip({required this.label, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}
