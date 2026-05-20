import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/navigation_cubit.dart';
import 'package:serat/imports.dart';
import 'package:serat/Presentation/Widgets/resume_bottom_bar.dart';
import 'package:serat/Business_Logic/Cubit/last_read_cubit.dart';

class ScreenLayout extends StatelessWidget {
  const ScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final cubit = NavigationCubit.get(context);
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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Text(
              'Menu',
              style: TextStyle(
                  color: Colors.white, fontSize: 24, fontFamily: 'Cairo'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home', style: TextStyle(fontFamily: 'Cairo')),
            onTap: () {
              Navigator.pop(context);
              NavigationCubit.get(context).changeIndex(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title:
                const Text('Settings', style: TextStyle(fontFamily: 'Cairo')),
            onTap: () {
              Navigator.pop(context);
              NavigationCubit.get(context).changeIndex(4);
            },
          ),
        ],
      ),
    );
  }
}
