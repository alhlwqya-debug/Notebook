import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/db_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/local_database.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final LocalDatabase _db = LocalDatabase.instance;

  static const String _documentsQuery = '''
    SELECT d.*,
           dt.${DbConstants.colName} AS type_name,
           f.${DbConstants.colName} AS folder_name,
           c.${DbConstants.colName} AS category_name,
           GROUP_CONCAT(t.${DbConstants.colName}) AS tags
    FROM ${DbConstants.documentsTable} d
    LEFT JOIN ${DbConstants.documentTypesTable} dt ON d.${DbConstants.colTypeId} = dt.${DbConstants.colId}
    LEFT JOIN ${DbConstants.foldersTable} f ON d.${DbConstants.colFolderId} = f.${DbConstants.colId}
    LEFT JOIN ${DbConstants.categoriesTable} c ON d.${DbConstants.colCategoryId} = c.${DbConstants.colId}
    LEFT JOIN ${DbConstants.documentTagsTable} dtg ON d.${DbConstants.colId} = dtg.${DbConstants.colDocumentId}
    LEFT JOIN ${DbConstants.tagsTable} t ON dtg.tag_id = t.${DbConstants.colId}
  ''';

  @override
  Future<Either<Failure, List<Document>>> getAllDocuments({
    bool includeArchived = false,
    bool includeDeleted = false,
    int? folderId,
    int? categoryId,
    int? typeId,
    String? sortBy,
    bool ascending = false,
  }) async {
    try {
      final db = await _db.database;
      final conditions = <String>[];
      final args = <dynamic>[];

      if (!includeDeleted) {
        conditions.add('d.${DbConstants.colIsDeleted} = 0');
      }
      if (!includeArchived) {
        conditions.add('d.${DbConstants.colIsArchived} = 0');
      }
      if (folderId != null) {
        conditions.add('d.${DbConstants.colFolderId} = ?');
        args.add(folderId);
      }
      if (categoryId != null) {
        conditions.add('d.${DbConstants.colCategoryId} = ?');
        args.add(categoryId);
      }
      if (typeId != null) {
        conditions.add('d.${DbConstants.colTypeId} = ?');
        args.add(typeId);
      }

      final where = conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';
      final sort = sortBy ?? DbConstants.colUpdatedAt;
      final order = ascending ? 'ASC' : 'DESC';

      final query = '$_documentsQuery $where GROUP BY d.${DbConstants.colId} ORDER BY d.$sort $order';
      final maps = await db.rawQuery(query, args);

      return Right(maps.map((m) => DocumentModel.fromMap(m)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Document>> getDocumentById(int id) async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        '$_documentsQuery WHERE d.${DbConstants.colId} = ? GROUP BY d.${DbConstants.colId}',
        [id],
      );
      if (maps.isEmpty) {
        return const Left(NotFoundFailure('المستند غير موجود'));
      }
      return Right(DocumentModel.fromMap(maps.first));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> searchDocuments({
    required String query,
    int? typeId,
    int? categoryId,
    DateTime? fromDate,
    DateTime? toDate,
    List<String>? tags,
  }) async {
    try {
      final db = await _db.database;
      final conditions = <String>[
        "d.${DbConstants.colIsDeleted} = 0",
        "(d.${DbConstants.colTitle} LIKE ? OR d.${DbConstants.colContent} LIKE ?)",
      ];
      final args = <dynamic>['%$query%', '%$query%'];

      if (typeId != null) {
        conditions.add('d.${DbConstants.colTypeId} = ?');
        args.add(typeId);
      }
      if (categoryId != null) {
        conditions.add('d.${DbConstants.colCategoryId} = ?');
        args.add(categoryId);
      }
      if (fromDate != null) {
        conditions.add('d.${DbConstants.colCreatedAt} >= ?');
        args.add(fromDate.toIso8601String());
      }
      if (toDate != null) {
        conditions.add('d.${DbConstants.colCreatedAt} <= ?');
        args.add(toDate.toIso8601String());
      }

      final where = 'WHERE ${conditions.join(' AND ')}';
      final rawQuery = '$_documentsQuery $where GROUP BY d.${DbConstants.colId} ORDER BY d.${DbConstants.colUpdatedAt} DESC';
      final maps = await db.rawQuery(rawQuery, args);

      return Right(maps.map((m) => DocumentModel.fromMap(m)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> getFavoriteDocuments() async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        '$_documentsQuery WHERE d.${DbConstants.colIsFavorite} = 1 AND d.${DbConstants.colIsDeleted} = 0 GROUP BY d.${DbConstants.colId} ORDER BY d.${DbConstants.colUpdatedAt} DESC',
      );
      return Right(maps.map((m) => DocumentModel.fromMap(m)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> getArchivedDocuments() async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        '$_documentsQuery WHERE d.${DbConstants.colIsArchived} = 1 AND d.${DbConstants.colIsDeleted} = 0 GROUP BY d.${DbConstants.colId} ORDER BY d.${DbConstants.colUpdatedAt} DESC',
      );
      return Right(maps.map((m) => DocumentModel.fromMap(m)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> getDeletedDocuments() async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        '$_documentsQuery WHERE d.${DbConstants.colIsDeleted} = 1 GROUP BY d.${DbConstants.colId} ORDER BY d.${DbConstants.colDeletedAt} DESC',
      );
      return Right(maps.map((m) => DocumentModel.fromMap(m)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> getRecentDocuments({int limit = 10}) async {
    try {
      final db = await _db.database;
      final maps = await db.rawQuery(
        '$_documentsQuery WHERE d.${DbConstants.colIsDeleted} = 0 AND d.${DbConstants.colIsArchived} = 0 AND d.${DbConstants.colLastOpenedAt} IS NOT NULL GROUP BY d.${DbConstants.colId} ORDER BY d.${DbConstants.colLastOpenedAt} DESC LIMIT $limit',
      );
      return Right(maps.map((m) => DocumentModel.fromMap(m)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Document>> createDocument(Document document) async {
    try {
      final db = await _db.database;
      final model = DocumentModel.fromEntity(document);
      final id = await db.insert(DbConstants.documentsTable, model.toMap());
      return getDocumentById(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Document>> updateDocument(Document document) async {
    try {
      final db = await _db.database;
      final model = DocumentModel.fromEntity(document.copyWith(updatedAt: DateTime.now()));
      await db.update(
        DbConstants.documentsTable,
        model.toMap(),
        where: '${DbConstants.colId} = ?',
        whereArgs: [document.id],
      );
      return getDocumentById(document.id!);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(int id) async {
    try {
      final db = await _db.database;
      await db.update(
        DbConstants.documentsTable,
        {
          DbConstants.colIsDeleted: 1,
          DbConstants.colDeletedAt: DateTime.now().toIso8601String(),
          DbConstants.colUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteDocument(int id) async {
    try {
      final db = await _db.database;
      await db.delete(
        DbConstants.documentsTable,
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restoreDocument(int id) async {
    try {
      final db = await _db.database;
      await db.update(
        DbConstants.documentsTable,
        {
          DbConstants.colIsDeleted: 0,
          DbConstants.colDeletedAt: null,
          DbConstants.colUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(int id) async {
    try {
      final db = await _db.database;
      final result = await db.query(
        DbConstants.documentsTable,
        columns: [DbConstants.colIsFavorite],
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return const Left(NotFoundFailure('المستند غير موجود'));
      final current = result.first[DbConstants.colIsFavorite] as int;
      await db.update(
        DbConstants.documentsTable,
        {
          DbConstants.colIsFavorite: current == 1 ? 0 : 1,
          DbConstants.colUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> archiveDocument(int id) async {
    try {
      final db = await _db.database;
      await db.update(
        DbConstants.documentsTable,
        {DbConstants.colIsArchived: 1, DbConstants.colUpdatedAt: DateTime.now().toIso8601String()},
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unarchiveDocument(int id) async {
    try {
      final db = await _db.database;
      await db.update(
        DbConstants.documentsTable,
        {DbConstants.colIsArchived: 0, DbConstants.colUpdatedAt: DateTime.now().toIso8601String()},
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> moveDocument(int documentId, int? folderId) async {
    try {
      final db = await _db.database;
      await db.update(
        DbConstants.documentsTable,
        {DbConstants.colFolderId: folderId, DbConstants.colUpdatedAt: DateTime.now().toIso8601String()},
        where: '${DbConstants.colId} = ?',
        whereArgs: [documentId],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Document>> duplicateDocument(int id) async {
    try {
      final result = await getDocumentById(id);
      return result.fold(
        (failure) => Left(failure),
        (doc) => createDocument(doc.copyWith(
          id: null,
          title: '${doc.title} (نسخة)',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isFavorite: false,
        )),
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> emptyTrash() async {
    try {
      final db = await _db.database;
      await db.delete(
        DbConstants.documentsTable,
        where: '${DbConstants.colIsDeleted} = ?',
        whereArgs: [1],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
