import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:serat/Presentation/Widgets/Azkar/azkar_item.dart';

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
      background: Container(color: Colors.red),
      confirmDismiss:
          (direction) => _confirmDismiss(context, item, direction, isDarkMode),
      onDismissed: (direction) {
        if (!item.isDefault && onDelete != null) {
          onDelete!();
        }
      },
      child: Card(
        color: isDarkMode ? Colors.black12 : Colors.grey.shade100,
        margin: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.015,
          horizontal: screenSize.width * 0.02,
        ),
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.02),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => Sebha(
                        title: item.text,
                        subtitle: item.reward,
                        beadCount: item.count,
                        maxCounter: item.count,
                      ),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.text,
                        textAlign: TextAlign.right,
                        style: _textStyle(
                          isDarkMode,
                          fontSize: screenSize.width * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.008),
                      Text(
                        item.reward,
                        textAlign: TextAlign.right,
                        style: _textStyle(
                          isDarkMode,
                          fontSize: screenSize.width * 0.035,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: screenSize.width * 0.02),
                _buildTrailing(isDarkMode, screenSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing(bool isDarkMode, Size screenSize) {
    return Container(
      constraints: BoxConstraints(
        minWidth: screenSize.width * 0.15,
        maxWidth: screenSize.width * 0.2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${item.count}',
            textAlign: TextAlign.center,
            style: _textStyle(isDarkMode, fontSize: screenSize.width * 0.045),
          ),
          SizedBox(height: screenSize.height * 0.004),
          Text(
            'مرة',
            textAlign: TextAlign.center,
            style: _textStyle(isDarkMode, fontSize: screenSize.width * 0.035),
          ),
        ],
      ),
    );
  }

  TextStyle _textStyle(
    bool isDarkMode, {
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: 'DIN',
      color: isDarkMode ? Colors.white : AppColors.primaryColor,
      fontWeight: fontWeight,
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
      builder:
          (context) => AlertDialog(
            title: Text(
              'تأكيد الحذف',
              textAlign: TextAlign.center,
              style: _dialogTextStyle(isDarkMode),
            ),
            content: Text(
              'هل أنت متأكد أنك تريد حذف هذا الذكر؟',
              textAlign: TextAlign.center,
              style: _dialogTextStyle(isDarkMode),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('إلغاء', style: _dialogTextStyle(isDarkMode)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('حذف', style: _dialogTextStyle(isDarkMode)),
              ),
            ],
          ),
    );
  }

  TextStyle _dialogTextStyle(bool isDarkMode) {
    return TextStyle(
      fontFamily: 'DIN',
      fontSize: 16.sp,
      color: isDarkMode ? Colors.white : AppColors.primaryColor,
    );
  }
}
