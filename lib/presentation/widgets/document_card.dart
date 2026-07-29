import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/document.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  final bool isGrid;
  final Widget? trailing;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    this.isGrid = false,
    this.trailing,
  });

  Color _typeColor() {
    switch (document.typeId) {
      case 1: return AppColors.noteColor;
      case 2: return AppColors.notebookColor;
      case 3: return AppColors.lectureColor;
      case 4: return AppColors.reportColor;
      case 5: return AppColors.invoiceColor;
      case 6: return AppColors.contractColor;
      case 7: return AppColors.bookColor;
      case 8: return AppColors.codeColor;
      default: return AppColors.primary;
    }
  }

  IconData _typeIcon() {
    switch (document.typeId) {
      case 1: return Icons.note;
      case 2: return Icons.menu_book;
      case 3: return Icons.school;
      case 4: return Icons.assessment;
      case 5: return Icons.receipt;
      case 6: return Icons.description;
      case 7: return Icons.import_contacts;
      case 8: return Icons.code;
      default: return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isGrid ? _buildGrid(context) : _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final color = document.color != null ? Color(document.color!) : _typeColor();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Color indicator + icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_typeIcon(), color: color, size: 22),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            document.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (document.isFavorite)
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (document.content.isNotEmpty)
                      Text(
                        document.content.replaceAll('\n', ' '),
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (document.typeName != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              document.typeName!,
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: color),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          AppDateUtils.formatRelative(document.updatedAt),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        if (document.wordCount > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${document.wordCount} كلمة',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final color = document.color != null ? Color(document.color!) : _typeColor();
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_typeIcon(), color: color, size: 20),
                  ),
                  if (document.isFavorite)
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                document.title,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                AppDateUtils.formatRelative(document.updatedAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
