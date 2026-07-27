import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import '../../models/note_model.dart';

enum ExportFormat { pdf, txt, json, html, markdown, csv, zip }

class ExportService {
  static final ExportService instance = ExportService._();
  ExportService._();

  Future<String> _getExportDirectory() async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
      dir = Directory('${dir!.path}/NotebookExports');
    } else {
      dir = await getApplicationDocumentsDirectory();
      dir = Directory('${dir.path}/NotebookExports');
    }
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir.path;
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
  }

  // ─── تصدير PDF ────────────────────────────────────────────

  Future<String> exportToPdf(NoteModel note) async {
    final pdf = pw.Document();

    // تحميل خط عربي
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: arabicFont,
          bold: arabicFontBold,
        ),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              note.title,
              style: pw.TextStyle(
                font: arabicFontBold,
                fontSize: 24,
                color: PdfColor.fromHex('6C63FF'),
              ),
              textDirection: pw.TextDirection.rtl,
            ),
            pw.Divider(color: PdfColor.fromHex('6C63FF')),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'تاريخ الإنشاء: ${_formatDate(note.createdAt)}',
                  style: pw.TextStyle(font: arabicFont, fontSize: 10, color: PdfColors.grey600),
                  textDirection: pw.TextDirection.rtl,
                ),
                if (note.category != null)
                  pw.Text(
                    'التصنيف: ${note.category}',
                    style: pw.TextStyle(font: arabicFont, fontSize: 10, color: PdfColors.grey600),
                    textDirection: pw.TextDirection.rtl,
                  ),
              ],
            ),
            pw.SizedBox(height: 8),
          ],
        ),
        build: (context) => [
          pw.Text(
            _extractPlainText(note.content),
            style: pw.TextStyle(font: arabicFont, fontSize: 14),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'دفتري - تطبيق الملاحظات',
              style: pw.TextStyle(font: arabicFont, fontSize: 10, color: PdfColors.grey500),
            ),
            pw.Text(
              '${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(font: arabicFont, fontSize: 10, color: PdfColors.grey500),
            ),
          ],
        ),
      ),
    );

    final dir = await _getExportDirectory();
    final fileName = '${_sanitizeFileName(note.title)}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('$dir/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  // ─── تصدير TXT ────────────────────────────────────────────

  Future<String> exportToTxt(NoteModel note) async {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════');
    buffer.writeln(note.title);
    buffer.writeln('═══════════════════════════════════');
    buffer.writeln();
    buffer.writeln('التاريخ: ${_formatDate(note.createdAt)}');
    if (note.category != null) buffer.writeln('التصنيف: ${note.category}');
    if (note.tags.isNotEmpty) buffer.writeln('الوسوم: ${note.tags.join(', ')}');
    buffer.writeln();
    buffer.writeln(_extractPlainText(note.content));
    buffer.writeln();
    buffer.writeln('─── تم التصدير بواسطة دفتري ───');

    final dir = await _getExportDirectory();
    final fileName = '${_sanitizeFileName(note.title)}.txt';
    final file = File('$dir/$fileName');
    await file.writeAsString(buffer.toString(), encoding: utf8);
    return file.path;
  }

  // ─── تصدير JSON ───────────────────────────────────────────

  Future<String> exportToJson(NoteModel note) async {
    final jsonData = note.toJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

    final dir = await _getExportDirectory();
    final fileName = '${_sanitizeFileName(note.title)}.json';
    final file = File('$dir/$fileName');
    await file.writeAsString(jsonString, encoding: utf8);
    return file.path;
  }

  // ─── تصدير HTML ───────────────────────────────────────────

  Future<String> exportToHtml(NoteModel note) async {
    final content = _extractPlainText(note.content);
    final htmlContent = '''<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${note.title}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&display=swap');
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Cairo', 'Arial', sans-serif;
      background: #f8f9fe;
      color: #1a1a2e;
      direction: rtl;
      padding: 20px;
    }
    .container { max-width: 800px; margin: 0 auto; background: white; border-radius: 16px; padding: 40px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
    .header { border-bottom: 3px solid #6C63FF; padding-bottom: 20px; margin-bottom: 24px; }
    h1 { color: #6C63FF; font-size: 2em; margin-bottom: 8px; }
    .meta { color: #6B7280; font-size: 0.9em; display: flex; gap: 16px; flex-wrap: wrap; }
    .badge { background: #E8D6FF; color: #6C63FF; padding: 2px 10px; border-radius: 20px; }
    .content { line-height: 2; font-size: 1.1em; white-space: pre-wrap; }
    .footer { margin-top: 40px; padding-top: 20px; border-top: 1px solid #e5e7eb; color: #9CA3AF; font-size: 0.8em; text-align: center; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>${note.title}</h1>
      <div class="meta">
        <span>📅 ${_formatDate(note.createdAt)}</span>
        ${note.category != null ? '<span class="badge">${note.category}</span>' : ''}
        ${note.tags.isNotEmpty ? '<span>${note.tags.map((t) => '#$t').join(' ')}</span>' : ''}
      </div>
    </div>
    <div class="content">$content</div>
    <div class="footer">تم التصدير بواسطة تطبيق دفتري</div>
  </div>
</body>
</html>''';

    final dir = await _getExportDirectory();
    final fileName = '${_sanitizeFileName(note.title)}.html';
    final file = File('$dir/$fileName');
    await file.writeAsString(htmlContent, encoding: utf8);
    return file.path;
  }

  // ─── تصدير Markdown ───────────────────────────────────────

  Future<String> exportToMarkdown(NoteModel note) async {
    final buffer = StringBuffer();
    buffer.writeln('# ${note.title}');
    buffer.writeln();
    buffer.writeln('> **التاريخ:** ${_formatDate(note.createdAt)}');
    if (note.category != null) buffer.writeln('> **التصنيف:** ${note.category}');
    if (note.tags.isNotEmpty) buffer.writeln('> **الوسوم:** ${note.tags.map((t) => '`$t`').join(' ')}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln(_extractPlainText(note.content));
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('*تم التصدير بواسطة تطبيق دفتري*');

    final dir = await _getExportDirectory();
    final fileName = '${_sanitizeFileName(note.title)}.md';
    final file = File('$dir/$fileName');
    await file.writeAsString(buffer.toString(), encoding: utf8);
    return file.path;
  }

  // ─── تصدير CSV ────────────────────────────────────────────

  Future<String> exportToCsv(List<NoteModel> notes) async {
    final List<List<dynamic>> rows = [
      ['المعرف', 'العنوان', 'المحتوى', 'التصنيف', 'التاريخ', 'مثبتة', 'مفضلة', 'الوسوم'],
    ];

    for (final note in notes) {
      rows.add([
        note.id ?? '',
        note.title,
        _extractPlainText(note.content),
        note.category ?? '',
        _formatDate(note.createdAt),
        note.isPinned ? 'نعم' : 'لا',
        note.isFavorite ? 'نعم' : 'لا',
        note.tags.join(', '),
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await _getExportDirectory();
    final fileName = 'notes_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('$dir/$fileName');
    await file.writeAsString('\uFEFF$csv', encoding: utf8); // BOM للعربية في Excel
    return file.path;
  }

  // ─── تصدير ZIP ────────────────────────────────────────────

  Future<String> exportToZip(List<NoteModel> notes) async {
    final archive = Archive();

    for (final note in notes) {
      // إضافة كل ملاحظة كملف JSON
      final jsonBytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(note.toJson()));
      final fileName = '${_sanitizeFileName(note.title)}.json';
      archive.addFile(ArchiveFile(fileName, jsonBytes.length, jsonBytes));
    }

    // إضافة ملف CSV الشامل
    final csvRows = [
      ['العنوان', 'التصنيف', 'التاريخ', 'مثبتة', 'مفضلة'],
      ...notes.map((n) => [n.title, n.category ?? '', _formatDate(n.createdAt), n.isPinned, n.isFavorite]),
    ];
    final csvContent = utf8.encode('\uFEFF${const ListToCsvConverter().convert(csvRows)}');
    archive.addFile(ArchiveFile('notes_index.csv', csvContent.length, csvContent));

    final zipBytes = ZipEncoder().encode(archive);
    final dir = await _getExportDirectory();
    final fileName = 'daftari_backup_${DateTime.now().millisecondsSinceEpoch}.zip';
    final file = File('$dir/$fileName');
    await file.writeAsBytes(zipBytes!);
    return file.path;
  }

  // ─── مشاركة الملف ─────────────────────────────────────────

  Future<void> shareFile(String filePath, {String? subject}) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject ?? 'ملاحظة من دفتري',
    );
  }

  // ─── مساعدات ─────────────────────────────────────────────

  String _extractPlainText(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        final buffer = StringBuffer();
        for (final op in decoded) {
          if (op is Map && op['insert'] is String) {
            buffer.write(op['insert']);
          }
        }
        return buffer.toString().trim();
      }
    } catch (_) {}
    return content;
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
