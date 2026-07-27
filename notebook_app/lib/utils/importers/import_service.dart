import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import '../../models/note_model.dart';

class ImportService {
  static final ImportService instance = ImportService._();
  ImportService._();

  // ─── اختيار وقراءة الملفات ────────────────────────────────

  Future<List<NoteModel>?> pickAndImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'txt', 'csv', 'zip', 'md'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = File(result.files.single.path!);
    final extension = result.files.single.extension?.toLowerCase();

    switch (extension) {
      case 'json':
        return await _importFromJson(file);
      case 'txt':
        return await _importFromTxt(file);
      case 'csv':
        return await _importFromCsv(file);
      case 'zip':
        return await _importFromZip(file);
      case 'md':
        return await _importFromMarkdown(file);
      default:
        return null;
    }
  }

  // ─── استيراد JSON ─────────────────────────────────────────

  Future<List<NoteModel>?> _importFromJson(File file) async {
    try {
      final content = await file.readAsString(encoding: utf8);
      final decoded = jsonDecode(content);

      if (decoded is List) {
        // ملف JSON يحتوي على قائمة ملاحظات
        return decoded
            .map((item) => NoteModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (decoded is Map) {
        // ملف JSON يحتوي على ملاحظة واحدة
        return [NoteModel.fromJson(Map<String, dynamic>.from(decoded))];
      }
    } catch (e) {
      // محاولة قراءة كملف Quill Delta JSON
      try {
        final content = await file.readAsString(encoding: utf8);
        return [
          NoteModel(
            title: file.path.split('/').last.replaceAll('.json', ''),
            content: content,
          )
        ];
      } catch (_) {}
    }
    return null;
  }

  // ─── استيراد TXT ──────────────────────────────────────────

  Future<List<NoteModel>?> _importFromTxt(File file) async {
    try {
      final content = await file.readAsString(encoding: utf8);
      final lines = content.split('\n');

      String title = file.path.split('/').last.replaceAll('.txt', '');
      String noteContent = content;

      // محاولة استخراج العنوان من السطر الأول إذا كان يبدو عنواناً
      if (lines.isNotEmpty && lines.first.trim().isNotEmpty && lines.first.length < 100) {
        // التحقق من نمط التصدير القديم
        if (lines.length > 2 && lines[1].startsWith('═')) {
          title = lines.first.trim();
          noteContent = lines.skip(4).join('\n').trim();
        } else {
          title = lines.first.trim();
          noteContent = lines.skip(1).join('\n').trim();
        }
      }

      // تحويل النص إلى صيغة Quill Delta
      final deltaContent = jsonEncode([
        {'insert': noteContent + '\n'},
      ]);

      return [
        NoteModel(
          title: title.isNotEmpty ? title : 'ملاحظة مستوردة',
          content: deltaContent,
        )
      ];
    } catch (e) {
      return null;
    }
  }

  // ─── استيراد CSV ──────────────────────────────────────────

  Future<List<NoteModel>?> _importFromCsv(File file) async {
    try {
      // قراءة الملف مع معالجة BOM
      String content = await file.readAsString(encoding: utf8);
      if (content.startsWith('\uFEFF')) {
        content = content.substring(1);
      }

      final rows = const CsvToListConverter().convert(content);
      if (rows.isEmpty) return null;

      // تخطي صف الرأس
      final dataRows = rows.skip(1).toList();
      final notes = <NoteModel>[];

      for (final row in dataRows) {
        if (row.isEmpty || row.first.toString().isEmpty) continue;

        final title = row.length > 1 ? row[1].toString() : row[0].toString();
        final content = row.length > 2 ? row[2].toString() : '';
        final category = row.length > 3 && row[3].toString().isNotEmpty ? row[3].toString() : null;

        final deltaContent = jsonEncode([
          {'insert': content + '\n'},
        ]);

        notes.add(NoteModel(
          title: title.isNotEmpty ? title : 'ملاحظة مستوردة',
          content: deltaContent,
          category: category,
        ));
      }

      return notes.isNotEmpty ? notes : null;
    } catch (e) {
      return null;
    }
  }

  // ─── استيراد ZIP ──────────────────────────────────────────

  Future<List<NoteModel>?> _importFromZip(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final notes = <NoteModel>[];

      for (final archiveFile in archive.files) {
        if (!archiveFile.isFile) continue;

        final fileName = archiveFile.name.toLowerCase();
        final content = utf8.decode(archiveFile.content as List<int>);

        if (fileName.endsWith('.json') && !fileName.contains('index')) {
          try {
            final decoded = jsonDecode(content);
            if (decoded is Map) {
              notes.add(NoteModel.fromJson(Map<String, dynamic>.from(decoded)));
            }
          } catch (_) {}
        } else if (fileName.endsWith('.txt')) {
          final deltaContent = jsonEncode([{'insert': content + '\n'}]);
          notes.add(NoteModel(
            title: archiveFile.name.replaceAll('.txt', ''),
            content: deltaContent,
          ));
        }
      }

      return notes.isNotEmpty ? notes : null;
    } catch (e) {
      return null;
    }
  }

  // ─── استيراد Markdown ─────────────────────────────────────

  Future<List<NoteModel>?> _importFromMarkdown(File file) async {
    try {
      final content = await file.readAsString(encoding: utf8);
      final lines = content.split('\n');

      String title = file.path.split('/').last.replaceAll('.md', '');
      String? category;
      String noteContent = content;

      // استخراج العنوان من # Heading
      if (lines.isNotEmpty && lines.first.startsWith('# ')) {
        title = lines.first.substring(2).trim();

        // استخراج البيانات الوصفية من blockquote
        final metaLines = lines.skip(1).takeWhile((l) => l.startsWith('>')).toList();
        for (final line in metaLines) {
          if (line.contains('التصنيف:')) {
            category = line.split(':').last.trim();
          }
        }

        // الحصول على المحتوى بعد الفاصل
        final separatorIndex = lines.indexOf('---');
        if (separatorIndex != -1 && separatorIndex + 1 < lines.length) {
          noteContent = lines.skip(separatorIndex + 1).join('\n').trim();
          // إزالة التذييل
          final footerIndex = noteContent.lastIndexOf('---');
          if (footerIndex != -1) {
            noteContent = noteContent.substring(0, footerIndex).trim();
          }
        }
      }

      // تحويل إلى Quill Delta
      final deltaContent = jsonEncode([{'insert': noteContent + '\n'}]);

      return [
        NoteModel(
          title: title.isNotEmpty ? title : 'ملاحظة مستوردة',
          content: deltaContent,
          category: category,
        )
      ];
    } catch (e) {
      return null;
    }
  }

  // ─── استيراد من نص مباشر ──────────────────────────────────

  NoteModel importFromText(String title, String text) {
    final deltaContent = jsonEncode([{'insert': text + '\n'}]);
    return NoteModel(title: title, content: deltaContent);
  }
}
