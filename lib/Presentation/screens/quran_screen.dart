import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/quran_cubit.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import 'package:serat/Core/widgets/app_text.dart';
import 'package:serat/Presentation/screens/quran_chapter_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<QuranChapter> _filteredChapters = [];

  @override
  void initState() {
    super.initState();
    context.read<QuranCubit>().getChapters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterChapters(String query, List<QuranChapter> chapters) {
    setState(() {
      _filteredChapters =
          chapters.where((chapter) {
            final nameLower = chapter.name.toLowerCase();
            final englishNameLower = chapter.englishName.toLowerCase();
            final translationLower =
                chapter.englishNameTranslation.toLowerCase();
            final searchLower = query.toLowerCase();

            return nameLower.contains(searchLower) ||
                englishNameLower.contains(searchLower) ||
                translationLower.contains(searchLower);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor =
        isDarkMode
            ? Colors.grey[400] ?? Colors.grey
            : Colors.grey[600] ?? Colors.grey;
    final cardColor =
        isDarkMode ? Colors.grey[900] ?? Colors.grey[800]! : Colors.white;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? Colors.grey[900] : Theme.of(context).primaryColor,
        title: const AppText(
          'القرآن الكريم',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: QuranSearchDelegate(
                  chapters: _filteredChapters,
                  onFilter: _filterChapters,
                  isDarkMode: isDarkMode,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          } else if (state is QuranError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    'حدث خطأ: ${state.message}',
                    color: Colors.red,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuranCubit>().getChapters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const AppText('إعادة المحاولة', fontFamily: 'Cairo'),
                  ),
                ],
              ),
            );
          } else if (state is QuranLoaded) {
            _filteredChapters = state.chapters;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredChapters.length,
              itemBuilder: (context, index) {
                final chapter = _filteredChapters[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 24,
                      child: AppText(
                        chapter.number.toString(),
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    title: AppText(
                      chapter.name,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontFamily: 'Cairo',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        AppText(
                          '${chapter.englishName} - ${chapter.englishNameTranslation}',
                          fontSize: 14,
                          color: subtitleColor ?? Colors.grey,
                          fontFamily: 'Cairo',
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          '${chapter.versesCount} آية',
                          fontSize: 14,
                          color: subtitleColor ?? Colors.grey,
                          fontFamily: 'Cairo',
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => QuranChapterScreen(chapter: chapter),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class QuranSearchDelegate extends SearchDelegate {
  final List<QuranChapter> chapters;
  final Function(String, List<QuranChapter>) onFilter;
  final bool isDarkMode;

  QuranSearchDelegate({
    required this.chapters,
    required this.onFilter,
    required this.isDarkMode,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? Colors.grey[900] : theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onFilter(query, chapters);
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onFilter(query, chapters);
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor =
        isDarkMode
            ? Colors.grey[400] ?? Colors.grey
            : Colors.grey[600] ?? Colors.grey;
    final cardColor =
        isDarkMode ? Colors.grey[900] ?? Colors.grey[800]! : Colors.white;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 24,
              child: AppText(
                chapter.number.toString(),
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            title: AppText(
              chapter.name,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'Cairo',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                AppText(
                  '${chapter.englishName} - ${chapter.englishNameTranslation}',
                  fontSize: 14,
                  color: subtitleColor ?? Colors.grey,
                  fontFamily: 'Cairo',
                ),
                const SizedBox(height: 4),
                AppText(
                  '${chapter.versesCount} آية',
                  fontSize: 14,
                  color: subtitleColor ?? Colors.grey,
                  fontFamily: 'Cairo',
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuranChapterScreen(chapter: chapter),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
