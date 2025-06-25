import 'package:flutter/material.dart';
import 'package:serat/features/adhkar/models/adhkar_category.dart';

class AdhkarSearchWidget extends StatefulWidget {
  final List<AdhkarCategory> allCategories;
  final Function(List<AdhkarCategory>) onSearchResults;

  const AdhkarSearchWidget({
    super.key,
    required this.allCategories,
    required this.onSearchResults,
  });

  @override
  State<AdhkarSearchWidget> createState() => _AdhkarSearchWidgetState();
}

class _AdhkarSearchWidgetState extends State<AdhkarSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<AdhkarCategory> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Responsive helper methods
  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSize * 0.8;
    if (width < 600) return baseSize;
    if (width < 900) return baseSize * 1.1;
    return baseSize * 1.2;
  }

  double _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;
    if (width < 600) return 16.0;
    if (width < 900) return 20.0;
    return 24.0;
  }

  double _getResponsiveBorderRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;
    if (width < 600) return 16.0;
    if (width < 900) return 20.0;
    return 24.0;
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      widget.onSearchResults(widget.allCategories);
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = widget.allCategories.where((category) {
        return category.category.toLowerCase().contains(query.toLowerCase()) ||
            category.array.any((item) =>
                item.text.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });

    widget.onSearchResults(_searchResults);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = _isSmallScreen(context);

    return Container(
      padding: EdgeInsets.all(_getResponsivePadding(context)),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(_getResponsiveBorderRadius(context)),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: isSmallScreen ? 8 : 10,
                  offset: Offset(0, isSmallScreen ? 3 : 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'البحث في الأذكار...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: _getResponsiveFontSize(context, 16),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: isSmallScreen ? 20 : 24,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          size: isSmallScreen ? 20 : 24,
                        ),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: _getResponsivePadding(context),
                  vertical: isSmallScreen ? 10 : 12,
                ),
              ),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: _getResponsiveFontSize(context, 16),
              ),
            ),
          ),

          // Search results info
          if (_isSearching) ...[
            SizedBox(height: isSmallScreen ? 8 : 12),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: _getResponsivePadding(context),
                vertical: isSmallScreen ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: isSmallScreen ? 14 : 16,
                    color: theme.primaryColor,
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Text(
                    'تم العثور على ${_searchResults.length} نتيجة',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 12),
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AdhkarFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const AdhkarFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  // Responsive helper methods
  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSize * 0.8;
    if (width < 600) return baseSize;
    if (width < 900) return baseSize * 1.1;
    return baseSize * 1.2;
  }

  double _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;
    if (width < 600) return 16.0;
    if (width < 900) return 20.0;
    return 24.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = _isSmallScreen(context);
    final filters = [
      {'key': 'all', 'label': 'الكل'},
      {'key': 'completed', 'label': 'مكتمل'},
      {'key': 'in_progress', 'label': 'قيد التقدم'},
      {'key': 'not_started', 'label': 'لم يبدأ'},
    ];

    return Container(
      height: isSmallScreen ? 45 : 50,
      padding: EdgeInsets.symmetric(horizontal: _getResponsivePadding(context)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['key'];

          return Container(
            margin: EdgeInsets.only(right: isSmallScreen ? 6 : 8),
            child: FilterChip(
              label: Text(
                filter['label']!,
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: _getResponsiveFontSize(context, 14),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                onFilterChanged(filter['key']!);
              },
              backgroundColor: theme.cardColor,
              selectedColor: theme.primaryColor,
              checkmarkColor: theme.colorScheme.onPrimary,
              side: BorderSide(
                color: isSelected
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface.withOpacity(0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 4 : 6,
              ),
            ),
          );
        },
      ),
    );
  }
}
