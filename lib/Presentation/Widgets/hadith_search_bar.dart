import 'package:flutter/material.dart';

class HadithSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final bool isDarkMode;
  final int resultCount;
  final bool isSearching;

  const HadithSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.isDarkMode,
    this.resultCount = 0,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن حديث...',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                      fontFamily: 'DIN',
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                    suffixIcon:
                        controller.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color:
                                    isDarkMode
                                        ? Colors.white54
                                        : Colors.black54,
                              ),
                              onPressed: () {
                                controller.clear();
                                onChanged('');
                              },
                            )
                            : null,
                    filled: true,
                    fillColor:
                        isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'DIN',
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          if (controller.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isSearching)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    '${resultCount} نتيجة',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontFamily: 'DIN',
                      fontSize: 14,
                    ),
                  ),
                if (resultCount > 0)
                  Text(
                    'تم العثور على ${resultCount} حديث',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontFamily: 'DIN',
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
