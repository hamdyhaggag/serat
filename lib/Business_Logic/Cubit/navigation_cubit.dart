import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/imports.dart';
import 'package:serat/Presentation/screens/Ahadith_screen/ahadith_list_screen.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationInitial());

  static NavigationCubit get(context) => BlocProvider.of(context);

  int index = 0;

  List<Widget> get buildScreens => [
    const TimingsScreen(),
    const SebhaAzkarListScreen(),
    const AzkarScreen(),
    const AhadithListScreen(),
    const QiblaScreen(),
  ];

  List<BottomNavigationBarItem> get bottomItems => [
    _buildBottomNavItem('home', 'الرئيسية', 0),
    _buildBottomNavItem('Tasbih', 'السبحة', 1),
    _buildBottomNavItem('Azkar', 'الأذكار', 2),
    _buildBottomNavItem('Ahadith', 'الأربعين', 3),
    _buildBottomNavItem('qibla', 'القبلة', 4),
  ];

  void changeIndex(int newIndex) {
    index = newIndex;
    emit(ChangeBottomNavState());
  }

  BottomNavigationBarItem _buildBottomNavItem(
    String asset,
    String label,
    int itemIndex,
  ) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        "assets/icon/$asset.svg",
        height: 28,
        colorFilter: ColorFilter.mode(
          index == itemIndex ? AppColors.primaryColor : Colors.grey,
          BlendMode.srcIn,
        ),
      ),
      label: label,
    );
  }
}

// Navigation States
abstract class NavigationState {}

class NavigationInitial extends NavigationState {}

class ChangeBottomNavState extends NavigationState {}
