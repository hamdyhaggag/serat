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
      children: [
        _buildBookChips(),
        _buildFilterSegments(),
      ],
    );
  }

  Widget _buildBookChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books.keys.elementAt(index);
          final isSelected = book == selectedBook;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                book,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isDarkMode
                          ? Colors.white70
                          : Colors.black87,
                  fontFamily: 'DIN',
                ),
              ),
              backgroundColor:
                  isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
              selectedColor: AppColors.primaryColor,
              onSelected: (_) => onBookSelected(book),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSegments() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildFilterSegment(
            'الكل',
            selectedFilter == 'الكل',
            () => onFilterSelected('الكل'),
          ),
          _buildFilterSegment(
            'المحفوظات',
            selectedFilter == 'المحفوظات',
            () => onFilterSelected('المحفوظات'),
          ),
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

  Widget _buildFilterSegment(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    bool isLoading = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
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
                      color: isSelected
                          ? Colors.white
                          : isDarkMode
                              ? Colors.white70
                              : Colors.black87,
                      fontFamily: 'DIN',
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
