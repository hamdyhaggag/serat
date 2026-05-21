import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PropheticPeriod {
  final String title;
  final String time;
  final List<String> activities;
  final IconData icon;
  final Color color;

  PropheticPeriod({
    required this.title,
    required this.time,
    required this.activities,
    required this.icon,
    required this.color,
  });
}

class PropheticDayScreen extends StatelessWidget {
  final bool isDarkMode;

  PropheticDayScreen({super.key, required this.isDarkMode});

  final List<PropheticPeriod> schedule = [
    PropheticPeriod(
      title: 'قبل الفجر',
      time: '00:00 - 05:00',
      activities: [
        'يتهجد ويصلي قيام الليل في المنزل أو في المسجد',
        'يأخذ قيلولة قصيرة بعد التهجد',
      ],
      icon: Icons.nightlight_round,
      color: const Color(0xff3F51B5),
    ),
    PropheticPeriod(
      title: 'الفجر',
      time: '05:00 - 07:00',
      activities: [
        'يستيقظ، يتطهر فمه بالسواك',
        'يحمد الله ويثني عليه',
        'يستمع إلى الأذان',
        'يصلي ركعتين قبل الفجر',
        'يصلي صلاة الفجر ويخطب فيهم',
      ],
      icon: Icons.wb_twilight_rounded,
      color: const Color(0xff2196F3),
    ),
    PropheticPeriod(
      title: 'بعد شروق الشمس',
      time: '07:00 - 09:00',
      activities: [
        'يصلي ركعتين',
        'يذهب إلى المنزل، ويحدث أهله',
        'يذهب إلى أصحابه',
      ],
      icon: Icons.light_mode_rounded,
      color: const Color(0xffFF9800),
    ),
    PropheticPeriod(
      title: 'بداية اليوم',
      time: '09:00 - 12:00',
      activities: [
        'يعود إلى المسجد، ويصلي ركعتين',
        'يعلم أصحابه ويعظهم',
        'يستمع ويعالج القضايا السياسية والاجتماعية',
        'يزور الأهل والأقارب',
      ],
      icon: Icons.groups_rounded,
      color: const Color(0xff009688),
    ),
    PropheticPeriod(
      title: 'الظهر',
      time: '12:00 - 15:00',
      activities: [
        'يؤم المصلين بصلاة الظهر',
        'في بعض الأحيان يعظهم ويوجههم',
        'يخرج مع أصحابه في مهام محددة',
      ],
      icon: Icons.wb_sunny_rounded,
      color: const Color(0xffFFC107),
    ),
    PropheticPeriod(
      title: 'العصر',
      time: '15:00 - 18:00',
      activities: [
        'يؤم المصلين بصلاة العصر',
        'يعود إلى بيته ويمضي فترة مع أهله',
        'أحيانا يزور أصحابه أو يستقبل ضيوفاً',
      ],
      icon: Icons.architecture_rounded,
      color: const Color(0xffFF5722),
    ),
    PropheticPeriod(
      title: 'المغرب',
      time: '18:00 - 20:00',
      activities: [
        'يؤم المصلين بصلاة المغرب',
        'يصلي ركعتين بعد المغرب',
        'يتناول العشاء إذا وجد',
        'يجلس مع أهله وأصحابه',
      ],
      icon: Icons.nights_stay_rounded,
      color: const Color(0xff9C27B0),
    ),
    PropheticPeriod(
      title: 'العشاء',
      time: '20:00 - 23:00',
      activities: [
        'يؤم المصلين بصلاة العشاء',
        'يذكر الله ويثني عليه',
        'يعود إلى بيته ويخطب بعد صلاة العشاء',
        'يذهب إلى النوم مبكراً',
      ],
      icon: Icons.bedtime_rounded,
      color: const Color(0xff673AB7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff121212) : const Color(0xffF9FAFB),
      appBar: AppBar(
        title: const Text(
          'اليوم النبوي',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: schedule.length,
        itemBuilder: (context, index) {
          final isLast = index == schedule.length - 1;
          final period = schedule[index];
          return _TimelineTile(
            period: period,
            isLast: isLast,
            isDarkMode: isDarkMode,
            delay: (index * 100).ms,
          );
        },
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final PropheticPeriod period;
  final bool isLast;
  final bool isDarkMode;
  final Duration delay;

  const _TimelineTile({
    required this.period,
    required this.isLast,
    required this.isDarkMode,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Indicator
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: period.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: period.color.withOpacity(0.5), width: 2),
                  ),
                  child: Icon(period.icon, color: period.color, size: 20),
                ).animate().scale(delay: delay, duration: 400.ms, curve: Curves.easeOutBack),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            period.color.withOpacity(0.5),
                            period.color.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ).animate().scaleY(
                          delay: delay + 200.ms,
                          duration: 400.ms,
                          curve: Curves.easeOut,
                          alignment: Alignment.topCenter,
                        ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDarkMode
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.transparent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          period.title,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: period.color,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: period.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            period.time,
                            style: TextStyle(
                              fontFamily: 'DIN',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: period.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...period.activities.map(
                      (activity) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Icon(
                                Icons.circle,
                                size: 6,
                                color: isDarkMode ? Colors.white54 : Colors.black45,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                activity,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white70 : Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).toList(),
                  ],
                ),
              ).animate().fadeIn(delay: delay + 100.ms, duration: 400.ms).slideX(begin: 0.1, end: 0),
            ),
          ),
        ],
      ),
    );
  }
}
