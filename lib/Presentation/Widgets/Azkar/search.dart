import 'package:flutter/material.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';
import 'package:serat/Presentation/Widgets/Shared/azkar_category_card.dart';

class AzkarSearchDelegate extends SearchDelegate {
  final List<AzkarScreenItem> azkarItems;

  AzkarSearchDelegate(this.azkarItems);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [_buildClearAction(context)];
  }

  @override
  Widget buildLeading(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredItems = _filterItems();
    return _buildItemList(filteredItems, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredItems = _filterItems();
    return _buildItemList(filteredItems, context);
  }

  List<AzkarScreenItem> _filterItems() {
    final lowerCaseQuery = query.toLowerCase();
    return azkarItems.where((item) {
      return item.title.toLowerCase().contains(lowerCaseQuery);
    }).toList();
  }

  Widget _buildItemList(List<AzkarScreenItem> items, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildListTile(context, item, isDarkMode);
        },
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    AzkarScreenItem item,
    bool isDarkMode,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13.0,
          vertical: 8.0,
        ),
        leading: Icon(
          item.icon,
          color: isDarkMode ? Colors.white : AppColors.primaryColor,
        ),
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            item.title,
            style: TextStyle(
              fontFamily: 'DIN',
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
            ),
          ),
        ),
        onTap: () {
          _navigateToScreen(context, item.screen);
        },
      ),
    );
  }

  Widget _buildClearAction(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      alignment: Alignment.centerRight,
      icon: const Icon(Icons.clear),
      color: isDarkMode ? Colors.white : Colors.black,
      onPressed: () => query = '',
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }
}
