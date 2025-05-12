import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/quran_cubit.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import 'package:serat/Core/utils/app_colors.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          'القرآن الكريم',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: QuranSearchDelegate(
                  chapters: _filteredChapters,
                  onFilter: _filterChapters,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuranError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText('حدث خطأ: ${state.message}', color: Colors.red),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuranCubit>().getChapters();
                    },
                    child: const AppText('إعادة المحاولة'),
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
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: AppText(
                        chapter.number.toString(),
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    title: AppText(
                      chapter.name,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    subtitle: AppText(
                      '${chapter.englishName} - ${chapter.englishNameTranslation}',
                      fontSize: 14,
                      color: Colors.grey[600]!,
                    ),
                    trailing: AppText(
                      '${chapter.versesCount} آية',
                      fontSize: 14,
                      color: Colors.grey[600]!,
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

  QuranSearchDelegate({required this.chapters, required this.onFilter});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
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
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onFilter(query, chapters);
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onFilter(query, chapters);
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            child: AppText(
              chapter.number.toString(),
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          title: AppText(
            chapter.name,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          subtitle: AppText(
            '${chapter.englishName} - ${chapter.englishNameTranslation}',
            color: Colors.grey[600]!,
          ),
          trailing: AppText(
            '${chapter.versesCount} آية',
            color: Colors.grey[600]!,
          ),
          onTap: () {
            // TODO: Navigate to chapter details
          },
        );
      },
    );
  }
}
