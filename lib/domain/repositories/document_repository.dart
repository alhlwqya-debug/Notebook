import 'package:dartz/dartz.dart';

import '../entities/document.dart';
import '../../core/errors/failures.dart';

abstract class DocumentRepository {
  Future<Either<Failure, List<Document>>> getAllDocuments({
    bool includeArchived = false,
    bool includeDeleted = false,
    int? folderId,
    int? categoryId,
    int? typeId,
    String? sortBy,
    bool ascending = false,
  });

  Future<Either<Failure, Document>> getDocumentById(int id);

  Future<Either<Failure, List<Document>>> searchDocuments({
    required String query,
    int? typeId,
    int? categoryId,
    DateTime? fromDate,
    DateTime? toDate,
    List<String>? tags,
  });

  Future<Either<Failure, List<Document>>> getFavoriteDocuments();

  Future<Either<Failure, List<Document>>> getArchivedDocuments();

  Future<Either<Failure, List<Document>>> getDeletedDocuments();

  Future<Either<Failure, List<Document>>> getRecentDocuments({int limit = 10});

  Future<Either<Failure, Document>> createDocument(Document document);

  Future<Either<Failure, Document>> updateDocument(Document document);

  Future<Either<Failure, void>> deleteDocument(int id);

  Future<Either<Failure, void>> permanentlyDeleteDocument(int id);

  Future<Either<Failure, void>> restoreDocument(int id);

  Future<Either<Failure, void>> toggleFavorite(int id);

  Future<Either<Failure, void>> archiveDocument(int id);

  Future<Either<Failure, void>> unarchiveDocument(int id);

  Future<Either<Failure, void>> moveDocument(int documentId, int? folderId);

  Future<Either<Failure, Document>> duplicateDocument(int id);

  Future<Either<Failure, void>> emptyTrash();
}
