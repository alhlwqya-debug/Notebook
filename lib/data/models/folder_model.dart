import '../../core/constants/db_constants.dart';
import '../../domain/entities/folder.dart';

class FolderModel extends Folder {
  const FolderModel({
    super.id,
    required super.name,
    super.parentId,
    super.color,
    super.icon,
    super.sortOrder,
    super.documentCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      id: map[DbConstants.colId] as int?,
      name: map[DbConstants.colName] as String,
      parentId: map[DbConstants.colParentId] as int?,
      color: map[DbConstants.colColor] as int? ?? 0xFFFF9800,
      icon: map[DbConstants.colIcon] as String? ?? 'folder',
      sortOrder: map[DbConstants.colSortOrder] as int? ?? 0,
      documentCount: map['document_count'] as int? ?? 0,
      createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
      updatedAt: DateTime.parse(map[DbConstants.colUpdatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.colId: id,
      DbConstants.colName: name,
      DbConstants.colParentId: parentId,
      DbConstants.colColor: color,
      DbConstants.colIcon: icon,
      DbConstants.colSortOrder: sortOrder,
      DbConstants.colCreatedAt: createdAt.toIso8601String(),
      DbConstants.colUpdatedAt: updatedAt.toIso8601String(),
    };
  }
}
