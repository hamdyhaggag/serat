class FilterState {
  final String selectedFilter;
  final String selectedBook;
  final bool isLoadingRandom;
  final bool isLoadingBookmarks;
  final bool isLoadingBooks;

  const FilterState({
    this.selectedFilter = 'الكل',
    this.selectedBook = 'الأربعين النووية',
    this.isLoadingRandom = false,
    this.isLoadingBookmarks = false,
    this.isLoadingBooks = false,
  });

  FilterState copyWith({
    String? selectedFilter,
    String? selectedBook,
    bool? isLoadingRandom,
    bool? isLoadingBookmarks,
    bool? isLoadingBooks,
  }) {
    return FilterState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedBook: selectedBook ?? this.selectedBook,
      isLoadingRandom: isLoadingRandom ?? this.isLoadingRandom,
      isLoadingBookmarks: isLoadingBookmarks ?? this.isLoadingBookmarks,
      isLoadingBooks: isLoadingBooks ?? this.isLoadingBooks,
    );
  }
}
