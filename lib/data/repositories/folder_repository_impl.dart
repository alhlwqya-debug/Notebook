import 'package:dartz/dartz.dart';

import '../../core/constants/db_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';
import '../datasources/local_database.dart';
import '../models/folder_model.dart';

class FolderRepositoryImpl implements FolderRepository {
  final LocalDatabase _db = LocalDatabase.instance;

  @override
  Future<Either<Failure, List<Folder>>> getAllFolders({int? parentId}) async {
    try {
      final db = await _db.database;
      final query = '''
        SELECT f.*,
               COUNT(d.${DbConstants.colId}) AS document_count
        FROM ${DbConstants.foldersTable} f
        LEFT JOIN ${DbConstants.documentsTable} d ON f.${DbConstants.colId} = d.${DbConstants.colFolderId}
          AND d.${DbConstants.colIsDeleted} = 0
        ${parentId == null ? 'WHERE f.${DbConstants.colParentId} IS NULL' : 'WHERE f.${DbConstants.colParentId} = $parentId'}
        GROUP BY f.${DbConstants.colId}
        ORDER BY f.${DbConstants.colName} ASC
      ''';
      final maps = await db.rawQuery(query);
      return Right(maps.map((m) => FolderModel.fromMap(m)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Folder>> getFolderById(int id) async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        DbConstants.foldersTable,
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return const Left(NotFoundFailure('المجلد غير موجود'));
      return Right(FolderModel.fromMap(maps.first));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Folder>> createFolder(Folder folder) async {
    try {
      final db = await _db.database;
      final model = FolderModel(
        name: folder.name,
        parentId: folder.parentId,
        color: folder.color,
        icon: folder.icon,
        sortOrder: folder.sortOrder,
        createdAt: folder.createdAt,
        updatedAt: folder.updatedAt,
      );
      final id = await db.insert(DbConstants.foldersTable, model.toMap());
      return getFolderById(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Folder>> updateFolder(Folder folder) async {
    try {
      final db = await _db.database;
      final model = FolderModel(
        id: folder.id,
        name: folder.name,
        parentId: folder.parentId,
        color: folder.color,
        icon: folder.icon,
        sortOrder: folder.sortOrder,
        createdAt: folder.createdAt,
        updatedAt: DateTime.now(),
      );
      await db.update(
        DbConstants.foldersTable,
        model.toMap(),
        where: '${DbConstants.colId} = ?',
        whereArgs: [folder.id],
      );
      return getFolderById(folder.id!);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFolder(int id) async {
    try {
      final db = await _db.database;
      // Move documents to root first
      await db.update(
        DbConstants.documentsTable,
        {DbConstants.colFolderId: null},
        where: '${DbConstants.colFolderId} = ?',
        whereArgs: [id],
      );
      await db.delete(
        DbConstants.foldersTable,
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> moveFolder(int folderId, int? parentId) async {
    try {
      final db = await _db.database;
      await db.update(
        DbConstants.foldersTable,
        {
          DbConstants.colParentId: parentId,
          DbConstants.colUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${DbConstants.colId} = ?',
        whereArgs: [folderId],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
