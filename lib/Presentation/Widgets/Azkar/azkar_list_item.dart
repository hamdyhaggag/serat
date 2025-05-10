import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class AzkarListItem extends StatelessWidget {
  final AzkarItem item;
  final int index;
  final VoidCallback? onDelete;

  const AzkarListItem({
    super.key,
    required this.item,
    required this.index,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
        margin: EdgeInsets.symmetric(vertical: 15.0.h),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          title: Text(
            item.text,
            textAlign: TextAlign.right,
            style: _textStyle(
              isDarkMode,
              fontSize: 21.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            item.reward,
            textAlign: TextAlign.right,
            style: _textStyle(isDarkMode, fontSize: 16.sp),
          ),
          trailing: _buildTrailing(isDarkMode),
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
        ),
      ),
    );
  }

  Widget _buildTrailing(bool isDarkMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${item.count}',
          textAlign: TextAlign.left,
          style: _textStyle(isDarkMode, fontSize: 22.sp),
        ),
        SizedBox(width: 26.w),
        Text(
          'مرة',
          textAlign: TextAlign.left,
          style: _textStyle(isDarkMode, fontSize: 18.sp),
        ),
      ],
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
