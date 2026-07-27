import 'dart:convert';

class NoteModel {
  final int? id;
  final String title;
  final String content;
  final String? category;
  final int colorIndex;
  final String? templateType;
  final String? templateId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isFavorite;
  final bool isPasswordProtected;
  final String? password;
  final List<String> tags;
  final List<String> imagePaths;
  final String fontFamily;
  final double fontSize;
  final String textAlign;
  final Map<String, dynamic> customFields;
  final String? backgroundImage;
  final DateTime? reminderDate;
  final bool isArchived;
  final String? ownerId;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    this.category,
    this.colorIndex = 0,
    this.templateType,
    this.templateId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
    this.isFavorite = false,
    this.isPasswordProtected = false,
    this.password,
    List<String>? tags,
    List<String>? imagePaths,
    this.fontFamily = 'Tajawal',
    this.fontSize = 16.0,
    this.textAlign = 'right',
    Map<String, dynamic>? customFields,
    this.backgroundImage,
    this.reminderDate,
    this.isArchived = false,
    this.ownerId,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        tags = tags ?? [],
        imagePaths = imagePaths ?? [],
        customFields = customFields ?? {};

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'colorIndex': colorIndex,
      'templateType': templateType,
      'templateId': templateId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'isPasswordProtected': isPasswordProtected ? 1 : 0,
      'password': password,
      'tags': jsonEncode(tags),
      'imagePaths': jsonEncode(imagePaths),
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'textAlign': textAlign,
      'customFields': jsonEncode(customFields),
      'backgroundImage': backgroundImage,
      'reminderDate': reminderDate?.toIso8601String(),
      'isArchived': isArchived ? 1 : 0,
      'ownerId': ownerId,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'],
      colorIndex: map['colorIndex'] ?? 0,
      templateType: map['templateType'],
      templateId: map['templateId'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      isPinned: map['isPinned'] == 1,
      isFavorite: map['isFavorite'] == 1,
      isPasswordProtected: map['isPasswordProtected'] == 1,
      password: map['password'],
      tags: map['tags'] != null ? List<String>.from(jsonDecode(map['tags'])) : [],
      imagePaths: map['imagePaths'] != null ? List<String>.from(jsonDecode(map['imagePaths'])) : [],
      fontFamily: map['fontFamily'] ?? 'Tajawal',
      fontSize: (map['fontSize'] ?? 16.0).toDouble(),
      textAlign: map['textAlign'] ?? 'right',
      customFields: map['customFields'] != null ? Map<String, dynamic>.from(jsonDecode(map['customFields'])) : {},
      backgroundImage: map['backgroundImage'],
      reminderDate: map['reminderDate'] != null ? DateTime.parse(map['reminderDate']) : null,
      isArchived: map['isArchived'] == 1,
      ownerId: map['ownerId'],
    );
  }

  NoteModel copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    int? colorIndex,
    String? templateType,
    String? templateId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isFavorite,
    bool? isPasswordProtected,
    String? password,
    List<String>? tags,
    List<String>? imagePaths,
    String? fontFamily,
    double? fontSize,
    String? textAlign,
    Map<String, dynamic>? customFields,
    String? backgroundImage,
    DateTime? reminderDate,
    bool? isArchived,
    String? ownerId,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      colorIndex: colorIndex ?? this.colorIndex,
      templateType: templateType ?? this.templateType,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isPasswordProtected: isPasswordProtected ?? this.isPasswordProtected,
      password: password ?? this.password,
      tags: tags ?? this.tags,
      imagePaths: imagePaths ?? this.imagePaths,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textAlign: textAlign ?? this.textAlign,
      customFields: customFields ?? this.customFields,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      reminderDate: reminderDate ?? this.reminderDate,
      isArchived: isArchived ?? this.isArchived,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  // الحصول على معاينة نصية للمحتوى
  String get contentPreview {
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        final buffer = StringBuffer();
        for (final op in decoded) {
          if (op is Map && op['insert'] is String) {
            buffer.write(op['insert']);
          }
        }
        final text = buffer.toString().trim();
        return text.length > 100 ? '${text.substring(0, 100)}...' : text;
      }
    } catch (_) {}
    return content.length > 100 ? '${content.substring(0, 100)}...' : content;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'colorIndex': colorIndex,
      'templateType': templateType,
      'templateId': templateId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'isPasswordProtected': isPasswordProtected,
      'tags': tags,
      'imagePaths': imagePaths,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'textAlign': textAlign,
      'customFields': customFields,
      'backgroundImage': backgroundImage,
      'reminderDate': reminderDate?.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'],
      colorIndex: json['colorIndex'] ?? 0,
      templateType: json['templateType'],
      templateId: json['templateId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isPinned: json['isPinned'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      isPasswordProtected: false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      imagePaths: json['imagePaths'] != null ? List<String>.from(json['imagePaths']) : [],
      fontFamily: json['fontFamily'] ?? 'Tajawal',
      fontSize: (json['fontSize'] ?? 16.0).toDouble(),
      textAlign: json['textAlign'] ?? 'right',
      customFields: json['customFields'] != null ? Map<String, dynamic>.from(json['customFields']) : {},
      backgroundImage: json['backgroundImage'],
      reminderDate: json['reminderDate'] != null ? DateTime.parse(json['reminderDate']) : null,
      isArchived: json['isArchived'] ?? false,
    );
  }
}
