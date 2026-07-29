import 'package:equatable/equatable.dart';

class DocumentType extends Equatable {
  final int? id;
  final String name;
  final String icon;
  final int color;
  final DateTime createdAt;

  const DocumentType({
    this.id,
    required this.name,
    required this.icon,
    this.color = 0xFF2196F3,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, icon, color];
}
