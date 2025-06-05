import 'package:flutter/material.dart';

import 'package:serat/imports.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.isHome = false,
    this.actions,
  });
  final String title;
  final bool isHome;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.RTL;

    return AppBar(
      backgroundColor: isDarkMode ? Colors.transparent : Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment:
            isHome ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (!isHome) ...[
            IconButton(
              onPressed: () {
                Navigator.canPop(context) == true
                    ? Navigator.pop(context)
                    : () {};
              },
              icon: Icon(
                isRTL
                    ? FontAwesomeIcons.chevronRight
                    : FontAwesomeIcons.chevronRight,
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
              ),
            ),
            SizedBox(width: 5.w),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 23,
              fontFamily: 'DIN',
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
            ),
          ),
        ],
      ),
      leadingWidth: 0.0,
      leading: const SizedBox(),
      actions: actions,
    );
  }
}
