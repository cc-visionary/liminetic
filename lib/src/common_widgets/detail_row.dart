// lib/src/common_widgets/detail_row.dart

import 'package:flutter/material.dart';

/// A universal, reusable widget for displaying a single piece of information
/// in a detail screen, featuring a leading icon, a title (label), and the content.
class DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const DetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The title/label for the data.
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 2),
                // The actual content.
                Text(content, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
