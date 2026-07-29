import '../../core/constants/db_constants.dart';
import '../../domain/entities/template.dart';

class TemplateModel extends Template {
  const TemplateModel({
    super.id,
    required super.name,
    super.description,
    required super.content,
    super.typeId,
    super.typeName,
    super.categoryId,
    super.isDefault,
    super.previewImage,
    super.color,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TemplateModel.fromMap(Map<String, dynamic> map) {
    return TemplateModel(
      id: map[DbConstants.colId] as int?,
      name: map[DbConstants.colName] as String,
      description: map[DbConstants.colDescription] as String?,
      content: map[DbConstants.colContent] as String? ?? '',
      typeId: map[DbConstants.colTypeId] as int?,
      typeName: map['type_name'] as String?,
      categoryId: map[DbConstants.colCategoryId] as int?,
      isDefault: (map[DbConstants.colIsDefault] as int? ?? 0) == 1,
      previewImage: map[DbConstants.colPreviewImage] as String?,
      color: map[DbConstants.colColor] as int?,
      createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
      updatedAt: DateTime.parse(map[DbConstants.colUpdatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.colId: id,
      DbConstants.colName: name,
      DbConstants.colDescription: description,
      DbConstants.colContent: content,
      DbConstants.colTypeId: typeId,
      DbConstants.colCategoryId: categoryId,
      DbConstants.colIsDefault: isDefault ? 1 : 0,
      DbConstants.colPreviewImage: previewImage,
      DbConstants.colColor: color,
      DbConstants.colCreatedAt: createdAt.toIso8601String(),
      DbConstants.colUpdatedAt: updatedAt.toIso8601String(),
    };
  }
}
