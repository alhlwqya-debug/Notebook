import 'package:dartz/dartz.dart';

import '../entities/folder.dart';
import '../../core/errors/failures.dart';

abstract class FolderRepository {
  Future<Either<Failure, List<Folder>>> getAllFolders({int? parentId});
  Future<Either<Failure, Folder>> getFolderById(int id);
  Future<Either<Failure, Folder>> createFolder(Folder folder);
  Future<Either<Failure, Folder>> updateFolder(Folder folder);
  Future<Either<Failure, void>> deleteFolder(int id);
  Future<Either<Failure, void>> moveFolder(int folderId, int? parentId);
}
