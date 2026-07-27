import 'dart:convert';

enum FieldType {
  text,
  number,
  date,
  dropdown,
  checkbox,
  multiline,
}

class TemplateField {
  final String id;
  final String label;
  final FieldType type;
  final bool isRequired;
  final String? defaultValue;
  final List<String>? options; // للقائمة المنسدلة
  final int order;

  TemplateField({
    required this.id,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.defaultValue,
    this.options,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'type': type.name,
      'isRequired': isRequired,
      'defaultValue': defaultValue,
      'options': options,
      'order': order,
    };
  }

  factory TemplateField.fromMap(Map<String, dynamic> map) {
    return TemplateField(
      id: map['id'],
      label: map['label'],
      type: FieldType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => FieldType.text,
      ),
      isRequired: map['isRequired'] ?? false,
      defaultValue: map['defaultValue'],
      options: map['options'] != null ? List<String>.from(map['options']) : null,
      order: map['order'] ?? 0,
    );
  }

  TemplateField copyWith({
    String? id,
    String? label,
    FieldType? type,
    bool? isRequired,
    String? defaultValue,
    List<String>? options,
    int? order,
  }) {
    return TemplateField(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      defaultValue: defaultValue ?? this.defaultValue,
      options: options ?? this.options,
      order: order ?? this.order,
    );
  }

  String get typeLabel {
    switch (type) {
      case FieldType.text:
        return 'نص';
      case FieldType.number:
        return 'رقم';
      case FieldType.date:
        return 'تاريخ';
      case FieldType.dropdown:
        return 'قائمة منسدلة';
      case FieldType.checkbox:
        return 'خانة اختيار';
      case FieldType.multiline:
        return 'نص متعدد الأسطر';
    }
  }
}

class TemplateModel {
  final String id;
  final String name;
  final String? description;
  final int colorIndex;
  final List<TemplateField> fields;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? backgroundImage;
  final String? headerText;
  final String? footerText;
  final bool isDefault;

  TemplateModel({
    required this.id,
    required this.name,
    this.description,
    this.colorIndex = 0,
    required this.fields,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.backgroundImage,
    this.headerText,
    this.footerText,
    this.isDefault = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'colorIndex': colorIndex,
      'fields': jsonEncode(fields.map((f) => f.toMap()).toList()),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'backgroundImage': backgroundImage,
      'headerText': headerText,
      'footerText': footerText,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory TemplateModel.fromMap(Map<String, dynamic> map) {
    final fieldsJson = jsonDecode(map['fields'] ?? '[]') as List;
    return TemplateModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      colorIndex: map['colorIndex'] ?? 0,
      fields: fieldsJson.map((f) => TemplateField.fromMap(f)).toList(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      backgroundImage: map['backgroundImage'],
      headerText: map['headerText'],
      footerText: map['footerText'],
      isDefault: map['isDefault'] == 1,
    );
  }

  TemplateModel copyWith({
    String? id,
    String? name,
    String? description,
    int? colorIndex,
    List<TemplateField>? fields,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? backgroundImage,
    String? headerText,
    String? footerText,
    bool? isDefault,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorIndex: colorIndex ?? this.colorIndex,
      fields: fields ?? this.fields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      headerText: headerText ?? this.headerText,
      footerText: footerText ?? this.footerText,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // القوالب الجاهزة المدمجة
  static List<TemplateModel> get builtinTemplates => [
        TemplateModel(
          id: 'builtin_student',
          name: 'دفتر الطالب',
          description: 'قالب مخصص للملاحظات الدراسية',
          colorIndex: 2,
          fields: [
            TemplateField(id: 'subject', label: 'المادة', type: FieldType.text, isRequired: true, order: 0),
            TemplateField(id: 'date', label: 'التاريخ', type: FieldType.date, isRequired: true, order: 1),
            TemplateField(id: 'grade', label: 'الدرجة', type: FieldType.number, order: 2),
            TemplateField(id: 'notes', label: 'ملاحظات إضافية', type: FieldType.multiline, order: 3),
          ],
          isDefault: true,
        ),
        TemplateModel(
          id: 'builtin_meeting',
          name: 'محضر اجتماع',
          description: 'قالب لتدوين محاضر الاجتماعات',
          colorIndex: 0,
          fields: [
            TemplateField(id: 'meeting_date', label: 'تاريخ الاجتماع', type: FieldType.date, isRequired: true, order: 0),
            TemplateField(id: 'attendees', label: 'المشاركون', type: FieldType.multiline, isRequired: true, order: 1),
            TemplateField(id: 'agenda', label: 'جدول الأعمال', type: FieldType.multiline, order: 2),
            TemplateField(id: 'decisions', label: 'القرارات المتخذة', type: FieldType.multiline, order: 3),
            TemplateField(id: 'actions', label: 'الإجراءات المطلوبة', type: FieldType.multiline, order: 4),
          ],
          isDefault: true,
        ),
        TemplateModel(
          id: 'builtin_task',
          name: 'قائمة المهام',
          description: 'قالب لإدارة المهام اليومية',
          colorIndex: 3,
          fields: [
            TemplateField(id: 'priority', label: 'الأولوية', type: FieldType.dropdown, options: ['عالية', 'متوسطة', 'منخفضة'], order: 0),
            TemplateField(id: 'due_date', label: 'تاريخ الاستحقاق', type: FieldType.date, order: 1),
            TemplateField(id: 'completed', label: 'مكتملة', type: FieldType.checkbox, order: 2),
          ],
          isDefault: true,
        ),
      ];
}
