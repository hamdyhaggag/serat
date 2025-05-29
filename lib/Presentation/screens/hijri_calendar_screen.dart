import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/location_cubit.dart';
import 'package:serat/Data/Model/times_model.dart';
import 'package:serat/Data/Model/hijri_calendar_model.dart';
import 'package:serat/Data/Model/hijri_holiday_model.dart';
import 'package:serat/Data/Services/hijri_calendar_service.dart';
import 'package:serat/Data/Services/hijri_holiday_service.dart';
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
  final HijriCalendarService _calendarService = HijriCalendarService();
  final HijriHolidayService _holidayService = HijriHolidayService();
  HijriCalendarResponse? _calendarData;
  HijriHolidayModel? _holidayData;
  bool _isLoading = true;
  bool _isLoadingHoliday = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedCalendar = 'هجري';
    _initializeMonths();
    _fetchCalendarData();
  }

  Future<void> _fetchCalendarData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _calendarService.getHijriCalendar(
        selectedDate.month,
        selectedDate.year,
      );

      setState(() {
        _calendarData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchHolidays(int day, int month) async {
    try {
      setState(() {
        _isLoadingHoliday = true;
      });

      final response = await _holidayService.getHijriHolidays(day, month);

      setState(() {
        _holidayData = response;
        _isLoadingHoliday = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingHoliday = false;
      });
    }
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
    if (_calendarData == null || _calendarData!.data.isEmpty) return '';

    final date = _calendarData!.data[0];
    if (selectedCalendar == 'هجري') {
      return '${date.hijri.weekday.ar ?? date.hijri.weekday.en} ، ${date.hijri.day} ${date.hijri.month.ar ?? date.hijri.month.en} ${date.hijri.year} هـ';
    } else {
      final gregorianMonths = {
        'January': 'يناير',
        'February': 'فبراير',
        'March': 'مارس',
        'April': 'أبريل',
        'May': 'مايو',
        'June': 'يونيو',
        'July': 'يوليو',
        'August': 'أغسطس',
        'September': 'سبتمبر',
        'October': 'أكتوبر',
        'November': 'نوفمبر',
        'December': 'ديسمبر',
      };

      final gregorianWeekdays = {
        'Monday': 'الاثنين',
        'Tuesday': 'الثلاثاء',
        'Wednesday': 'الأربعاء',
        'Thursday': 'الخميس',
        'Friday': 'الجمعة',
        'Saturday': 'السبت',
        'Sunday': 'الأحد',
      };

      final month =
          gregorianMonths[date.gregorian.month.en] ?? date.gregorian.month.en;
      final weekday = gregorianWeekdays[date.gregorian.weekday.en] ??
          date.gregorian.weekday.en;

      return '$weekday ، ${date.gregorian.day} $month ${date.gregorian.year} م';
    }
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    final gregorianMonths = {
      'January': 'يناير',
      'February': 'فبراير',
      'March': 'مارس',
      'April': 'أبريل',
      'May': 'مايو',
      'June': 'يونيو',
      'July': 'يوليو',
      'August': 'أغسطس',
      'September': 'سبتمبر',
      'October': 'أكتوبر',
      'November': 'نوفمبر',
      'December': 'ديسمبر',
    };

    final gregorianWeekdays = {
      'Monday': 'الاثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
      'Saturday': 'السبت',
      'Sunday': 'الأحد',
    };

    final month = gregorianMonths[DateFormat('MMMM').format(now)] ??
        DateFormat('MMMM').format(now);
    final weekday = gregorianWeekdays[DateFormat('EEEE').format(now)] ??
        DateFormat('EEEE').format(now);

    return '$weekday ، ${now.day} $month ${now.year} م';
  }

  String _getAlternateDateString() {
    if (_calendarData == null || _calendarData!.data.isEmpty) return '';

    final date = _calendarData!.data[0];
    if (selectedCalendar == 'هجري') {
      final gregorianMonths = {
        'January': 'يناير',
        'February': 'فبراير',
        'March': 'مارس',
        'April': 'أبريل',
        'May': 'مايو',
        'June': 'يونيو',
        'July': 'يوليو',
        'August': 'أغسطس',
        'September': 'سبتمبر',
        'October': 'أكتوبر',
        'November': 'نوفمبر',
        'December': 'ديسمبر',
      };

      final gregorianWeekdays = {
        'Monday': 'الاثنين',
        'Tuesday': 'الثلاثاء',
        'Wednesday': 'الأربعاء',
        'Thursday': 'الخميس',
        'Friday': 'الجمعة',
        'Saturday': 'السبت',
        'Sunday': 'الأحد',
      };

      final month =
          gregorianMonths[date.gregorian.month.en] ?? date.gregorian.month.en;
      final weekday = gregorianWeekdays[date.gregorian.weekday.en] ??
          date.gregorian.weekday.en;

      return '$weekday ، ${date.gregorian.day} $month ${date.gregorian.year} م';
    } else {
      return '${date.hijri.weekday.ar ?? date.hijri.weekday.en} ، ${date.hijri.day} ${date.hijri.month.ar ?? date.hijri.month.en} ${date.hijri.year} هـ';
    }
  }

  String _getTodayHijriDateString() {
    if (_calendarData == null || _calendarData!.data.isEmpty) return '';

    // Find today's date in the calendar data
    final today = DateTime.now();
    final todayData = _calendarData!.data.firstWhere(
      (date) =>
          date.gregorian.day == today.day &&
          date.gregorian.month.number == today.month &&
          date.gregorian.year == today.year,
      orElse: () => _calendarData!.data[0],
    );

    return '${todayData.hijri.weekday.ar ?? todayData.hijri.weekday.en} ، ${todayData.hijri.day} ${todayData.hijri.month.ar ?? todayData.hijri.month.en} ${todayData.hijri.year} هـ';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // Professional color palette using primary color
    final backgroundColor =
        isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA);
    final cardColor = isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
    final accentColor = primaryColor;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3142);
    final secondaryTextColor =
        isDarkMode ? Colors.white70 : const Color(0xFF2D3142).withOpacity(0.7);
    final borderColor =
        isDarkMode ? Colors.white24 : primaryColor.withOpacity(0.2);
    final gradientColors = isDarkMode
        ? [
            const Color(0xFF2D2D2D),
            const Color(0xFF1A1A1A),
          ]
        : [
            primaryColor.withOpacity(0.15),
            primaryColor.withOpacity(0.05),
          ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: accentColor,
                  ),
                )
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            style: TextStyle(
                              fontFamily: 'DIN',
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchCalendarData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'إعادة المحاولة',
                              style: TextStyle(
                                fontFamily: 'DIN',
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            // Today's Date Card
                            _buildDateCard(
                              context,
                              title: 'التاريخ اليوم',
                              icon: Icons.calendar_today,
                              content: _getTodayHijriDateString(),
                              subtitle: _getTodayDateString(),
                              backgroundColor: cardColor,
                              textColor: textColor,
                              secondaryTextColor: secondaryTextColor,
                              accentColor: accentColor,
                            ),
                            const SizedBox(height: 16),
                            // Holiday Container
                            _buildHolidayContainer(
                              backgroundColor: cardColor,
                              textColor: textColor,
                              secondaryTextColor: secondaryTextColor,
                              accentColor: accentColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),
                            // Calendar Card
                            Card(
                              elevation: 8,
                              shadowColor:
                                  isDarkMode ? Colors.black : Colors.black12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              color: cardColor,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    // Selected Date Display
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: borderColor,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              _buildIconContainer(
                                                context,
                                                Icons.calendar_today,
                                                accentColor: accentColor,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _getCurrentDateString(),
                                                  style: textTheme.titleLarge
                                                      ?.copyWith(
                                                    fontFamily: 'DIN',
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              _buildIconContainer(
                                                context,
                                                Icons.calendar_today,
                                                accentColor: accentColor,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _getAlternateDateString(),
                                                  style: textTheme.titleLarge
                                                      ?.copyWith(
                                                    fontFamily: 'DIN',
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                  textAlign: TextAlign.end,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Month and Calendar Type Selectors
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildSelector(
                                            context,
                                            value: selectedMonth,
                                            items: months,
                                            icon: Icons.calendar_month,
                                            onChanged: (val) {
                                              setState(() {
                                                selectedMonth = val!;
                                                final monthIndex =
                                                    months.indexOf(val);
                                                selectedDate = DateTime(
                                                  selectedDate.year,
                                                  monthIndex + 1,
                                                  selectedDate.day,
                                                );
                                                _fetchCalendarData();
                                              });
                                            },
                                            backgroundColor: cardColor,
                                            textColor: textColor,
                                            accentColor: accentColor,
                                            borderColor: borderColor,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildSelector(
                                            context,
                                            value: selectedCalendar,
                                            items: calendarTypes,
                                            icon: Icons.swap_horiz,
                                            onChanged: (val) {
                                              setState(() {
                                                selectedCalendar = val!;
                                                _initializeMonths();
                                                _fetchCalendarData();
                                              });
                                            },
                                            backgroundColor: cardColor,
                                            textColor: textColor,
                                            accentColor: accentColor,
                                            borderColor: borderColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // Calendar Grid
                                    _buildCalendarGrid(
                                      textColor: textColor,
                                      secondaryTextColor: secondaryTextColor,
                                      accentColor: accentColor,
                                      borderColor: borderColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildDateCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
    String? subtitle,
    required Color backgroundColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color accentColor,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildIconContainer(
                  context,
                  icon,
                  accentColor: accentColor,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'DIN',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontFamily: 'DIN',
                fontSize: 16,
                color: textColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'DIN',
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(
    BuildContext context,
    IconData icon, {
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSelector(
    BuildContext context, {
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
    required Color backgroundColor,
    required Color textColor,
    required Color accentColor,
    required Color borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        dropdownColor: backgroundColor,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'DIN',
              color: textColor,
            ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            color: accentColor,
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'DIN',
                        color: textColor,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildHolidayContainer({
    required Color backgroundColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color accentColor,
    required Color borderColor,
  }) {
    if (_isLoadingHoliday) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            color: accentColor,
          ),
        ),
      );
    }

    if (_holidayData == null || _holidayData!.data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Center(
          child: Text(
            'لا توجد مناسبات في هذا اليوم',
            style: TextStyle(
              fontFamily: 'DIN',
              fontSize: 16,
              color: textColor,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconContainer(
                context,
                Icons.celebration,
                accentColor: accentColor,
              ),
              const SizedBox(width: 12),
              Text(
                'المناسبات',
                style: TextStyle(
                  fontFamily: 'DIN',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._holidayData!.data.map((holiday) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holiday.name,
                      style: TextStyle(
                        fontFamily: 'DIN',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (holiday.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        holiday.description,
                        style: TextStyle(
                          fontFamily: 'DIN',
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid({
    required Color textColor,
    required Color secondaryTextColor,
    required Color accentColor,
    required Color borderColor,
  }) {
    if (_calendarData == null || _calendarData!.data.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات التقويم',
          style: TextStyle(
            fontFamily: 'DIN',
            fontSize: 16,
            color: textColor,
          ),
        ),
      );
    }

    final daysOfWeek = [
      'سبت',
      'أحد',
      'اثنين',
      'ثلاثاء',
      'أربعاء',
      'خميس',
      'جمعه',
    ];

    final calendarData = _calendarData!.data[0];
    final daysInMonth = selectedCalendar == 'هجري'
        ? calendarData.hijri.month.days ?? 30
        : DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    final firstDayOfMonth = selectedCalendar == 'هجري'
        ? _getHijriFirstDayOfMonth(
            int.parse(calendarData.hijri.year),
            calendarData.hijri.month.number,
          )
        : DateTime(selectedDate.year, selectedDate.month, 1).weekday % 7;

    final totalCells = firstDayOfMonth + daysInMonth;
    final rowsNeeded = (totalCells / 7).ceil();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: daysOfWeek
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontFamily: 'DIN',
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
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

                final dayIndex = dayNumber - 1;
                if (dayIndex >= _calendarData!.data.length) {
                  return const SizedBox.shrink();
                }

                final currentDayData = _calendarData!.data[dayIndex];
                final isHoliday = selectedCalendar == 'هجري'
                    ? currentDayData.hijri.holidays.isNotEmpty
                    : false;

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
                        if (selectedCalendar == 'هجري') {
                          _fetchHolidays(
                            int.parse(currentDayData.hijri.day),
                            currentDayData.hijri.month.number,
                          );
                        }
                      });
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor
                            : isHoliday
                                ? accentColor.withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? accentColor
                              : isHoliday
                                  ? accentColor.withOpacity(0.5)
                                  : borderColor,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayNumber.toString(),
                              style: TextStyle(
                                fontFamily: 'DIN',
                                color: isSelected
                                    ? Colors.white
                                    : isHoliday
                                        ? accentColor
                                        : textColor,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            if (isHoliday &&
                                currentDayData.hijri.holidays.isNotEmpty)
                              Text(
                                currentDayData.hijri.holidays[0],
                                style: TextStyle(
                                  fontFamily: 'DIN',
                                  color: accentColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
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
    );
  }

  int _getHijriFirstDayOfMonth(int year, int month) {
    final now = DateTime.now();
    return now.weekday % 7;
  }
}
