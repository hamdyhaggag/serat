import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/quran_cubit.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import 'package:serat/Core/utils/app_colors.dart';
import 'package:serat/Core/widgets/app_text.dart';

class QuranChapterScreen extends StatefulWidget {
  final QuranChapter chapter;

  const QuranChapterScreen({super.key, required this.chapter});

  @override
  State<QuranChapterScreen> createState() => _QuranChapterScreenState();
}

class _QuranChapterScreenState extends State<QuranChapterScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure we have the chapters loaded before getting verses
    if (context.read<QuranCubit>().state is! QuranLoaded) {
      context.read<QuranCubit>().getChapters();
    }
    context.read<QuranCubit>().getChapterVerses(widget.chapter.number);
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
    final dividerColor =
        isDarkMode
            ? Colors.grey[800] ?? Colors.grey[700]!
            : Colors.grey[200] ?? Colors.grey[300]!;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? Colors.grey[900] : Theme.of(context).primaryColor,
        title: AppText(
          widget.chapter.name,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Cairo',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          if (state is QuranVersesLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          } else if (state is QuranVersesError) {
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
                      context.read<QuranCubit>().getChapterVerses(
                        widget.chapter.number,
                      );
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
          } else if (state is QuranVersesLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.verses.length,
              itemBuilder: (context, index) {
                final verse = state.verses[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 16,
                              child: AppText(
                                verse.numberInSurah.toString(),
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            if (verse.sajda)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const AppText(
                                  'سجدة',
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AppText(
                          verse.text,
                          fontSize: 24,
                          textAlign: TextAlign.right,
                          color: textColor,
                          fontFamily: 'Cairo',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              'جزء ${verse.juz}',
                              fontSize: 14,
                              color: subtitleColor,
                              fontFamily: 'Cairo',
                            ),
                            AppText(
                              'صفحة ${verse.page}',
                              fontSize: 14,
                              color: subtitleColor,
                              fontFamily: 'Cairo',
                            ),
                          ],
                        ),
                      ],
                    ),
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
