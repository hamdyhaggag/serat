import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:serat/Presentation/Widgets/Azkar/azkar_item.dart';
import 'package:serat/Presentation/theme/app_theme.dart';
import 'package:serat/Presentation/screens/azkar_screens/sebha_screen.dart';

class SebhaListItem extends StatelessWidget {
  final AzkarItem item;
  final int index;
  final VoidCallback? onDelete;

  const SebhaListItem({
    super.key,
    required this.item,
    required this.index,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Dismissible(
      key: Key(item.text),
      background: Container(
        margin: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.01,
          horizontal: screenSize.width * 0.04,
        ),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) =>
          _confirmDismiss(context, item, direction, isDarkMode),
      onDismissed: (direction) {
        if (!item.isDefault && onDelete != null) {
          onDelete!();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.01,
          horizontal: screenSize.width * 0.04,
        ),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xff2C2C2C).withOpacity(0.6)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Sebha(
                      title: item.text,
                      subtitle: item.reward,
                      beadCount: item.count,
                      maxCounter: item.count,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon/Identifier
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppTheme.primaryLight.withOpacity(0.1)
                            : AppTheme.primaryLight.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isDarkMode
                                ? AppTheme.primaryLight
                                : AppTheme.primaryLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'DIN',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.text,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Cairo', // Use Cairo for premium feel
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                              height: 1.3,
                            ),
                          ),
                          if (item.reward.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              item.reward,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'DIN',
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.count}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDismiss(
    BuildContext context,
    AzkarItem item,
    DismissDirection direction,
    bool isDarkMode,
  ) {
    if (item.isDefault || direction != DismissDirection.endToStart) {
      return Future.value(false);
    }

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        title: Text(
          'تأكيد الحذف',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'هل أنت متأكد أنك تريد حذف هذا الذكر؟',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DIN',
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
