import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/location_cubit.dart';
import 'package:serat/Data/Model/times_model.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late DateTime selectedDate;
  late String selectedMonth;
  late String selectedCalendar;
  late List<String> months;
  final List<String> calendarTypes = ['هجري', 'ميلادي'];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedCalendar = 'هجري';
    _initializeMonths();
  }

  void _initializeMonths() {
    if (selectedCalendar == 'هجري') {
      months = [
        'محرم',
        'صفر',
        'ربيع الأول',
        'ربيع الثاني',
        'جمادى الأولى',
        'جمادى الآخرة',
        'رجب',
        'شعبان',
        'رمضان',
        'شوال',
        'ذو القعدة',
        'ذو الحجة',
      ];
    } else {
      months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];
    }
    selectedMonth = months[selectedDate.month - 1];
  }

  String _getCurrentDateString() {
    final locationCubit = LocationCubit.get(context);
    if (locationCubit.timesModel == null) return '';

    final date = locationCubit.timesModel!.data.date;
    if (selectedCalendar == 'هجري') {
      return '${date.hijri.year} ${date.hijri.month.ar} ${date.hijri.day} ${date.hijri.weekday.ar}';
    } else {
      return '${date.gregorian.year} ${date.gregorian.month.ar} ${date.gregorian.day} ${date.gregorian.weekday.ar}';
    }
  }

  String _getAlternateDateString() {
    final locationCubit = LocationCubit.get(context);
    if (locationCubit.timesModel == null) return '';

    final date = locationCubit.timesModel!.data.date;
    if (selectedCalendar == 'هجري') {
      return '${date.gregorian.year} ${date.gregorian.month.ar} ${date.gregorian.day} ${date.gregorian.weekday.ar}';
    } else {
      return '${date.hijri.year} ${date.hijri.month.ar} ${date.hijri.day} ${date.hijri.weekday.ar}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF6F7FB);
    final cardColor = isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3142);
    final secondaryTextColor = isDarkMode ? Colors.white70 : const Color(0xFF2D3142).withOpacity(0.7);
    final borderColor = isDarkMode ? Colors.white24 : const Color(0xFF4CB7A5).withOpacity(0.3);
    final accentColor = const Color(0xFF4CB7A5);

    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: const CustomAppBar(title: 'التقويم'),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                    shadowColor: isDarkMode ? Colors.black : Colors.black12,
                    color: cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: accentColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _getCurrentDateString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: textColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: accentColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _getAlternateDateString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: textColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: selectedMonth,
                                    isExpanded: true,
                                    dropdownColor: cardColor,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.calendar_month,
                                        color: accentColor,
                                      ),
                                    ),
                                    items: months.map((month) => DropdownMenuItem(
                                      value: month,
                                      child: Text(
                                        month,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        selectedMonth = val!;
                                        final monthIndex = months.indexOf(val);
                                        selectedDate = DateTime(
                                          selectedDate.year,
                                          monthIndex + 1,
                                          selectedDate.day,
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: selectedCalendar,
                                    isExpanded: true,
                                    dropdownColor: cardColor,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.swap_horiz,
                                        color: accentColor,
                                      ),
                                    ),
                                    items: calendarTypes.map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        selectedCalendar = val!;
                                        _initializeMonths();
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildCalendarGrid(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'مناسبات قادمة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'عرض كل المناسبات',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                    shadowColor: isDarkMode ? Colors.black : Colors.black12,
                    color: cardColor,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accentColor.withOpacity(0.1),
                                cardColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.nightlight_round,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'عيد الفطر المبارك',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '2025 يناير 27 الاثنين | 1446 رجب 27 الاثنين',
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.event_available,
                                      size: 20,
                                      color: accentColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'قريباً',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'سيتم إضافة المناسبات قريباً',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.notifications_active,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          'سأخطرك عند الإطلاق',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3142);
    final secondaryTextColor = isDarkMode ? Colors.white70 : const Color(0xFF2D3142).withOpacity(0.7);
    final accentColor = const Color(0xFF4CB7A5);
    final cardColor = isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;

    final daysOfWeek = [
      'سبت',
      'أحد',
      'اثنين',
      'ثلاثاء',
      'أربعاء',
      'خميس',
      'جمعه',
    ];

    final locationCubit = LocationCubit.get(context);
    if (locationCubit.timesModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final date = locationCubit.timesModel!.data.date;
    final daysInMonth = selectedCalendar == 'هجري'
        ? 30 // Hijri months are either 29 or 30 days
        : DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    final firstDayOfMonth = selectedCalendar == 'هجري'
        ? _getHijriFirstDayOfMonth(
            int.parse(date.hijri.year),
            date.hijri.month.number,
          )
        : DateTime(selectedDate.year, selectedDate.month, 1).weekday % 7;

    final totalCells = firstDayOfMonth + daysInMonth;
    final rowsNeeded = (totalCells / 7).ceil();

    return Stack(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: daysOfWeek.map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 12),
            Table(
              children: List.generate(rowsNeeded, (row) {
                return TableRow(
                  children: List.generate(7, (col) {
                    final dayNumber = row * 7 + col - firstDayOfMonth + 1;
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const SizedBox.shrink();
                    }
                    bool isSelected = dayNumber == selectedDate.day;
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              dayNumber,
                            );
                          });
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? accentColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? accentColor
                                  : secondaryTextColor,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              dayNumber.toString(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : textColor,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
          ],
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.rocket_launch,
                    size: 40,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'قريباً',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سيتم إضافة هذه الميزة قريباً',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'سأخطرك عند الإطلاق',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _getHijriFirstDayOfMonth(int year, int month) {
    // For now, we'll use the current date's weekday
    // In a production app, you should use a proper Hijri calendar library
    // like hijri or ummalqura to get accurate Hijri dates
    final now = DateTime.now();
    return now.weekday % 7;
  }
}
