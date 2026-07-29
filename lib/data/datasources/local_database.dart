import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/db_constants.dart';

class LocalDatabase {
  LocalDatabase._internal();
  static final LocalDatabase instance = LocalDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      // Document Types
      await txn.execute('''
        CREATE TABLE ${DbConstants.documentTypesTable} (
          ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${DbConstants.colName} TEXT NOT NULL,
          icon TEXT NOT NULL DEFAULT 'description',
          ${DbConstants.colColor} INTEGER NOT NULL DEFAULT 0xFF2196F3,
          ${DbConstants.colCreatedAt} TEXT NOT NULL
        )
      ''');

      // Categories
      await txn.execute('''
        CREATE TABLE ${DbConstants.categoriesTable} (
          ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${DbConstants.colName} TEXT NOT NULL,
          ${DbConstants.colColor} INTEGER NOT NULL DEFAULT 0xFF9E9E9E,
          ${DbConstants.colCreatedAt} TEXT NOT NULL
        )
      ''');

      // Folders
      await txn.execute('''
        CREATE TABLE ${DbConstants.foldersTable} (
          ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${DbConstants.colName} TEXT NOT NULL,
          ${DbConstants.colParentId} INTEGER,
          ${DbConstants.colColor} INTEGER NOT NULL DEFAULT 0xFFFF9800,
          ${DbConstants.colIcon} TEXT DEFAULT 'folder',
          ${DbConstants.colSortOrder} INTEGER NOT NULL DEFAULT 0,
          ${DbConstants.colCreatedAt} TEXT NOT NULL,
          ${DbConstants.colUpdatedAt} TEXT NOT NULL,
          FOREIGN KEY (${DbConstants.colParentId}) REFERENCES ${DbConstants.foldersTable}(${DbConstants.colId}) ON DELETE CASCADE
        )
      ''');

      // Templates
      await txn.execute('''
        CREATE TABLE ${DbConstants.templatesTable} (
          ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${DbConstants.colName} TEXT NOT NULL,
          ${DbConstants.colDescription} TEXT,
          ${DbConstants.colContent} TEXT NOT NULL DEFAULT '',
          ${DbConstants.colTypeId} INTEGER,
          ${DbConstants.colCategoryId} INTEGER,
          ${DbConstants.colIsDefault} INTEGER NOT NULL DEFAULT 0,
          ${DbConstants.colPreviewImage} TEXT,
          ${DbConstants.colColor} INTEGER DEFAULT 0xFF2196F3,
          ${DbConstants.colCreatedAt} TEXT NOT NULL,
          ${DbConstants.colUpdatedAt} TEXT NOT NULL,
          FOREIGN KEY (${DbConstants.colTypeId}) REFERENCES ${DbConstants.documentTypesTable}(${DbConstants.colId})
        )
      ''');

      // Documents
      await txn.execute('''
        CREATE TABLE ${DbConstants.documentsTable} (
          ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${DbConstants.colTitle} TEXT NOT NULL DEFAULT 'مستند جديد',
          ${DbConstants.colContent} TEXT NOT NULL DEFAULT '',
          ${DbConstants.colTypeId} INTEGER,
          ${DbConstants.colFolderId} INTEGER,
          ${DbConstants.colCategoryId} INTEGER,
          ${DbConstants.colIsFavorite} INTEGER NOT NULL DEFAULT 0,
          ${DbConstants.colIsArchived} INTEGER NOT NULL DEFAULT 0,
          ${DbConstants.colIsDeleted} INTEGER NOT NULL DEFAULT 0,
          ${DbConstants.colColor} INTEGER,
          ${DbConstants.colIcon} TEXT,
          ${DbConstants.colSortOrder} INTEGER NOT NULL DEFAULT 0,
          ${DbConstants.colWordCount} INTEGER NOT NULL DEFAULT 0,
          ${DbConstants.colCharCount} INTEGER NOT NULL DEFAULT 0,
          ${DbConstants.colLastOpenedAt} TEXT,
          ${DbConstants.colDeletedAt} TEXT,
          ${DbConstants.colCreatedAt} TEXT NOT NULL,
          ${DbConstants.colUpdatedAt} TEXT NOT NULL,
          FOREIGN KEY (${DbConstants.colTypeId}) REFERENCES ${DbConstants.documentTypesTable}(${DbConstants.colId}),
          FOREIGN KEY (${DbConstants.colFolderId}) REFERENCES ${DbConstants.foldersTable}(${DbConstants.colId}) ON DELETE SET NULL,
          FOREIGN KEY (${DbConstants.colCategoryId}) REFERENCES ${DbConstants.categoriesTable}(${DbConstants.colId}) ON DELETE SET NULL
        )
      ''');

      // Tags
      await txn.execute('''
        CREATE TABLE ${DbConstants.tagsTable} (
          ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${DbConstants.colName} TEXT NOT NULL UNIQUE,
          ${DbConstants.colColor} INTEGER DEFAULT 0xFF2196F3,
          ${DbConstants.colCreatedAt} TEXT NOT NULL
        )
      ''');

      // Document Tags (many-to-many)
      await txn.execute('''
        CREATE TABLE ${DbConstants.documentTagsTable} (
          ${DbConstants.colDocumentId} INTEGER NOT NULL,
          tag_id INTEGER NOT NULL,
          PRIMARY KEY (${DbConstants.colDocumentId}, tag_id),
          FOREIGN KEY (${DbConstants.colDocumentId}) REFERENCES ${DbConstants.documentsTable}(${DbConstants.colId}) ON DELETE CASCADE,
          FOREIGN KEY (tag_id) REFERENCES ${DbConstants.tagsTable}(${DbConstants.colId}) ON DELETE CASCADE
        )
      ''');

      // Attachments
      await txn.execute('''
        CREATE TABLE ${DbConstants.attachmentsTable} (
          ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${DbConstants.colDocumentId} INTEGER NOT NULL,
          ${DbConstants.colFileName} TEXT NOT NULL,
          ${DbConstants.colFilePath} TEXT NOT NULL,
          ${DbConstants.colFileSize} INTEGER NOT NULL DEFAULT 0,
          ${DbConstants.colFileType} TEXT NOT NULL DEFAULT 'file',
          ${DbConstants.colCreatedAt} TEXT NOT NULL,
          FOREIGN KEY (${DbConstants.colDocumentId}) REFERENCES ${DbConstants.documentsTable}(${DbConstants.colId}) ON DELETE CASCADE
        )
      ''');

      // History
      await txn.execute('''
        CREATE TABLE ${DbConstants.historyTable} (
          ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${DbConstants.colDocumentId} INTEGER NOT NULL,
          ${DbConstants.colAction} TEXT NOT NULL,
          ${DbConstants.colCreatedAt} TEXT NOT NULL,
          FOREIGN KEY (${DbConstants.colDocumentId}) REFERENCES ${DbConstants.documentsTable}(${DbConstants.colId}) ON DELETE CASCADE
        )
      ''');

      // Settings
      await txn.execute('''
        CREATE TABLE ${DbConstants.settingsTable} (
          ${DbConstants.colKey} TEXT PRIMARY KEY,
          ${DbConstants.colValue} TEXT NOT NULL
        )
      ''');

      // Insert default data
      await _insertDefaults(txn);
    });
  }

  Future<void> _insertDefaults(Transaction txn) async {
    final now = DateTime.now().toIso8601String();

    // Insert document types
    for (final type in AppConstants.defaultDocumentTypes) {
      await txn.insert(DbConstants.documentTypesTable, {
        DbConstants.colName: type['name'],
        'icon': type['icon'],
        DbConstants.colColor: type['color'],
        DbConstants.colCreatedAt: now,
      });
    }

    // Insert categories
    for (final cat in AppConstants.defaultCategories) {
      await txn.insert(DbConstants.categoriesTable, {
        DbConstants.colName: cat['name'],
        DbConstants.colColor: cat['color'],
        DbConstants.colCreatedAt: now,
      });
    }

    // Insert default settings
    await txn.insert(DbConstants.settingsTable, {DbConstants.colKey: 'theme', DbConstants.colValue: 'system'});
    await txn.insert(DbConstants.settingsTable, {DbConstants.colKey: 'language', DbConstants.colValue: 'ar'});
    await txn.insert(DbConstants.settingsTable, {DbConstants.colKey: 'font_size', DbConstants.colValue: '16'});
    await txn.insert(DbConstants.settingsTable, {DbConstants.colKey: 'auto_save', DbConstants.colValue: 'true'});
    await txn.insert(DbConstants.settingsTable, {DbConstants.colKey: 'view_mode', DbConstants.colValue: 'list'});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations in future versions
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
