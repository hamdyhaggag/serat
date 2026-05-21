import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/navigation_cubit.dart';
import 'package:serat/imports.dart';
import 'package:serat/Presentation/Widgets/resume_bottom_bar.dart';
import 'package:serat/Business_Logic/Cubit/last_read_cubit.dart';
import 'package:serat/features/quran/screens/surah_list_screen.dart';
import 'package:serat/features/spiritual_progress/screens/spiritual_dashboard_screen.dart';
import 'package:serat/Presentation/screens/SettingsScreen/app_info.dart';

class ScreenLayout extends StatelessWidget {
  const ScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final cubit = NavigationCubit.get(context);
        cubit.startTrackingIfNeeded(context);
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final theme = Theme.of(context);

        final navItems = [
          {'icon': 'assets/icon/home.svg', 'label': 'الرئيسية'},
          {'icon': 'assets/icon/Tasbih.svg', 'label': 'السبحة'},
          {'icon': 'assets/icon/Azkar.svg', 'label': 'الأذكار'},
          {'icon': 'assets/icon/Ahadith.svg', 'label': 'الأحاديث'},
          {'icon': 'assets/icon/qibla.svg', 'label': 'القبلة'},
        ];

        return Scaffold(
          extendBody: true, // Needed for transparency/glass effect
          endDrawer: const _CustomDrawer(),
          body: WillPopScope(
            onWillPop: () async {
              if (cubit.index != 0) {
                cubit.changeIndex(0);
                return false;
              }
              return await _showExitDialog(context, isDarkMode);
            },
            child: Stack(
              children: [
                IndexedStack(
                  index: cubit.index,
                  children: cubit.buildScreens,
                ),

                // Pro "Docked" Navigation Bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The Resume Bottom Bar (Premium UX)
                      BlocBuilder<LastReadCubit, LastReadState>(
                        builder: (context, state) {
                          if (state is LastReadLoaded && state.hasData) {
                            return ResumeBottomBar(
                              title: state.type == 'audio' ? 'استئناف الاستماع' : 'استئناف القراءة',
                              subtitle: '${state.title} - ${state.subtitle}',
                              icon: state.type == 'audio' ? Icons.headset_rounded : Icons.menu_book_rounded,
                              onTap: () {
                                // TODO: Navigate to the correct screen based on state
                                // Example: if type == 'audio' push AudioScreen
                                // if type == 'quran' push SurahScreen
                              },
                              onClose: () {
                                LastReadCubit.get(context).clearLastRead();
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      ClipRRect(
                        borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height:
                            90, // Slightly improved height for safearea and design
                        decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xff1E1E1E).withOpacity(0.9)
                                : Colors.white.withOpacity(0.9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, -5),
                              ),
                            ],
                            border: Border(
                                top: BorderSide(
                                    color: isDarkMode
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.black.withOpacity(0.05),
                                    width: 1))),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(navItems.length, (index) {
                              final isSelected = cubit.index == index;
                              return InkWell(
                                onTap: () => cubit.changeIndex(index),
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          color: theme.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        )
                                      : null,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        navItems[index]['icon'] as String,
                                        height: 24,
                                        colorFilter: ColorFilter.mode(
                                          isSelected
                                              ? theme.primaryColor
                                              : (isDarkMode
                                                  ? Colors.grey
                                                  : Colors.grey.shade600),
                                          BlendMode.srcIn,
                                        ),
                                      )
                                          .animate(target: isSelected ? 1 : 0)
                                          .scale(
                                              begin: const Offset(1, 1),
                                              end: const Offset(1.15, 1.15))
                                          .shake(
                                              hz: 4,
                                              curve: Curves.easeInOut,
                                              duration: 200.ms),
                                       const SizedBox(height: 4),
                                        AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 250),
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 11,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? theme.primaryColor
                                                : (isDarkMode
                                                    ? Colors.grey
                                                    : Colors.grey.shade500),
                                          ),
                                          child: Text(
                                            navItems[index]['label'] as String,
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ), // Container
                    ), // BackdropFilter
                  ), // ClipRRect
                ], // Column children
              ), // Column
            ), // Positioned
          ], // Stack children
        ), // Stack
      ), // WillPopScope
    ); // Scaffold
      },
    );
  }

  Future<bool> _showExitDialog(BuildContext context, bool isDarkMode) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xff2F2F2F) : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.exit_to_app_rounded,
                      size: 40, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'تأكيد الخروج',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontFamily: 'Cairo', // Consistent font
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'هل أنت متأكد من رغبتك في الخروج؟',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        color: isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                isDarkMode ? Colors.white70 : Colors.grey[700],
                          ),
                          child: const Text('إلغاء',
                              style: TextStyle(fontFamily: 'Cairo')),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor),
                          child: const Text('خروج',
                              style: TextStyle(
                                  fontFamily: 'Cairo', color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }
}

class _CustomDrawer extends StatelessWidget {
  const _CustomDrawer();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      width: isTablet ? 400 : size.width * 0.8,
      backgroundColor: isDarkMode ? const Color(0xff121212) : const Color(0xffF8FAF9),
      child: Column(
        children: [
          _buildHeader(context, isDarkMode),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                const SizedBox(height: 12),
                _buildDrawerItem(
                  context,
                  title: 'الرئيسية',
                  icon: Icons.home_rounded,
                  index: 0,
                  isDarkMode: isDarkMode,
                ),
                _buildDrawerItem(
                  context,
                  title: 'القرآن الكريم',
                  icon: Icons.menu_book_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SurahListScreen()));
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildDrawerItem(
                  context,
                  title: 'مركز العبادات',
                  icon: Icons.auto_awesome_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SpiritualDashboardScreen()));
                  },
                  isDarkMode: isDarkMode,
                ),
                const Divider(height: 32, thickness: 0.5),
                _buildDrawerItem(
                  context,
                  title: 'الإعدادات',
                  icon: Icons.settings_rounded,
                  index: 4,
                  isDarkMode: isDarkMode,
                ),
                _buildDrawerItem(
                  context,
                  title: 'عن التطبيق',
                  icon: Icons.info_outline_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AppInfo()));
                  },
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
          _buildFooter(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        image: DecorationImage(
          image: const AssetImage('assets/images/pattern.png'),
          opacity: 0.05,
          fit: BoxFit.cover,
          repeat: ImageRepeat.repeat,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.1),
            BlendMode.srcIn,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          const AppText(
            'أهلاً بك في صراط',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Cairo',
          ),
          const AppText(
            'صحبتك في رحلة العبادة',
            fontSize: 12,
            color: Colors.white70,
            fontFamily: 'Cairo',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    int? index,
    VoidCallback? onTap,
    required bool isDarkMode,
  }) {
    final isSelected = index != null && NavigationCubit.get(context).index == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected 
            ? Theme.of(context).primaryColor.withOpacity(0.1) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap ?? () {
            Navigator.pop(context);
            if (index != null) {
              NavigationCubit.get(context).changeIndex(index);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : (isDarkMode ? Colors.white60 : Colors.black54),
                  size: 24,
                ),
                const SizedBox(width: 16),
                AppText(
                  title,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : (isDarkMode ? Colors.white70 : Colors.black87),
                  fontFamily: 'Cairo',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 10),
          AppText(
            'صراط - الإصدار 2.0.0',
            fontSize: 10,
            color: isDarkMode ? Colors.white24 : Colors.grey,
            fontFamily: 'Cairo',
          ),
        ],
      ),
    );
  }
}
