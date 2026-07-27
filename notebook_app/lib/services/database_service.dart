import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note_model.dart';
import '../models/template_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'daftari.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // جدول الملاحظات
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT,
        colorIndex INTEGER DEFAULT 0,
        templateType TEXT,
        templateId TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isPinned INTEGER DEFAULT 0,
        isFavorite INTEGER DEFAULT 0,
        isPasswordProtected INTEGER DEFAULT 0,
        password TEXT,
        tags TEXT,
        imagePaths TEXT,
        fontFamily TEXT DEFAULT 'Tajawal',
        fontSize REAL DEFAULT 16.0,
        textAlign TEXT DEFAULT 'right',
        customFields TEXT,
        backgroundImage TEXT,
        reminderDate TEXT,
        isArchived INTEGER DEFAULT 0,
        ownerId TEXT
      )
    ''');

    // جدول التصنيفات
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        colorIndex INTEGER DEFAULT 0,
        iconName TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // جدول القوالب المخصصة
    await db.execute('''
      CREATE TABLE custom_templates (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        colorIndex INTEGER DEFAULT 0,
        fields TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        backgroundImage TEXT,
        headerText TEXT,
        footerText TEXT,
        isDefault INTEGER DEFAULT 0
      )
    ''');

    // إدراج تصنيفات افتراضية
    final now = DateTime.now().toIso8601String();
    await db.insert('categories', {'name': 'عام', 'colorIndex': 0, 'iconName': 'note', 'createdAt': now});
    await db.insert('categories', {'name': 'عمل', 'colorIndex': 2, 'iconName': 'work', 'createdAt': now});
    await db.insert('categories', {'name': 'شخصي', 'colorIndex': 4, 'iconName': 'person', 'createdAt': now});
    await db.insert('categories', {'name': 'دراسة', 'colorIndex': 1, 'iconName': 'school', 'createdAt': now});
    await db.insert('categories', {'name': 'أفكار', 'colorIndex': 6, 'iconName': 'lightbulb', 'createdAt': now});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN isArchived INTEGER DEFAULT 0');
    }
  }

  // ─── CRUD للملاحظات ───────────────────────────────────────

  Future<int> insertNote(NoteModel note) async {
    final db = await database;
    return await db.insert('notes', note.toMap()..remove('id'));
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<NoteModel>> getAllNotes({bool includeArchived = false}) async {
    final db = await database;
    final where = includeArchived ? null : 'isArchived = 0';
    final maps = await db.query(
      'notes',
      where: where,
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map((m) => NoteModel.fromMap(m)).toList();
  }

  Future<NoteModel?> getNoteById(int id) async {
    final db = await database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return NoteModel.fromMap(maps.first);
  }

  Future<List<NoteModel>> getPinnedNotes() async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'isPinned = 1 AND isArchived = 0',
      orderBy: 'updatedAt DESC',
    );
    return maps.map((m) => NoteModel.fromMap(m)).toList();
  }

  Future<List<NoteModel>> getFavoriteNotes() async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'isFavorite = 1 AND isArchived = 0',
      orderBy: 'updatedAt DESC',
    );
    return maps.map((m) => NoteModel.fromMap(m)).toList();
  }

  Future<List<NoteModel>> getNotesByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'category = ? AND isArchived = 0',
      whereArgs: [category],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map((m) => NoteModel.fromMap(m)).toList();
  }

  Future<List<NoteModel>> searchNotes(String query) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: '(title LIKE ? OR content LIKE ?) AND isArchived = 0',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map((m) => NoteModel.fromMap(m)).toList();
  }

  Future<List<NoteModel>> getArchivedNotes() async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'isArchived = 1',
      orderBy: 'updatedAt DESC',
    );
    return maps.map((m) => NoteModel.fromMap(m)).toList();
  }

  Future<int> getNoteCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM notes WHERE isArchived = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─── CRUD للتصنيفات ───────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('categories', orderBy: 'name ASC');
  }

  Future<int> insertCategory(String name, int colorIndex, String? iconName) async {
    final db = await database;
    return await db.insert('categories', {
      'name': name,
      'colorIndex': colorIndex,
      'iconName': iconName,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ─── CRUD للقوالب ─────────────────────────────────────────

  Future<void> insertTemplate(TemplateModel template) async {
    final db = await database;
    await db.insert('custom_templates', template.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTemplate(TemplateModel template) async {
    final db = await database;
    await db.update(
      'custom_templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<int> deleteTemplate(String id) async {
    final db = await database;
    return await db.delete('custom_templates', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TemplateModel>> getAllTemplates() async {
    final db = await database;
    final maps = await db.query('custom_templates', orderBy: 'isDefault DESC, name ASC');
    return maps.map((m) => TemplateModel.fromMap(m)).toList();
  }

  // ─── مسح قاعدة البيانات ───────────────────────────────────

  Future<void> clearAllNotes() async {
    final db = await database;
    await db.delete('notes');
  }
}
