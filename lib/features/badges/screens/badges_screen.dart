import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/features/badges/cubit/badges_cubit.dart';
import 'package:serat/features/badges/models/badge_model.dart';
import 'package:serat/shared/constants/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui' show ImageFilter;
import 'package:awesome_dialog/awesome_dialog.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BadgesCubit()..initBadges(),
      child: const _BadgesScreenContent(),
    );
  }
}

class _BadgesScreenContent extends StatelessWidget {
  const _BadgesScreenContent();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackgroundColor : Colors.white,
      appBar: AppBar(
        title: const Text(
          'الأوسمة النبوية',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: isDarkMode ? Colors.white : Colors.black87),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('إعادة تعيين الأوسمة', style: TextStyle(fontFamily: 'Cairo')),
                  content: const Text('هل أنت متأكد من تصفير وإعادة تعيين جميع إنجازاتك؟ لا يمكن التراجع عن هذا الإجراء.', style: TextStyle(fontFamily: 'Cairo', height: 1.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: isDarkMode ? Colors.white70 : Colors.black87)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        BadgesCubit.get(context).resetBadges();
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('إعادة تعيين', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<BadgesCubit, BadgesState>(
        listener: (context, state) {
          if (state is BadgesSubmissionSuccess) {
            if (state.isNewlyUnlocked) {
               _showBadgeUnlockedDialog(context, state.badge, isDarkMode);
            } else {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.reason, style: const TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: AppColors.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } else if (state is BadgesSubmissionRejected) {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: AppColors.warningColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {
          final cubit = BadgesCubit.get(context);
          
          if (state is BadgesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final badges = cubit.badges;
          final unlockedCount = badges.where((b) => b.isUnlocked).length;

          return Column(
            children: [
              _buildHeader(unlockedCount, badges.length, isDarkMode),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return _BadgeCard(
                      badge: badge,
                      isDarkMode: isDarkMode,
                    ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1, end: 0);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActionSheet(context, isDarkMode),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('تسجيل موقف', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(int unlocked, int total, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode 
             ? [const Color(0xff2A2A2A), const Color(0xff1A1A1A)]
             : [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : AppColors.primaryColor).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إنجازاتك النبوية',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),
               Text(
                'لقد حصدت $unlocked من أصل $total أوسمة',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.military_tech_rounded, size: 40, color: Colors.white),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scaleXY(begin: 0.9, end: 1.1, duration: 1000.ms),
        ],
      ),
    );
  }

  void _showAddActionSheet(BuildContext context, bool isDarkMode) {
    final cubit = BadgesCubit.get(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xff252525) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ماذا فعلت اليوم؟',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اختر عملاً صالحاً قمت به اليوم لترتبط بهدي النبي ﷺ',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Cairo',
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<BadgesCubit, BadgesState>(
                  bloc: cubit,
                  builder: (context, state) {
                    final badges = cubit.badges;
                    return ListView.builder(
                      controller: controller,
                      itemCount: badges.length,
                      itemBuilder: (context, index) {
                        final badge = badges[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: badge.gradientColors.first.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(badge.icon, color: badge.gradientColors.first),
                              ),
                              title: Text(
                                badge.name,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              children: badge.examples.map((action) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    cubit.submitAction(badge.id, action);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle_outline, color: badge.gradientColors.first, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            action,
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              color: isDarkMode ? Colors.white70 : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeUnlockedDialog(BuildContext context, BadgeModel badge, bool isDarkMode) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      customHeader: Container(
         padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(
           shape: BoxShape.circle,
           gradient: LinearGradient(colors: badge.gradientColors),
         ),
         child: Icon(badge.icon, size: 50, color: Colors.white),
      ),
      title: 'تهانينا! 🎉',
      desc: 'لقد نلت وسام "${badge.name}"\n\n${badge.hadith}\n(${badge.source})',
      descTextStyle: const TextStyle(fontFamily: 'Cairo', height: 1.5, fontSize: 16),
      titleTextStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 22),
      btnOkOnPress: () {},
      btnOkColor: badge.gradientColors.first,
      btnOkText: 'الحمد لله',
      buttonsTextStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
      dialogBackgroundColor: isDarkMode ? const Color(0xff252525) : Colors.white,
    ).show();
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeModel badge;
  final bool isDarkMode;

  const _BadgeCard({required this.badge, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: badge.isUnlocked 
           ? (isDarkMode ? const Color(0xff2A2A2A) : Colors.white)
           : (isDarkMode ? const Color(0xff1E1E1E) : Colors.grey[50]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badge.isUnlocked 
              ? badge.gradientColors.first.withOpacity(0.5)
              : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[200]!),
        ),
        boxShadow: [
          if (badge.isUnlocked)
            BoxShadow(
              color: badge.gradientColors.first.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (!badge.isUnlocked)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                  child: Container(color: Colors.transparent),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                           color: badge.isUnlocked
                              ? badge.gradientColors.first.withOpacity(0.1)
                              : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[200]),
                           shape: BoxShape.circle,
                        ),
                        child: Icon(
                          badge.icon, 
                          color: badge.isUnlocked ? badge.gradientColors.first : Colors.grey, 
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              badge.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${badge.progressCount} / ${badge.requiredCount}',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'DIN',
                                color: badge.isUnlocked ? badge.gradientColors.first : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (badge.isUnlocked)
                           Icon(Icons.verified_rounded, color: badge.gradientColors.first, size: 32)
                              .animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    badge.hadith,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge.source,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: isDarkMode ? Colors.white38 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                   // Progress bar
                   Container(
                     height: 10,
                     clipBehavior: Clip.hardEdge,
                     decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(5),
                     ),
                     child: Row(
                       children: [
                          Expanded(
                            flex: (badge.progressPercent * 100).toInt(),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: badge.gradientColors,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ).animate().scaleX(begin: 0, alignment: Alignment.centerRight, duration: 800.ms, curve: Curves.easeOutCubic),
                          ),
                          Expanded(
                            flex: 100 - (badge.progressPercent * 100).toInt(),
                            child: const SizedBox(),
                          )
                       ],
                     ),
                   ),
                  
                  if (!badge.isComplete) ...[
                    const SizedBox(height: 20),
                    Text(
                      'المواقف المقترحة (اسحب لاختيار واحد):',
                      style: TextStyle(
                        fontFamily: 'Cairo', 
                        fontSize: 12,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: badge.examples.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                           final action = badge.examples[idx];
                           return ActionChip(
                             label: Text(action, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: isDarkMode ? Colors.white : Colors.black87)),
                             onPressed: () {
                                BadgesCubit.get(context).submitAction(badge.id, action);
                             },
                             backgroundColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                             elevation: isDarkMode ? 0 : 1,
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(20),
                               side: BorderSide(
                                 color: badge.gradientColors.first.withOpacity(0.3),
                               ),
                             ),
                           );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
