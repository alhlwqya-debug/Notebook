import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/document_repository_impl.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';

// Repository provider
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl();
});

// Enum for sort options
enum DocumentSort { updatedAt, createdAt, title, wordCount }

// Enum for view mode
enum ViewMode { list, grid }

// State class
class DocumentsState {
  final List<Document> documents;
  final bool isLoading;
  final String? error;
  final DocumentSort sortBy;
  final bool ascending;
  final ViewMode viewMode;
  final int? selectedTypeId;
  final int? selectedCategoryId;
  final int? selectedFolderId;

  const DocumentsState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
    this.sortBy = DocumentSort.updatedAt,
    this.ascending = false,
    this.viewMode = ViewMode.list,
    this.selectedTypeId,
    this.selectedCategoryId,
    this.selectedFolderId,
  });

  DocumentsState copyWith({
    List<Document>? documents,
    bool? isLoading,
    String? error,
    DocumentSort? sortBy,
    bool? ascending,
    ViewMode? viewMode,
    int? selectedTypeId,
    int? selectedCategoryId,
    int? selectedFolderId,
  }) {
    return DocumentsState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      viewMode: viewMode ?? this.viewMode,
      selectedTypeId: selectedTypeId ?? this.selectedTypeId,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedFolderId: selectedFolderId ?? this.selectedFolderId,
    );
  }
}

class DocumentsNotifier extends StateNotifier<DocumentsState> {
  final DocumentRepository _repository;

  DocumentsNotifier(this._repository) : super(const DocumentsState()) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, error: null);
    final sortMap = {
      DocumentSort.updatedAt: 'updated_at',
      DocumentSort.createdAt: 'created_at',
      DocumentSort.title: 'title',
      DocumentSort.wordCount: 'word_count',
    };
    final result = await _repository.getAllDocuments(
      folderId: state.selectedFolderId,
      categoryId: state.selectedCategoryId,
      typeId: state.selectedTypeId,
      sortBy: sortMap[state.sortBy],
      ascending: state.ascending,
    );
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (docs) => state = state.copyWith(documents: docs, isLoading: false),
    );
  }

  Future<Document?> createDocument(Document document) async {
    final result = await _repository.createDocument(document);
    result.fold((_) {}, (_) => loadDocuments());
    return result.fold((_) => null, (doc) => doc);
  }

  Future<bool> updateDocument(Document document) async {
    final result = await _repository.updateDocument(document);
    result.fold((_) {}, (_) => loadDocuments());
    return result.isRight();
  }

  Future<void> deleteDocument(int id) async {
    await _repository.deleteDocument(id);
    loadDocuments();
  }

  Future<void> toggleFavorite(int id) async {
    await _repository.toggleFavorite(id);
    loadDocuments();
  }

  Future<void> archiveDocument(int id) async {
    await _repository.archiveDocument(id);
    loadDocuments();
  }

  Future<void> moveDocument(int documentId, int? folderId) async {
    await _repository.moveDocument(documentId, folderId);
    loadDocuments();
  }

  Future<void> duplicateDocument(int id) async {
    await _repository.duplicateDocument(id);
    loadDocuments();
  }

  void setSortBy(DocumentSort sort) {
    state = state.copyWith(sortBy: sort);
    loadDocuments();
  }

  void toggleAscending() {
    state = state.copyWith(ascending: !state.ascending);
    loadDocuments();
  }

  void setViewMode(ViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void setFolderFilter(int? folderId) {
    state = state.copyWith(selectedFolderId: folderId);
    loadDocuments();
  }

  void setTypeFilter(int? typeId) {
    state = state.copyWith(selectedTypeId: typeId);
    loadDocuments();
  }
}

final documentsProvider = StateNotifierProvider<DocumentsNotifier, DocumentsState>((ref) {
  return DocumentsNotifier(ref.watch(documentRepositoryProvider));
});

final favoritesProvider = FutureProvider<List<Document>>((ref) async {
  final repo = ref.watch(documentRepositoryProvider);
  final result = await repo.getFavoriteDocuments();
  return result.fold((_) => [], (docs) => docs);
});

final archivedDocumentsProvider = FutureProvider<List<Document>>((ref) async {
  final repo = ref.watch(documentRepositoryProvider);
  final result = await repo.getArchivedDocuments();
  return result.fold((_) => [], (docs) => docs);
});

final trashedDocumentsProvider = FutureProvider<List<Document>>((ref) async {
  final repo = ref.watch(documentRepositoryProvider);
  final result = await repo.getDeletedDocuments();
  return result.fold((_) => [], (docs) => docs);
});

final recentDocumentsProvider = FutureProvider<List<Document>>((ref) async {
  final repo = ref.watch(documentRepositoryProvider);
  final result = await repo.getRecentDocuments(limit: 10);
  return result.fold((_) => [], (docs) => docs);
});

final documentByIdProvider = FutureProvider.family<Document?, int>((ref, id) async {
  final repo = ref.watch(documentRepositoryProvider);
  final result = await repo.getDocumentById(id);
  return result.fold((_) => null, (doc) => doc);
});
