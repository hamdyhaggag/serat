import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:serat/Features/NamesOfAllah/Data/Model/names_of_allah_model.dart';
import 'package:serat/Features/NamesOfAllah/Data/Model/text_scale_model.dart';

class NameCard extends StatelessWidget {
  final NamesOfAllahModel name;
  final TextScaleModel textScale;
  final VoidCallback onTap;

  const NameCard({
    super.key,
    required this.name,
    required this.textScale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xff2F2F2F),
                    const Color(0xff252525),
                  ]
                : [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.name,
                style: TextStyle(
                  fontSize: textScale.nameScale,
                  fontFamily: 'Amiri',
                  color: isDarkMode ? Colors.white : AppColors.primaryColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              Text(
                name.text,
                style: TextStyle(
                  fontSize: textScale.descriptionScale,
                  fontFamily: 'DIN',
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
