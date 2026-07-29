class DbConstants {
  DbConstants._();

  // Table names
  static const String documentsTable = 'documents';
  static const String documentTypesTable = 'document_types';
  static const String templatesTable = 'templates';
  static const String categoriesTable = 'categories';
  static const String tagsTable = 'tags';
  static const String documentTagsTable = 'document_tags';
  static const String attachmentsTable = 'attachments';
  static const String favoritesTable = 'favorites';
  static const String historyTable = 'history';
  static const String settingsTable = 'settings';
  static const String trashTable = 'trash';
  static const String foldersTable = 'folders';

  // Common columns
  static const String colId = 'id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // Documents columns
  static const String colTitle = 'title';
  static const String colContent = 'content';
  static const String colTypeId = 'type_id';
  static const String colFolderId = 'folder_id';
  static const String colCategoryId = 'category_id';
  static const String colIsFavorite = 'is_favorite';
  static const String colIsArchived = 'is_archived';
  static const String colIsDeleted = 'is_deleted';
  static const String colColor = 'color';
  static const String colIcon = 'icon';
  static const String colSortOrder = 'sort_order';
  static const String colWordCount = 'word_count';
  static const String colCharCount = 'char_count';
  static const String colLastOpenedAt = 'last_opened_at';
  static const String colDeletedAt = 'deleted_at';

  // Templates columns
  static const String colName = 'name';
  static const String colDescription = 'description';
  static const String colIsDefault = 'is_default';
  static const String colPreviewImage = 'preview_image';

  // Folders columns
  static const String colParentId = 'parent_id';

  // Settings columns
  static const String colKey = 'key';
  static const String colValue = 'value';

  // History columns
  static const String colDocumentId = 'document_id';
  static const String colAction = 'action';

  // Attachments columns
  static const String colFilePath = 'file_path';
  static const String colFileName = 'file_name';
  static const String colFileSize = 'file_size';
  static const String colFileType = 'file_type';
}
