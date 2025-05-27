import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/quran_cubit.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import 'package:serat/Core/widgets/app_text.dart' as core;
import 'package:serat/Presentation/screens/quran_chapter_screen.dart';

const String kQuranFont = 'KFGQPC Uthman Taha Naskh';
const String kDefaultFont = 'Cairo';

const double kDefaultPadding = 16.0;
const double kItemSpacing = 12.0;
const double kCardBorderRadius = 16.0;
const double kSubtleElevation = 2.0;
const double kProminentElevation = 4.0;

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<QuranChapter> _filteredChapters = [];

  @override
  void initState() {
    super.initState();
    final quranCubit = context.read<QuranCubit>();
    if (quranCubit.state is! QuranLoaded && quranCubit.state is! QuranLoading) {
      quranCubit.getChapters();
    }
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
    final subtitleColor = isDarkMode
        ? Colors.grey[400] ?? Colors.grey
        : Colors.grey[600] ?? Colors.grey;
    final cardColor =
        isDarkMode ? Colors.grey[900] ?? Colors.grey[800]! : Colors.white;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'القرآن الكريم',
          style: TextStyle(
            fontFamily: 'Din',
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _searchController.clear();
              _filterChapters('');
              setState(() {
                _isSearching = true;
              });
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
                  core.AppText(
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
                    child: const core.AppText('إعادة المحاولة',
                        fontFamily: 'Cairo'),
                  ),
                ],
              ),
            );
          } else if (state is QuranLoaded) {
            final chaptersToShow =
                _isSearching ? _filteredChapters : state.chapters;

            return Column(
              children: [
                if (_isSearching) _buildSearchBar(),
                Expanded(
                  child: chaptersToShow.isEmpty && _isSearching
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: subtitleColor,
                              ),
                              const SizedBox(height: 16),
                              core.AppText(
                                'لم يتم العثور على نتائج',
                                color: subtitleColor,
                                fontSize: 16,
                                fontFamily: 'Cairo',
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: chaptersToShow.length,
                          itemBuilder: (context, index) {
                            final chapter = chaptersToShow[index];
                            final bool isMeccan =
                                (chapter.revelationPlace['en']?.toLowerCase() ??
                                        '') ==
                                    'meccan';
                            final String revelationPlaceText =
                                isMeccan ? 'مكية' : 'مدنية';

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              color: cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          QuranChapterScreen(chapter: chapter),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: Center(
                                          child: core.AppText(
                                            chapter.number.toString(),
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            core.AppText(
                                              chapter.name['ar'] ?? '',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                              fontFamily: 'Din',
                                            ),
                                            const SizedBox(height: 4),
                                            core.AppText(
                                              '${chapter.name['en'] ?? ''} - ${chapter.name['transliteration'] ?? ''}',
                                              fontSize: 12,
                                              color: subtitleColor,
                                              fontFamily: 'Cairo',
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: core.AppText(
                                                    revelationPlaceText,
                                                    fontSize: 12,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontFamily: 'Cairo',
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                core.AppText(
                                                  '${chapter.versesCount} آية',
                                                  fontSize: 14,
                                                  color: subtitleColor,
                                                  fontFamily: 'Cairo',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: subtitleColor,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ابحث عن سورة...',
          hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
            fontFamily: 'Cairo',
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterChapters('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: _filterChapters,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
        ),
      ),
    );
  }

  void _filterChapters(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredChapters = [];
        _isSearching = false;
      });
      return;
    }

    final state = context.read<QuranCubit>().state;
    if (state is QuranLoaded) {
      setState(() {
        _filteredChapters = state.chapters.where((chapter) {
          final arabicName = (chapter.name['ar'] ?? '').trim();
          final englishName = (chapter.name['en'] ?? '').toLowerCase();
          final transliteration =
              (chapter.name['transliteration'] ?? '').toLowerCase();
          final searchQuery = query.trim();

          bool isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(searchQuery);

          if (isArabic) {
            return arabicName.contains(searchQuery);
          } else {
            return arabicName
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                englishName.contains(searchQuery.toLowerCase()) ||
                transliteration.contains(searchQuery.toLowerCase());
          }
        }).toList();
        _isSearching = true;
      });
    }
  }
}

class QuranSearchDelegate extends SearchDelegate<QuranChapter?> {
  final List<QuranChapter> chapters;
  final bool isDarkMode;
  final ThemeData themeData;

  QuranSearchDelegate({
    required this.chapters,
    required this.isDarkMode,
    required this.themeData,
  });

  @override
  String get searchFieldLabel => 'ابحث عن سورة (اسم، رقم)...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final Color searchAppBarColor = isDarkMode
        ? const Color(0xFF242B40)
        : Colors.white; // Matches card color
    final Color searchIconColor = isDarkMode
        ? Colors.white70
        : themeData.primaryColorDark.withOpacity(0.7);
    final Color searchTextColor =
        isDarkMode ? Colors.white.withOpacity(0.9) : const Color(0xFF1F2937);

    return themeData.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: searchAppBarColor,
        elevation: kProminentElevation, // Make search bar pop a bit
        iconTheme: IconThemeData(color: searchIconColor),
        titleTextStyle: TextStyle(
            color: searchTextColor,
            fontSize: 18,
            fontFamily: 'Din',
            fontWeight: FontWeight.w500),
        toolbarTextStyle: TextStyle(
            color: searchTextColor, fontFamily: kDefaultFont), // For query text
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
            color: searchTextColor.withOpacity(0.5),
            fontFamily: kDefaultFont,
            fontSize: 17),
        // For a cleaner search bar look
        border: InputBorder.none, // Remove underline
        // Ensure text color matches
        labelStyle: TextStyle(color: searchTextColor, fontFamily: kDefaultFont),
      ),
      scaffoldBackgroundColor: isDarkMode
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFF4F6F8), // Matches main screen
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return query.isEmpty
        ? []
        : [
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              tooltip: 'مسح', // Clear
              onPressed: () {
                query = '';
                showSuggestions(
                    context); // Rebuild suggestions (often shows initial list or empty)
              },
            ),
          ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
      tooltip: 'رجوع', // Back
      onPressed: () => close(context, null),
    );
  }

  Widget _buildResultsOrSuggestions(BuildContext context) {
    final searchQuery = query.toLowerCase().trim();
    final List<QuranChapter> filteredChapters = searchQuery.isEmpty
        ? chapters // Show all as initial suggestions
        : chapters.where((chapter) {
            final nameAr = (chapter.name['ar'] ?? '').toLowerCase();
            final nameEn = (chapter.name['en'] ?? '').toLowerCase();
            final nameTr =
                (chapter.name['transliteration'] ?? '').toLowerCase();
            final number = chapter.number.toString();
            return nameAr.contains(searchQuery) ||
                nameEn.contains(searchQuery) ||
                nameTr.contains(searchQuery) ||
                number.contains(searchQuery);
          }).toList();

    if (searchQuery.isNotEmpty && filteredChapters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64,
                color: (isDarkMode ? Colors.white : Colors.black)
                    .withOpacity(0.3)),
            const SizedBox(height: kDefaultPadding),
            core.AppText(
              'لا توجد نتائج للبحث عن "$query"',
              color:
                  (isDarkMode ? Colors.white : Colors.black).withOpacity(0.6),
              fontSize: 16,
              fontFamily: kDefaultFont,
              align: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (searchQuery.isEmpty && chapters.isNotEmpty) {
      // Optionally, show a "Start typing..." message for suggestions
      // For now, it lists all chapters if query is empty
    }

    final Color itemTextColor =
        isDarkMode ? Colors.white.withOpacity(0.9) : const Color(0xFF1F2937);
    final Color itemSubtitleColor =
        isDarkMode ? Colors.white.withOpacity(0.6) : const Color(0xFF4B5563);
    final Color itemCardBgColor =
        isDarkMode ? const Color(0xFF242B40) : Colors.white; // Match main card

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          vertical: kDefaultPadding / 2, horizontal: kDefaultPadding / 2),
      itemCount: filteredChapters.length,
      itemBuilder: (context, index) {
        final chapter = filteredChapters[index];
        // Highlighting search query can be added here for super-pro feel (requires more complex TextSpans)
        return Card(
          elevation: kSubtleElevation / 2, // Less elevation for search items
          margin: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding / 2, vertical: kItemSpacing / 2.5),
          color: itemCardBgColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kCardBorderRadius / 1.5)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
            leading: CircleAvatar(
              backgroundColor: themeData.primaryColor.withOpacity(0.1),
              radius: 20,
              child: core.AppText(
                chapter.number.toString(),
                color: themeData.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: kDefaultFont,
              ),
            ),
            title: core.AppText(
              chapter.name['ar'] ?? '',
              color: itemTextColor,
              fontSize: 18,
              fontFamily: kQuranFont,
              fontWeight: FontWeight.w600,
            ),
            subtitle: core.AppText(
              '${chapter.name['en'] ?? ''} - ${chapter.name['transliteration'] ?? ''}',
              color: itemSubtitleColor,
              fontSize: 12,
              fontFamily: kDefaultFont,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => close(context, chapter),
          ),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) =>
      _buildResultsOrSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) =>
      _buildResultsOrSuggestions(context);
}
