import 'package:equatable/equatable.dart';

class Folder extends Equatable {
  final int? id;
  final String name;
  final int? parentId;
  final int color;
  final String icon;
  final int sortOrder;
  final int documentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Folder({
    this.id,
    required this.name,
    this.parentId,
    this.color = 0xFFFF9800,
    this.icon = 'folder',
    this.sortOrder = 0,
    this.documentCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Folder copyWith({
    int? id,
    String? name,
    int? parentId,
    int? color,
    String? icon,
    int? sortOrder,
    int? documentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      documentCount: documentCount ?? this.documentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, parentId, color, icon, sortOrder, createdAt, updatedAt];
}
