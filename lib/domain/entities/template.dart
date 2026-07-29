import 'package:equatable/equatable.dart';

class Template extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final String content;
  final int? typeId;
  final String? typeName;
  final int? categoryId;
  final bool isDefault;
  final String? previewImage;
  final int? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Template({
    this.id,
    required this.name,
    this.description,
    required this.content,
    this.typeId,
    this.typeName,
    this.categoryId,
    this.isDefault = false,
    this.previewImage,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  Template copyWith({
    int? id,
    String? name,
    String? description,
    String? content,
    int? typeId,
    String? typeName,
    int? categoryId,
    bool? isDefault,
    String? previewImage,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Template(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      content: content ?? this.content,
      typeId: typeId ?? this.typeId,
      typeName: typeName ?? this.typeName,
      categoryId: categoryId ?? this.categoryId,
      isDefault: isDefault ?? this.isDefault,
      previewImage: previewImage ?? this.previewImage,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, content, typeId, isDefault, createdAt, updatedAt];
}
