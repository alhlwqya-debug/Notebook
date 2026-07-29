import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  final String name;
  final int color;
  final DateTime createdAt;

  const Category({
    this.id,
    required this.name,
    this.color = 0xFF9E9E9E,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, color];
}
