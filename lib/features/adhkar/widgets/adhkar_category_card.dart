import 'package:flutter/material.dart';
import 'package:serat/features/adhkar/models/adhkar_category.dart';

class AdhkarCategoryCard extends StatelessWidget {
  final AdhkarCategory category;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final double progress;

  const AdhkarCategoryCard({
    super.key,
    required this.category,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = progress >= 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: isSelected ? 8.0 : 4.0,
        shadowColor: theme.primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isSelected
              ? BorderSide(color: theme.primaryColor, width: 2)
              : BorderSide.none,
        ),
        color:
            isSelected ? theme.primaryColor.withOpacity(0.1) : theme.cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon without progress ring
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : icon,
                    size: 24,
                    color: isCompleted ? Colors.green : theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Category name
                Text(
                  category.category,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Item count
                Text(
                  '${category.array.length} ذِكر',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdhkarCategoryHorizontalCard extends StatelessWidget {
  final AdhkarCategory category;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final double progress;

  const AdhkarCategoryHorizontalCard({
    super.key,
    required this.category,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = progress >= 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: isSelected ? 6.0 : 3.0,
        shadowColor: theme.primaryColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected
              ? BorderSide(color: theme.primaryColor, width: 2)
              : BorderSide.none,
        ),
        color:
            isSelected ? theme.primaryColor.withOpacity(0.1) : theme.cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon without progress
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : icon,
                    size: 24,
                    color: isCompleted ? Colors.green : theme.primaryColor,
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.category,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.array.length} أذكار',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
