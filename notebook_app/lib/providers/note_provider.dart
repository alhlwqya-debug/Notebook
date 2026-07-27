import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../models/template_model.dart';
import '../services/database_service.dart';

enum NoteFilter { all, pinned, favorites, templates }

enum SortOrder { newest, oldest, alphabetical, colorGrouped }

class NoteProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<NoteModel> _notes = [];
  List<NoteModel> _filteredNotes = [];
  List<TemplateModel> _templates = [];
  List<Map<String, dynamic>> _categories = [];

  NoteFilter _currentFilter = NoteFilter.all;
  SortOrder _sortOrder = SortOrder.newest;
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isLoading = false;
  bool _isDarkMode = false;
  bool _isGridView = true;

  // Getters
  List<NoteModel> get notes => _filteredNotes;
  List<NoteModel> get allNotes => _notes;
  List<TemplateModel> get templates => _templates;
  List<Map<String, dynamic>> get categories => _categories;
  NoteFilter get currentFilter => _currentFilter;
  SortOrder get sortOrder => _sortOrder;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  bool get isGridView => _isGridView;

  int get totalNotes => _notes.length;
  int get pinnedCount => _notes.where((n) => n.isPinned).length;
  int get favoritesCount => _notes.where((n) => n.isFavorite).length;

  // ─── تحميل البيانات ───────────────────────────────────────

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _db.getAllNotes();
      _categories = await _db.getAllCategories();
      _templates = await _db.getAllTemplates();

      // إضافة القوالب المدمجة إذا لم تُضف بعد
      if (_templates.isEmpty) {
        for (final t in TemplateModel.builtinTemplates) {
          await _db.insertTemplate(t);
        }
        _templates = await _db.getAllTemplates();
      }

      // تحميل الإعدادات
      await _loadPreferences();

      _applyFiltersAndSort();
    } catch (e) {
      debugPrint('Error loading notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isGridView = prefs.getBool('isGridView') ?? true;
    _sortOrder = SortOrder.values[prefs.getInt('sortOrder') ?? 0];
  }

  void _applyFiltersAndSort() {
    List<NoteModel> result = List.from(_notes);

    // تطبيق الفلتر
    switch (_currentFilter) {
      case NoteFilter.all:
        break;
      case NoteFilter.pinned:
        result = result.where((n) => n.isPinned).toList();
        break;
      case NoteFilter.favorites:
        result = result.where((n) => n.isFavorite).toList();
        break;
      case NoteFilter.templates:
        // تظهر الملاحظات التي تستخدم قوالب
        result = result.where((n) => n.templateId != null || n.templateType != null).toList();
        break;
    }

    // تصفية حسب الفئة
    if (_selectedCategory != null) {
      result = result.where((n) => n.category == _selectedCategory).toList();
    }

    // تطبيق البحث
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((n) {
        return n.title.toLowerCase().contains(q) ||
            n.contentPreview.toLowerCase().contains(q) ||
            (n.category?.toLowerCase().contains(q) ?? false) ||
            n.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    // الترتيب
    switch (_sortOrder) {
      case SortOrder.newest:
        result.sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
      case SortOrder.oldest:
        result.sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return a.updatedAt.compareTo(b.updatedAt);
        });
        break;
      case SortOrder.alphabetical:
        result.sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return a.title.compareTo(b.title);
        });
        break;
      case SortOrder.colorGrouped:
        result.sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return a.colorIndex.compareTo(b.colorIndex);
        });
        break;
    }

    _filteredNotes = result;
  }

  // ─── إجراءات الملاحظات ────────────────────────────────────

  Future<NoteModel> addNote(NoteModel note) async {
    final id = await _db.insertNote(note);
    final newNote = note.copyWith(id: id);
    _notes.insert(0, newNote);
    _applyFiltersAndSort();
    notifyListeners();
    return newNote;
  }

  Future<void> updateNote(NoteModel note) async {
    await _db.updateNote(note);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  Future<void> deleteNote(int id) async {
    await _db.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    _applyFiltersAndSort();
    notifyListeners();
  }

  Future<void> togglePin(NoteModel note) async {
    final updated = note.copyWith(isPinned: !note.isPinned);
    await updateNote(updated);
  }

  Future<void> toggleFavorite(NoteModel note) async {
    final updated = note.copyWith(isFavorite: !note.isFavorite);
    await updateNote(updated);
  }

  Future<void> toggleArchive(NoteModel note) async {
    final updated = note.copyWith(isArchived: !note.isArchived);
    await _db.updateNote(updated);
    if (updated.isArchived) {
      _notes.removeWhere((n) => n.id == note.id);
    } else {
      _notes.insert(0, updated);
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  Future<bool> verifyPassword(NoteModel note, String password) async {
    // مقارنة بسيطة (يمكن تحسينها بالتشفير)
    return note.password == password;
  }

  Future<void> setPassword(NoteModel note, String password) async {
    final updated = note.copyWith(
      isPasswordProtected: true,
      password: password,
    );
    await updateNote(updated);
  }

  Future<void> removePassword(NoteModel note) async {
    final updated = note.copyWith(
      isPasswordProtected: false,
      password: null,
    );
    await updateNote(updated);
  }

  // ─── الفلاتر والبحث ───────────────────────────────────────

  void setFilter(NoteFilter filter) {
    _currentFilter = filter;
    _selectedCategory = null;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    _currentFilter = NoteFilter.all;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortOrder(SortOrder order) async {
    _sortOrder = order;
    _applyFiltersAndSort();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sortOrder', order.index);
  }

  // ─── إعدادات العرض ───────────────────────────────────────

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void toggleViewMode() async {
    _isGridView = !_isGridView;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGridView', _isGridView);
  }

  // ─── القوالب ─────────────────────────────────────────────

  Future<void> addTemplate(TemplateModel template) async {
    await _db.insertTemplate(template);
    _templates = await _db.getAllTemplates();
    notifyListeners();
  }

  Future<void> updateTemplate(TemplateModel template) async {
    await _db.updateTemplate(template);
    final index = _templates.indexWhere((t) => t.id == template.id);
    if (index != -1) _templates[index] = template;
    notifyListeners();
  }

  Future<void> deleteTemplate(String id) async {
    await _db.deleteTemplate(id);
    _templates.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ─── التصنيفات ────────────────────────────────────────────

  Future<void> addCategory(String name, int colorIndex, String? iconName) async {
    await _db.insertCategory(name, colorIndex, iconName);
    _categories = await _db.getAllCategories();
    notifyListeners();
  }

  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);
    _categories = await _db.getAllCategories();
    notifyListeners();
  }

  // ─── استيراد الملاحظات ────────────────────────────────────

  Future<void> importNotes(List<NoteModel> notes) async {
    for (final note in notes) {
      final id = await _db.insertNote(note);
      _notes.insert(0, note.copyWith(id: id));
    }
    _applyFiltersAndSort();
    notifyListeners();
  }
}
