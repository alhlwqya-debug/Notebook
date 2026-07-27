import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';
import '../screens/export/export_screen.dart';

class AnimatedNoteCard extends StatefulWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final int index;
  final bool isListView;

  const AnimatedNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.index,
    this.isListView = false,
  });

  @override
  State<AnimatedNoteCard> createState() => _AnimatedNoteCardState();
}

class _AnimatedNoteCardState extends State<AnimatedNoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 50).clamp(0, 500)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 40), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: NoteCard(
            note: widget.note,
            onTap: widget.onTap,
            isListView: widget.isListView,
          ),
        ),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final bool isListView;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.isListView = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.noteColorsDark : AppColors.noteColors;
    final bgColor = note.colorIndex < colors.length ? colors[note.colorIndex] : colors[0];

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isListView ? _buildListLayout(context) : _buildGridLayout(context),
      ),
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شارات الملاحظة
          if (note.isPinned || note.isFavorite || note.isPasswordProtected)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 4,
                children: [
                  if (note.isPinned) _buildBadge(Icons.push_pin, AppColors.primary),
                  if (note.isFavorite) _buildBadge(Icons.favorite, AppColors.secondary),
                  if (note.isPasswordProtected) _buildBadge(Icons.lock, Colors.orange),
                ],
              ),
            ),
          // العنوان
          Text(
            note.title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // المحتوى
          if (!note.isPasswordProtected)
            Text(
              note.contentPreview,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            )
          else
            Text(
              '🔒 محمية بكلمة مرور',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                color: Colors.orange.shade700,
              ),
            ),
          const SizedBox(height: 10),
          // الوسوم
          if (note.tags.isNotEmpty)
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: note.tags.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 8),
          // التذييل
          Row(
            children: [
              if (note.category != null)
                Expanded(
                  child: Text(
                    note.category!,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      color: AppColors.primary.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Text(
                _formatDate(note.updatedAt),
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // لون جانبي
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.categoryColors[note.colorIndex % AppColors.categoryColors.length],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (note.isPinned) const Icon(Icons.push_pin, size: 14, color: AppColors.primary),
                        if (note.isFavorite) const Icon(Icons.favorite, size: 14, color: AppColors.secondary),
                        if (note.isPasswordProtected) const Icon(Icons.lock, size: 14, color: Colors.orange),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (!note.isPasswordProtected)
                  Text(
                    note.contentPreview,
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (note.category != null) ...[
                      Text(
                        note.category!,
                        style: const TextStyle(fontSize: 11, color: AppColors.primary, fontFamily: 'Tajawal'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _formatDate(note.updatedAt),
                      style: TextStyle(fontSize: 11, fontFamily: 'Tajawal', color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }

  void _showContextMenu(BuildContext context) {
    final provider = Provider.of<NoteProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                note.title,
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: AppColors.primary),
              title: Text(note.isPinned ? 'إلغاء التثبيت' : 'تثبيت',
                  style: const TextStyle(fontFamily: 'Tajawal')),
              onTap: () {
                Navigator.pop(context);
                provider.togglePin(note);
              },
            ),
            ListTile(
              leading: Icon(note.isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: AppColors.secondary),
              title: Text(note.isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                  style: const TextStyle(fontFamily: 'Tajawal')),
              onTap: () {
                Navigator.pop(context);
                provider.toggleFavorite(note);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload_outlined, color: AppColors.primary),
              title: const Text('تصدير', style: TextStyle(fontFamily: 'Tajawal')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ExportScreen(note: note)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: Colors.orange),
              title: Text(note.isArchived ? 'إلغاء الأرشفة' : 'أرشفة',
                  style: const TextStyle(fontFamily: 'Tajawal')),
              onTap: () {
                Navigator.pop(context);
                provider.toggleArchive(note);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('حذف', style: TextStyle(fontFamily: 'Tajawal', color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, NoteProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الملاحظة', style: TextStyle(fontFamily: 'Cairo')),
        content: Text('هل تريد حذف "${note.title}" نهائياً؟',
            style: const TextStyle(fontFamily: 'Tajawal')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              provider.deleteNote(note.id!);
            },
            child: const Text('حذف', style: TextStyle(fontFamily: 'Tajawal')),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${date.day}/${date.month}/${date.year}';
  }
}
