import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/quran_cubit.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import 'package:serat/Core/widgets/app_text.dart';
import 'package:serat/Core/utils/app_colors.dart';
import 'package:serat/Presentation/screens/quran_chapter_screen.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final TextEditingController _searchController = TextEditingController();

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
      appBar: CustomAppBar(title: 'القرآن الكريم', isHome: false),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final state = context.read<QuranCubit>().state;
          if (state is QuranLoaded) {
            showSearch(
              context: context,
              delegate: QuranSearchDelegate(
                chapters: state.chapters,
                onFilter:
                    (
                      _,
                      __,
                    ) {}, // Empty callback since we handle filtering in the delegate
                isDarkMode: isDarkMode,
              ),
            );
          }
        },
        backgroundColor: isDarkMode ? Colors.grey[900] : AppColors.primaryColor,
        child: Icon(
          Icons.search,
          color: isDarkMode ? Colors.white : Colors.white,
        ),
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
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.chapters.length,
              itemBuilder: (context, index) {
                final chapter = state.chapters[index];
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
  List<QuranChapter> _filteredChapters = [];

  QuranSearchDelegate({
    required this.chapters,
    required this.onFilter,
    required this.isDarkMode,
  }) {
    _filteredChapters = chapters;
  }

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
    _filterChapters(query);
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _filterChapters(query);
    return _buildSearchResults(context);
  }

  void _filterChapters(String query) {
    _filteredChapters =
        chapters.where((chapter) {
          final nameLower = chapter.name.toLowerCase();
          final englishNameLower = chapter.englishName.toLowerCase();
          final translationLower = chapter.englishNameTranslation.toLowerCase();
          final searchLower = query.toLowerCase();

          return nameLower.contains(searchLower) ||
              englishNameLower.contains(searchLower) ||
              translationLower.contains(searchLower);
        }).toList();
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
