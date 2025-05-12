import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/quran_cubit.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import 'package:serat/Core/widgets/app_text.dart';

class QuranChapterScreen extends StatefulWidget {
  final QuranChapter chapter;

  const QuranChapterScreen({Key? key, required this.chapter}) : super(key: key);

  @override
  State<QuranChapterScreen> createState() => _QuranChapterScreenState();
}

class _QuranChapterScreenState extends State<QuranChapterScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuranCubit>().getChapterVerses(widget.chapter.number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          '${widget.chapter.name} (${widget.chapter.englishName})',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          if (state is QuranVersesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuranVersesLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.verses.length,
              itemBuilder: (context, index) {
                final verse = state.verses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AppText(
                                verse.numberInSurah.toString(),
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (verse.sajda)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const AppText(
                                  'سجدة',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppText(
                          verse.text,
                          fontSize: 24,
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              'جزء ${verse.juz}',
                              fontSize: 14,
                              color: Colors.grey[600]!,
                            ),
                            AppText(
                              'صفحة ${verse.page}',
                              fontSize: 14,
                              color: Colors.grey[600]!,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                    child: const AppText('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
