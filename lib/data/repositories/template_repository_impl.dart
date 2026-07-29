import 'package:dartz/dartz.dart';

import '../../core/constants/db_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/template.dart';
import '../../domain/repositories/template_repository.dart';
import '../datasources/local_database.dart';
import '../models/template_model.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final LocalDatabase _db = LocalDatabase.instance;

  static const String _query = '''
    SELECT t.*,
           dt.${DbConstants.colName} AS type_name
    FROM ${DbConstants.templatesTable} t
    LEFT JOIN ${DbConstants.documentTypesTable} dt ON t.${DbConstants.colTypeId} = dt.${DbConstants.colId}
  ''';

  @override
  Future<Either<Failure, List<Template>>> getAllTemplates({int? typeId, int? categoryId}) async {
    try {
      final db = await _db.database;
      final conditions = <String>[];
      final args = <dynamic>[];
      if (typeId != null) { conditions.add('t.${DbConstants.colTypeId} = ?'); args.add(typeId); }
      if (categoryId != null) { conditions.add('t.${DbConstants.colCategoryId} = ?'); args.add(categoryId); }
      final where = conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';
      final maps = await db.rawQuery('$_query $where ORDER BY t.${DbConstants.colIsDefault} DESC, t.${DbConstants.colName} ASC', args);
      return Right(maps.map((m) => TemplateModel.fromMap(m)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Template>> getTemplateById(int id) async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery('$_query WHERE t.${DbConstants.colId} = ?', [id]);
      if (maps.isEmpty) return const Left(NotFoundFailure('القالب غير موجود'));
      return Right(TemplateModel.fromMap(maps.first));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Template>> createTemplate(Template template) async {
    try {
      final db = await _db.database;
      final model = TemplateModel(
        name: template.name,
        description: template.description,
        content: template.content,
        typeId: template.typeId,
        categoryId: template.categoryId,
        isDefault: template.isDefault,
        previewImage: template.previewImage,
        color: template.color,
        createdAt: template.createdAt,
        updatedAt: template.updatedAt,
      );
      final id = await db.insert(DbConstants.templatesTable, model.toMap());
      return getTemplateById(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Template>> updateTemplate(Template template) async {
    try {
      final db = await _db.database;
      final model = TemplateModel(
        id: template.id,
        name: template.name,
        description: template.description,
        content: template.content,
        typeId: template.typeId,
        categoryId: template.categoryId,
        isDefault: template.isDefault,
        previewImage: template.previewImage,
        color: template.color,
        createdAt: template.createdAt,
        updatedAt: DateTime.now(),
      );
      await db.update(DbConstants.templatesTable, model.toMap(), where: '${DbConstants.colId} = ?', whereArgs: [template.id]);
      return getTemplateById(template.id!);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTemplate(int id) async {
    try {
      final db = await _db.database;
      await db.delete(DbConstants.templatesTable, where: '${DbConstants.colId} = ?', whereArgs: [id]);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Template>> duplicateTemplate(int id) async {
    try {
      final result = await getTemplateById(id);
      return result.fold(
        (f) => Left(f),
        (t) => createTemplate(t.copyWith(
          id: null,
          name: '${t.name} (نسخة)',
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )),
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
