import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/folder_repository_impl.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepositoryImpl();
});

class FoldersNotifier extends StateNotifier<AsyncValue<List<Folder>>> {
  final FolderRepository _repository;
  int? _parentId;

  FoldersNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFolders();
  }

  Future<void> loadFolders({int? parentId}) async {
    _parentId = parentId;
    state = const AsyncValue.loading();
    final result = await _repository.getAllFolders(parentId: parentId);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (folders) => state = AsyncValue.data(folders),
    );
  }

  Future<Folder?> createFolder({
    required String name,
    int? parentId,
    int color = 0xFFFF9800,
    String icon = 'folder',
  }) async {
    final now = DateTime.now();
    final folder = Folder(
      name: name,
      parentId: parentId,
      color: color,
      icon: icon,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _repository.createFolder(folder);
    result.fold((_) {}, (_) => loadFolders(parentId: _parentId));
    return result.fold((_) => null, (f) => f);
  }

  Future<bool> updateFolder(Folder folder) async {
    final result = await _repository.updateFolder(folder);
    result.fold((_) {}, (_) => loadFolders(parentId: _parentId));
    return result.isRight();
  }

  Future<void> deleteFolder(int id) async {
    await _repository.deleteFolder(id);
    loadFolders(parentId: _parentId);
  }
}

final foldersProvider = StateNotifierProvider<FoldersNotifier, AsyncValue<List<Folder>>>((ref) {
  return FoldersNotifier(ref.watch(folderRepositoryProvider));
});
