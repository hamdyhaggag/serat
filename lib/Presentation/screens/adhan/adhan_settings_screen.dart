import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../Business_Logic/Cubit/adhan/adhan_cubit.dart';
import '../../../shared/constants/app_colors.dart' as shared_colors;

class AdhanSettingsScreen extends StatelessWidget {
  const AdhanSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdhanCubit()..init(),
      child: BlocBuilder<AdhanCubit, AdhanState>(
        builder: (context, state) {
          final cubit = AdhanCubit.get(context);
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: isDarkMode
                ? shared_colors.AppColors.darkBackgroundColor
                : Colors.grey[50],
            appBar: AppBar(
              title: const Text(
                'إعدادات المؤذن',
                style:
                    TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Main Adhan Toggle

                  // Main Adhan Toggle
                  _buildGlassCard(
                    isDarkMode,
                    child: SwitchListTile(
                      title: const Text(
                        'تفعيل الأذان',
                        style: TextStyle(
                            fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'تشغيل صوت الأذان في مواعيد الصلاة',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                      ),
                      value: cubit.isAdhanEnabled,
                      onChanged: (val) => cubit.toggleGlobalAdhan(val),
                      activeColor: shared_colors.AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pre-Prayer Reminder Section
                  _buildPrePrayerSection(cubit, isDarkMode),
                  const SizedBox(height: 24),

                  const SizedBox(height: 16),

                  // Per Prayer Toggles
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'تخصيص الصلوات',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPrayerItem(context, 'الفجر', 'Fajr', cubit, isDarkMode),
                  _buildPrayerItem(
                      context, 'الظهر', 'Dhuhr', cubit, isDarkMode),
                  _buildPrayerItem(context, 'العصر', 'Asr', cubit, isDarkMode),
                  _buildPrayerItem(
                      context, 'المغرب', 'Maghrib', cubit, isDarkMode),
                  _buildPrayerItem(
                      context, 'العشاء', 'Isha', cubit, isDarkMode),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrePrayerSection(AdhanCubit cubit, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'تنبيه اقتراب الصلاة',
            style: TextStyle(
                fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        _buildGlassCard(
          isDarkMode,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text(
                  'تنبيه "اقتربت الصلاة"',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                subtitle: const Text(
                  'تنبيه صوتي قبل موعد الأذان بوقت محدد',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11),
                ),
                value: cubit.isPreAdhanEnabled,
                onChanged: (val) => cubit.togglePreAdhan(val),
                activeColor: shared_colors.AppColors.primaryColor,
              ),
              if (cubit.isPreAdhanEnabled) ...[
                const Divider(height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text(
                        'التنبيه قبل بـ:',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                      ),
                      const Spacer(),
                      DropdownButton<int>(
                        value: cubit.preAdhanMinutes,
                        underline: const SizedBox(),
                        items: [5, 10, 15, 20, 30].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value دقيقة',
                                style: const TextStyle(
                                    fontFamily: 'Cairo', fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) => cubit.updatePreAdhanMinutes(val!),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ).animate().fade().slideY(begin: 0.1, end: 0);
  }

  Widget _buildGlassCard(bool isDarkMode, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.7),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildPrayerItem(BuildContext context, String titleAr, String key,
      AdhanCubit cubit, bool isDarkMode) {
    final isEnabled = cubit.prayerAdhanEnabled[key] ?? true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _buildGlassCard(
        isDarkMode,
        child: ListTile(
          leading: Icon(
            isEnabled ? Icons.notifications_active : Icons.notifications_off,
            color:
                isEnabled ? shared_colors.AppColors.primaryColor : Colors.grey,
          ),
          title: Text(
            titleAr,
            style: const TextStyle(
                fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
          trailing: Switch(
            value: isEnabled,
            onChanged: (val) => cubit.togglePrayerAdhan(key, val),
            activeColor: shared_colors.AppColors.primaryColor,
          ),
          onTap: () {},
        ),
      ),
    ).animate().fade(delay: 100.ms).slideX(begin: 0.1, end: 0);
  }
}
