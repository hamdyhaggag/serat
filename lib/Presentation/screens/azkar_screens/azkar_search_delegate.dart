import 'package:flutter/material.dart';
import 'package:serat/Data/models/azkar_model.dart';

class AzkarSearchDelegate extends SearchDelegate<Zikr?> {
  final List<AzkarModel> azkarList;

  AzkarSearchDelegate(this.azkarList);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('اكتب للبحث عن ذكر'),
      );
    }

    final results = <Zikr>[];
    for (var azkar in azkarList) {
      for (var zikr in azkar.array) {
        if (zikr.text.contains(query)) {
          results.add(zikr);
        }
      }
    }

    if (results.isEmpty) {
      return const Center(
        child: Text('لا توجد نتائج'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final zikr = results[index];
        return ListTile(
          title: Text(zikr.text),
          subtitle: Text('عدد المرات: ${zikr.count}'),
          onTap: () {
            close(context, zikr);
          },
        );
      },
    );
  }
}
