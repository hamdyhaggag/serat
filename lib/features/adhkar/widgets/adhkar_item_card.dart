import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serat/features/adhkar/models/adhkar_category.dart';

/// A reusable card widget for displaying an Adhkar item.
/// Supports both vertical (list) and horizontal layouts, and can be used for sharing (read-only).
class AdhkarItemCard extends StatelessWidget {
  final int index;
  final AdhkarItem item;
  final int currentProgress;
  final bool isCompleted;
  final bool isCurrentItem;
  final double textScale;
  final bool isHorizontal;
  final bool forShare;
  final VoidCallback? onTap;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onComplete;

  const AdhkarItemCard({
    super.key,
    required this.index,
    required this.item,
    required this.currentProgress,
    required this.isCompleted,
    required this.isCurrentItem,
    required this.textScale,
    this.isHorizontal = false,
    this.forShare = false,
    this.onTap,
    this.onCopy,
    this.onShare,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardPadding = isHorizontal
        ? EdgeInsets.all(14 + (textScale - 28) * 0.4)
        : EdgeInsets.all(16 + (textScale - 28) * 0.6);
    final iconSize = isHorizontal ? 14 + (textScale - 28) * 0.2 : 20.0;
    final iconPadding = isHorizontal ? 5 + (textScale - 28) * 0.1 : 8.0;
    final borderRadius = isHorizontal ? 6.0 : 8.0;
    final progressBarRadius = isHorizontal ? 3.0 : 4.0;
    final progressBarHeight = isHorizontal ? 3 + (textScale - 28) * 0.08 : 6.0;
    final textFontSize =
        isHorizontal ? (textScale - 28) * 0.5 + 16 : textScale * 0.6;
    final labelFontSize =
        isHorizontal ? (textScale - 28) * 0.25 + 15 : textScale * 0.7;
    final countFontSize =
        isHorizontal ? (textScale - 28) * 0.15 + 15 : textScale * 0.8;
    final buttonFontSize =
        isHorizontal ? (textScale - 28) * 0.15 + 16 : textScale * 0.6;
    final buttonPadding = isHorizontal
        ? EdgeInsets.symmetric(vertical: 5 + (textScale - 28) * 0.15)
        : EdgeInsets.symmetric(vertical: 8 + (textScale - 28) * 0.4);
    final cardColor =
        isCurrentItem ? theme.primaryColor.withOpacity(0.1) : theme.cardColor;
    final cardBorder = isCurrentItem
        ? BorderSide(color: theme.primaryColor, width: 2)
        : BorderSide.none;
    final cardElevation = isCurrentItem ? 8.0 : 4.0;

    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: isHorizontal ? MainAxisSize.max : MainAxisSize.min,
      children: [
        // Header row
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withOpacity(0.1)
                    : theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.format_list_numbered,
                size: iconSize,
                color: isCompleted ? Colors.green : theme.primaryColor,
              ),
            ),
            SizedBox(width: isHorizontal ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الذِكر رقم ${index + 1}',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '$currentProgress/${item.count}',
                    style: TextStyle(
                      fontSize: countFontSize,
                      color: isCompleted ? Colors.green : theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (!forShare) ...[
              IconButton(
                icon: const Icon(Icons.copy_all_outlined),
                iconSize: isHorizontal ? 18 : 22,
                tooltip: 'نسخ الذكر',
                onPressed: onCopy,
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                iconSize: isHorizontal ? 18 : 22,
                tooltip: 'مشاركة الذكر',
                onPressed: onShare,
              ),
            ],
          ],
        ),
        SizedBox(
            height: isHorizontal
                ? 6 + (textScale - 28) * 0.15
                : 12 + (textScale - 28) * 0.4),
        // Progress bar
        LinearProgressIndicator(
          value: item.count > 0 ? currentProgress / item.count : 0.0,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            isCompleted ? Colors.green : theme.primaryColor,
          ),
          borderRadius: BorderRadius.circular(progressBarRadius),
          minHeight: progressBarHeight,
        ),
        SizedBox(height: isHorizontal ? 6 + (textScale - 28) * 0.15 : 12),
        // Adhkar text
        isHorizontal
            ? Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    item.text,
                    style: TextStyle(
                      fontSize: textFontSize,
                      color: theme.colorScheme.onSurface.withOpacity(0.9),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: null,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.justify,
                  ),
                ),
              )
            : Text(
                item.text,
                style: TextStyle(
                  fontSize: textFontSize,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                  fontFamily: "Cairo",
                ),
                maxLines: null,
                overflow: TextOverflow.visible,
              ),
        SizedBox(height: isHorizontal ? 6 + (textScale - 28) * 0.15 : 8),
        if (!forShare)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCompleted ? null : onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCompleted ? Colors.green : theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: buttonPadding,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: isCompleted ? 0 : (isHorizontal ? 1 : 2),
              ),
              child: Text(
                isCompleted ? 'مكتمل' : 'إكمال',
                style: TextStyle(
                    fontSize: buttonFontSize, fontWeight: FontWeight.w500),
              ),
            ),
          ),
      ],
    );

    return GestureDetector(
      onTap: forShare ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: cardElevation,
          shadowColor: theme.primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: cardBorder,
          ),
          color: cardColor,
          child: Padding(
            padding: cardPadding,
            child: isHorizontal
                ? SizedBox(
                    height: double.infinity,
                    child: cardContent,
                  )
                : cardContent,
          ),
        ),
      ),
    );
  }
}
