import '../../core/constants/db_constants.dart';
import '../../domain/entities/document.dart';

class DocumentModel extends Document {
  const DocumentModel({
    super.id,
    required super.title,
    required super.content,
    super.typeId,
    super.typeName,
    super.folderId,
    super.folderName,
    super.categoryId,
    super.categoryName,
    super.isFavorite,
    super.isArchived,
    super.isDeleted,
    super.color,
    super.icon,
    super.sortOrder,
    super.wordCount,
    super.charCount,
    super.lastOpenedAt,
    super.deletedAt,
    required super.createdAt,
    required super.updatedAt,
    super.tags,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map[DbConstants.colId] as int?,
      title: map[DbConstants.colTitle] as String? ?? 'مستند جديد',
      content: map[DbConstants.colContent] as String? ?? '',
      typeId: map[DbConstants.colTypeId] as int?,
      typeName: map['type_name'] as String?,
      folderId: map[DbConstants.colFolderId] as int?,
      folderName: map['folder_name'] as String?,
      categoryId: map[DbConstants.colCategoryId] as int?,
      categoryName: map['category_name'] as String?,
      isFavorite: (map[DbConstants.colIsFavorite] as int? ?? 0) == 1,
      isArchived: (map[DbConstants.colIsArchived] as int? ?? 0) == 1,
      isDeleted: (map[DbConstants.colIsDeleted] as int? ?? 0) == 1,
      color: map[DbConstants.colColor] as int?,
      icon: map[DbConstants.colIcon] as String?,
      sortOrder: map[DbConstants.colSortOrder] as int? ?? 0,
      wordCount: map[DbConstants.colWordCount] as int? ?? 0,
      charCount: map[DbConstants.colCharCount] as int? ?? 0,
      lastOpenedAt: map[DbConstants.colLastOpenedAt] != null
          ? DateTime.parse(map[DbConstants.colLastOpenedAt] as String)
          : null,
      deletedAt: map[DbConstants.colDeletedAt] != null
          ? DateTime.parse(map[DbConstants.colDeletedAt] as String)
          : null,
      createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
      updatedAt: DateTime.parse(map[DbConstants.colUpdatedAt] as String),
      tags: map['tags'] != null
          ? (map['tags'] as String).split(',').where((t) => t.isNotEmpty).toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.colId: id,
      DbConstants.colTitle: title,
      DbConstants.colContent: content,
      DbConstants.colTypeId: typeId,
      DbConstants.colFolderId: folderId,
      DbConstants.colCategoryId: categoryId,
      DbConstants.colIsFavorite: isFavorite ? 1 : 0,
      DbConstants.colIsArchived: isArchived ? 1 : 0,
      DbConstants.colIsDeleted: isDeleted ? 1 : 0,
      DbConstants.colColor: color,
      DbConstants.colIcon: icon,
      DbConstants.colSortOrder: sortOrder,
      DbConstants.colWordCount: wordCount,
      DbConstants.colCharCount: charCount,
      DbConstants.colLastOpenedAt: lastOpenedAt?.toIso8601String(),
      DbConstants.colDeletedAt: deletedAt?.toIso8601String(),
      DbConstants.colCreatedAt: createdAt.toIso8601String(),
      DbConstants.colUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory DocumentModel.fromEntity(Document doc) {
    return DocumentModel(
      id: doc.id,
      title: doc.title,
      content: doc.content,
      typeId: doc.typeId,
      typeName: doc.typeName,
      folderId: doc.folderId,
      folderName: doc.folderName,
      categoryId: doc.categoryId,
      categoryName: doc.categoryName,
      isFavorite: doc.isFavorite,
      isArchived: doc.isArchived,
      isDeleted: doc.isDeleted,
      color: doc.color,
      icon: doc.icon,
      sortOrder: doc.sortOrder,
      wordCount: doc.wordCount,
      charCount: doc.charCount,
      lastOpenedAt: doc.lastOpenedAt,
      deletedAt: doc.deletedAt,
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
      tags: doc.tags,
    );
  }
}
