import 'package:flutter/material.dart';
import 'package:serat/shared/constants/app_colors.dart';

class HadithFilterChips extends StatelessWidget {
  final Map<String, String> books;
  final String selectedBook;
  final String selectedFilter;
  final bool isLoadingRandom;
  final bool isDarkMode;
  final Function(String) onBookSelected;
  final Function(String) onFilterSelected;

  const HadithFilterChips({
    super.key,
    required this.books,
    required this.selectedBook,
    required this.selectedFilter,
    required this.isLoadingRandom,
    required this.isDarkMode,
    required this.onBookSelected,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            "اختر الكتاب",
            style: TextStyle(
              fontFamily: "Cairo",
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        _buildBookChips(),
        const SizedBox(height: 16),
        _buildFilterSegments(),
      ],
    );
  }

  Widget _buildBookChips() {
    return Container(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books.keys.elementAt(index);
          final isSelected = book == selectedBook;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              selected: isSelected,
              label: Text(
                book,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.white70 : Colors.black87),
                ),
              ),
              backgroundColor:
                  isDarkMode ? const Color(0xff2A2A2A) : Colors.white,
              selectedColor: AppColors.primaryColor,
              elevation: 0,
              pressElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryColor
                      : (isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05)),
                ),
              ),
              onSelected: (_) => onBookSelected(book),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSegments() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          _buildFilterSegment(
              'الكل', selectedFilter == 'الكل', () => onFilterSelected('الكل')),
          _buildFilterSegment('المحفوظات', selectedFilter == 'المحفوظات',
              () => onFilterSelected('المحفوظات')),
          _buildFilterSegment(
            'عشوائي',
            selectedFilter == 'عشوائي',
            () => onFilterSelected('عشوائي'),
            isLoading: isLoadingRandom,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSegment(String label, bool isSelected, VoidCallback onTap,
      {bool isLoading = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDarkMode ? Colors.white60 : Colors.black54),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
