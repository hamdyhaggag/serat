import 'package:flutter/material.dart';
import 'package:serat/imports.dart';

class ActionButtonWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDarkMode;

  const ActionButtonWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 24),
              const SizedBox(height: 8),
              AppText(
                title,
                fontSize: 12,
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
                align: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
