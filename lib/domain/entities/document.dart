import 'package:equatable/equatable.dart';

class Document extends Equatable {
  final int? id;
  final String title;
  final String content;
  final int? typeId;
  final String? typeName;
  final int? folderId;
  final String? folderName;
  final int? categoryId;
  final String? categoryName;
  final bool isFavorite;
  final bool isArchived;
  final bool isDeleted;
  final int? color;
  final String? icon;
  final int sortOrder;
  final int wordCount;
  final int charCount;
  final DateTime? lastOpenedAt;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  const Document({
    this.id,
    required this.title,
    required this.content,
    this.typeId,
    this.typeName,
    this.folderId,
    this.folderName,
    this.categoryId,
    this.categoryName,
    this.isFavorite = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.color,
    this.icon,
    this.sortOrder = 0,
    this.wordCount = 0,
    this.charCount = 0,
    this.lastOpenedAt,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  Document copyWith({
    int? id,
    String? title,
    String? content,
    int? typeId,
    String? typeName,
    int? folderId,
    String? folderName,
    int? categoryId,
    String? categoryName,
    bool? isFavorite,
    bool? isArchived,
    bool? isDeleted,
    int? color,
    String? icon,
    int? sortOrder,
    int? wordCount,
    int? charCount,
    DateTime? lastOpenedAt,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      typeId: typeId ?? this.typeId,
      typeName: typeName ?? this.typeName,
      folderId: folderId ?? this.folderId,
      folderName: folderName ?? this.folderName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      wordCount: wordCount ?? this.wordCount,
      charCount: charCount ?? this.charCount,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id, title, content, typeId, folderId, categoryId,
        isFavorite, isArchived, isDeleted, color, icon,
        sortOrder, wordCount, charCount, createdAt, updatedAt,
      ];
}
