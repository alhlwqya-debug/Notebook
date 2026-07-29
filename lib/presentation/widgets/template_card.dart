import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/template.dart';

class TemplateCard extends StatelessWidget {
  final Template template;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = template.color != null ? Color(template.color!) : AppColors.primary;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.library_books, color: color, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    template.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (template.description != null && template.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      template.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  if (template.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'جاهز',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ),
            if (onDelete != null)
              Positioned(
                top: 4,
                left: 4,
                child: GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
