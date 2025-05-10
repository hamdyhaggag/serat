import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:serat/features/azkar/domain/azkar_model.dart';
import 'package:serat/services/azkar_service.dart';

class WakeUpAzkar extends StatelessWidget {
  final String title;
  const WakeUpAzkar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: FutureBuilder<List<Azkar>>(
          future: AzkarService().fetchAzkar(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:
                        isDarkMode
                            ? [const Color(0xff1F1F1F), const Color(0xff2D2D2D)]
                            : [Colors.grey[50]!, Colors.grey[100]!],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDarkMode
                                      ? Colors.white
                                      : AppColors.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'جاري التحميل...',
                              style: TextStyle(
                                fontFamily: 'DIN',
                                fontSize: 16,
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:
                        isDarkMode
                            ? [const Color(0xff1F1F1F), const Color(0xff2D2D2D)]
                            : [Colors.grey[50]!, Colors.grey[100]!],
                  ),
                ),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 50,
                          color: isDarkMode ? Colors.white : Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'حدث خطأ',
                          style: TextStyle(
                            fontFamily: 'DIN',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DIN',
                            fontSize: 16,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Trigger a rebuild to retry
                            (context as Element).markNeedsBuild();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDarkMode
                                    ? Colors.white
                                    : AppColors.primaryColor,
                            foregroundColor:
                                isDarkMode
                                    ? AppColors.primaryColor
                                    : Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'إعادة المحاولة',
                            style: TextStyle(
                              fontFamily: 'DIN',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final azkar = snapshot.data ?? [];
            return AzkarModelView(
              title: title,
              azkarList: azkar.map((zikr) => zikr.text).toList(),
              maxValues: azkar.map((zikr) => zikr.count).toList(),
            );
          },
        ),
      ),
    );
  }
}
