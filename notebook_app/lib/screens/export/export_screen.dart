import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/note_model.dart';
import '../../providers/note_provider.dart';
import '../../utils/exporters/export_service.dart';

class ExportScreen extends StatefulWidget {
  final NoteModel note;

  const ExportScreen({super.key, required this.note});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _isExporting = false;
  String? _exportedFilePath;
  ExportFormat? _activeFormat;

  final List<_ExportOption> _options = [
    _ExportOption(
      format: ExportFormat.pdf,
      title: 'PDF',
      subtitle: 'مستند PDF مع دعم العربية',
      icon: Icons.picture_as_pdf_outlined,
      color: AppColors.exportPdf,
    ),
    _ExportOption(
      format: ExportFormat.txt,
      title: 'TXT',
      subtitle: 'ملف نصي بترميز UTF-8',
      icon: Icons.text_snippet_outlined,
      color: AppColors.exportTxt,
    ),
    _ExportOption(
      format: ExportFormat.json,
      title: 'JSON',
      subtitle: 'بيانات الملاحظة كاملة',
      icon: Icons.data_object_outlined,
      color: AppColors.exportJson,
    ),
    _ExportOption(
      format: ExportFormat.html,
      title: 'HTML',
      subtitle: 'صفحة ويب مع دعم RTL',
      icon: Icons.html_outlined,
      color: AppColors.exportHtml,
    ),
    _ExportOption(
      format: ExportFormat.markdown,
      title: 'Markdown',
      subtitle: 'ملف Markdown قابل للتحرير',
      icon: Icons.article_outlined,
      color: AppColors.exportMarkdown,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تصدير الملاحظة', style: TextStyle(fontFamily: 'Cairo')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // معلومات الملاحظة
          _buildNoteInfo(),
          // خيارات التصدير
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'اختر صيغة التصدير',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                ..._options.map((opt) => _buildExportCard(opt)),
                const SizedBox(height: 16),
                // تصدير CSV لجميع الملاحظات
                _buildBulkExportCard(),
              ],
            ),
          ),
          // نتيجة التصدير
          if (_exportedFilePath != null) _buildExportResult(),
        ],
      ),
    );
  }

  Widget _buildNoteInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.note.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(widget.note.createdAt)} • ${widget.note.category ?? "عام"}',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard(_ExportOption option) {
    final isActive = _activeFormat == option.format;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isExporting ? null : () => _export(option.format),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? option.color.withOpacity(0.12) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? option.color : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: option.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isActive && _isExporting
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: option.color,
                          ),
                        )
                      : Icon(option.icon, color: option.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isActive ? option.color : null,
                        ),
                      ),
                      Text(
                        option.subtitle,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.file_download_outlined,
                  color: isActive ? option.color : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulkExportCard() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          'تصدير جميع الملاحظات',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSmallExportBtn(
                label: 'CSV',
                icon: Icons.table_chart_outlined,
                color: AppColors.exportCsv,
                onTap: _exportAllCsv,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallExportBtn(
                label: 'ZIP',
                icon: Icons.folder_zip_outlined,
                color: AppColors.exportZip,
                onTap: _exportAllZip,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallExportBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isExporting ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportResult() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'تم التصدير بنجاح',
              style: TextStyle(fontFamily: 'Tajawal', color: Colors.green, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              ExportService.instance.shareFile(_exportedFilePath!);
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text('مشاركة', style: TextStyle(fontFamily: 'Tajawal')),
          ),
        ],
      ),
    );
  }

  Future<void> _export(ExportFormat format) async {
    setState(() {
      _isExporting = true;
      _activeFormat = format;
      _exportedFilePath = null;
    });

    try {
      String filePath;
      switch (format) {
        case ExportFormat.pdf:
          filePath = await ExportService.instance.exportToPdf(widget.note);
          break;
        case ExportFormat.txt:
          filePath = await ExportService.instance.exportToTxt(widget.note);
          break;
        case ExportFormat.json:
          filePath = await ExportService.instance.exportToJson(widget.note);
          break;
        case ExportFormat.html:
          filePath = await ExportService.instance.exportToHtml(widget.note);
          break;
        case ExportFormat.markdown:
          filePath = await ExportService.instance.exportToMarkdown(widget.note);
          break;
        default:
          return;
      }

      setState(() => _exportedFilePath = filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التصدير: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportAllCsv() async {
    setState(() => _isExporting = true);
    try {
      final provider = Provider.of<NoteProvider>(context, listen: false);
      final filePath = await ExportService.instance.exportToCsv(provider.allNotes);
      setState(() => _exportedFilePath = filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التصدير: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportAllZip() async {
    setState(() => _isExporting = true);
    try {
      final provider = Provider.of<NoteProvider>(context, listen: false);
      final filePath = await ExportService.instance.exportToZip(provider.allNotes);
      setState(() => _exportedFilePath = filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التصدير: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ExportOption {
  final ExportFormat format;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ExportOption({
    required this.format,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
