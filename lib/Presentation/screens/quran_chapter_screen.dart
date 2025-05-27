import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/quran_cubit.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import 'package:serat/Core/widgets/app_text.dart' as core;

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
    // Add a small delay to ensure state transitions are complete
    Future.microtask(() {
      if (mounted) {
        context.read<QuranCubit>().getChapterVerses(widget.chapter.number);
      }
    });
  }

  @override
  void dispose() {
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

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          context.read<QuranCubit>().returnToChapters();
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
        appBar: AppBar(
          backgroundColor:
              isDarkMode ? Colors.grey[900] : Theme.of(context).primaryColor,
          title: Text(
            widget.chapter.name['ar']?.toString() ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.read<QuranCubit>().returnToChapters();
              Navigator.of(context).pop();
            },
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
                    Text(
                      'حدث خطأ: ${state.message}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
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
                      child: const Text('إعادة المحاولة',
                          style: TextStyle(fontFamily: 'Cairo')),
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
                              Expanded(
                                child: Text(
                                  verse.text['ar']?.toString() ?? '',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: textColor,
                                    fontFamily: 'Amiri',
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      verse.number.toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (verse.sajda?.obligatory == true)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'جزء ${verse.juz}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtitleColor,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              Text(
                                'صفحة ${verse.page}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtitleColor,
                                  fontFamily: 'Cairo',
                                ),
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
      ),
    );
  }
}
