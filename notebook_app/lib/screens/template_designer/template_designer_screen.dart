import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_colors.dart';
import '../../models/template_model.dart';
import '../../providers/note_provider.dart';

class TemplateDesignerScreen extends StatefulWidget {
  final TemplateModel? template;

  const TemplateDesignerScreen({super.key, this.template});

  @override
  State<TemplateDesignerScreen> createState() => _TemplateDesignerScreenState();
}

class _TemplateDesignerScreenState extends State<TemplateDesignerScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _headerController;
  late TextEditingController _footerController;

  int _selectedColorIndex = 0;
  List<TemplateField> _fields = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _nameController = TextEditingController(text: t?.name ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _headerController = TextEditingController(text: t?.headerText ?? '');
    _footerController = TextEditingController(text: t?.footerText ?? '');
    _selectedColorIndex = t?.colorIndex ?? 0;
    _fields = t != null ? List.from(t.fields) : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.template == null ? 'قالب جديد' : 'تعديل القالب',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveTemplate,
            icon: const Icon(Icons.save_outlined, color: AppColors.primary),
            label: const Text('حفظ', style: TextStyle(fontFamily: 'Tajawal', color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // اسم القالب
          _buildSectionTitle('معلومات القالب'),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'اسم القالب *',
              prefixIcon: Icon(Icons.dashboard_customize_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            textDirection: TextDirection.rtl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'الوصف (اختياري)',
              prefixIcon: Icon(Icons.description_outlined),
            ),
          ),
          const SizedBox(height: 20),

          // لون القالب
          _buildSectionTitle('لون القالب'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(AppColors.categoryColors.length, (index) {
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.categoryColors[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColorIndex == index ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: _selectedColorIndex == index
                        ? [BoxShadow(color: AppColors.categoryColors[index].withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))]
                        : [],
                  ),
                  child: _selectedColorIndex == index
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // نص الرأس والتذييل
          _buildSectionTitle('رأس وتذييل القالب'),
          const SizedBox(height: 12),
          TextField(
            controller: _headerController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'نص الرأس (اختياري)',
              prefixIcon: Icon(Icons.vertical_align_top),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _footerController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'نص التذييل (اختياري)',
              prefixIcon: Icon(Icons.vertical_align_bottom),
            ),
          ),
          const SizedBox(height: 20),

          // الحقول
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('حقول القالب'),
              TextButton.icon(
                onPressed: _addField,
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: const Text('إضافة حقل', style: TextStyle(fontFamily: 'Tajawal', color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_fields.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.15), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.add_box_outlined, size: 40, color: AppColors.primary.withOpacity(0.4)),
                  const SizedBox(height: 8),
                  const Text('لا توجد حقول بعد\nاضغط "إضافة حقل" للبدء',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Tajawal', color: Colors.grey)),
                ],
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _fields.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _fields.removeAt(oldIndex);
                  _fields.insert(newIndex, item);
                  // إعادة ترتيب الأوامر
                  for (int i = 0; i < _fields.length; i++) {
                    _fields[i] = _fields[i].copyWith(order: i);
                  }
                });
              },
              itemBuilder: (context, index) {
                return _buildFieldCard(_fields[index], index, key: ValueKey(_fields[index].id));
              },
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildFieldCard(TemplateField field, int index, {required Key key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle, color: Colors.grey),
        ),
        title: Text(field.label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                field.typeLabel,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: AppColors.primary),
              ),
            ),
            if (field.isRequired) ...[
              const SizedBox(width: 6),
              const Text('مطلوب', style: TextStyle(fontSize: 11, color: Colors.red, fontFamily: 'Tajawal')),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
              onPressed: () => _editField(field, index),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () => setState(() => _fields.removeAt(index)),
            ),
          ],
        ),
      ),
    );
  }

  void _addField() {
    _showFieldEditor(null, null);
  }

  void _editField(TemplateField field, int index) {
    _showFieldEditor(field, index);
  }

  void _showFieldEditor(TemplateField? existingField, int? index) {
    final labelCtrl = TextEditingController(text: existingField?.label ?? '');
    FieldType selectedType = existingField?.type ?? FieldType.text;
    bool isRequired = existingField?.isRequired ?? false;
    final optionsCtrl = TextEditingController(
      text: existingField?.options?.join('\n') ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existingField == null ? 'إضافة حقل جديد' : 'تعديل الحقل',
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: labelCtrl,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(labelText: 'اسم الحقل *'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<FieldType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'نوع الحقل'),
                items: FieldType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      _getFieldTypeLabel(type),
                      style: const TextStyle(fontFamily: 'Tajawal'),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setModalState(() => selectedType = v!),
              ),
              if (selectedType == FieldType.dropdown) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: optionsCtrl,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'الخيارات (كل خيار في سطر)',
                    hintText: 'خيار 1\nخيار 2\nخيار 3',
                  ),
                ),
              ],
              const SizedBox(height: 12),
              CheckboxListTile(
                value: isRequired,
                onChanged: (v) => setModalState(() => isRequired = v!),
                title: const Text('حقل مطلوب', style: TextStyle(fontFamily: 'Tajawal')),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (labelCtrl.text.trim().isEmpty) return;

                    final newField = TemplateField(
                      id: existingField?.id ?? const Uuid().v4(),
                      label: labelCtrl.text.trim(),
                      type: selectedType,
                      isRequired: isRequired,
                      options: selectedType == FieldType.dropdown
                          ? optionsCtrl.text.split('\n').where((s) => s.trim().isNotEmpty).toList()
                          : null,
                      order: existingField?.order ?? _fields.length,
                    );

                    setState(() {
                      if (index != null) {
                        _fields[index] = newField;
                      } else {
                        _fields.add(newField);
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('حفظ الحقل', style: TextStyle(fontFamily: 'Tajawal')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFieldTypeLabel(FieldType type) {
    switch (type) {
      case FieldType.text: return 'نص قصير';
      case FieldType.number: return 'رقم';
      case FieldType.date: return 'تاريخ';
      case FieldType.dropdown: return 'قائمة منسدلة';
      case FieldType.checkbox: return 'خانة اختيار';
      case FieldType.multiline: return 'نص طويل';
    }
  }

  Future<void> _saveTemplate() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم للقالب'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final provider = Provider.of<NoteProvider>(context, listen: false);
      final template = TemplateModel(
        id: widget.template?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        colorIndex: _selectedColorIndex,
        fields: _fields,
        headerText: _headerController.text.trim().isEmpty ? null : _headerController.text.trim(),
        footerText: _footerController.text.trim().isEmpty ? null : _footerController.text.trim(),
        createdAt: widget.template?.createdAt,
      );

      if (widget.template == null) {
        await provider.addTemplate(template);
      } else {
        await provider.updateTemplate(template);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ القالب "${template.name}" بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الحفظ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
