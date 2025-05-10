import 'package:flutter/material.dart';
import 'package:serat/Business_Logic/Cubit/navigation_cubit.dart';
import 'package:serat/imports.dart';
import 'package:serat/Presentation/Widgets/Shared/app_dialog.dart';
import 'dart:ui' show TextDirection;

class ScreenLayout extends StatelessWidget {
  const ScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final cubit = NavigationCubit.get(context);
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          endDrawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: AppColors.primaryColor),
                  child: const Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                    cubit.changeIndex(0);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    cubit.changeIndex(4);
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            selectedFontSize: 16,
            unselectedFontSize: 16,
            iconSize: 28,
            elevation: 8,
            enableFeedback: false,
            unselectedItemColor:
                isDarkMode
                    ? Colors.grey.withOpacity(0.5)
                    : Colors.grey.shade600,
            selectedItemColor: AppColors.primaryColor,
            backgroundColor:
                isDarkMode ? const Color(0xb01f1f1f) : Colors.white,
            type: BottomNavigationBarType.fixed,
            items: cubit.bottomItems,
            currentIndex: cubit.index,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            onTap: (index) {
              cubit.changeIndex(index);
            },
          ),
          body: WillPopScope(
            onWillPop: () async {
              if (cubit.index != 4) {
                cubit.changeIndex(4);
                return false;
              }
              return true;
            },
            child: IndexedStack(
              index: cubit.index,
              children: cubit.buildScreens,
            ),
          ),
        );
      },
    );
  }
}
