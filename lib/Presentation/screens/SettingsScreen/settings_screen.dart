import 'package:flutter/material.dart';
import '../../../imports.dart';

class SettingsScreens extends StatefulWidget {
  const SettingsScreens({super.key});

  @override
  SettingsScreensState createState() => SettingsScreensState();
}

class SettingsScreensState extends State<SettingsScreens> {
  bool isDarkMode = false;

  void Donate() {
    // TODO: Implement donation functionality
    showDialog(
      context: context,
      builder: (BuildContext context) => AppDialog(
        content: 'سيتم إضافة خاصية التبرع قريباً',
        okAction: AppDialogAction(
          title: 'حسناً',
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        cancelAction: AppDialogAction(
          title: 'إلغاء',
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkModee = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkModee ? const Color(0xff1F1F1F) : Colors.white,
      appBar: const CustomAppBar(title: 'الإعدادات'),
      body: Column(
        children: <Widget>[
          SizedBox(height: 7.h),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const RowWithTextAndIcon(
              'الشاشة الرئيسية',
              FontAwesomeIcons.house,
            ),
          ),
          const CustomSpace(),
          InkWell(
            onTap: () {
              showMethods(context);
            },
            child: const RowWithTextAndIcon(
              'طريقة تحديد مواقيت الصلاة',
              Icons.timer,
            ),
          ),
          const CustomSpace(),
          ///////////////////////
          InkWell(
            onTap: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: selectedTimeMorning ?? TimeOfDay.now(),
              );

              if (pickedTime != null) {
                setState(() {
                  selectedTimeMorning = pickedTime;
                });

                CacheHelper.saveData(
                  key: 'Morning',
                  value:
                      "${selectedTimeMorning!.hour}:${selectedTimeMorning!.minute}",
                );

                await NotificationService.showNotification(
                  title: "التنبية بأذكار الصباح",
                  payload: {
                    "navigate": "true",
                  },
                  actionButtons: [
                    NotificationActionButton(
                      key: 'check',
                      label: 'الدخول إلى التطبيق الآن',
                      color: AppColors.primaryColor,
                    ),
                  ],
                  scheduled: true,
                  selectedTimeMorning: selectedTimeMorning,
                  interval: 0,
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: AppText(
                    selectedTimeMorning != null
                        ? DateFormat('hh:mma').format(
                            DateTime(
                              0,
                              1,
                              1,
                              selectedTimeMorning!.hour,
                              selectedTimeMorning!.minute,
                            ),
                          )
                        : 'اختر التوقيت',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDarkModee
                        ? const Color(0xff0c8ee1)
                        : AppColors.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const Flexible(
                  flex: 8,
                  child: RowWithTextAndIcon(
                    'التنبية لأذكار الصباح',
                    Icons.sunny,
                  ),
                ),
              ],
            ),
          ),
          const CustomSpace(),
          InkWell(
            onTap: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: selectedTimeEvening ?? TimeOfDay.now(),
              );

              if (pickedTime != null) {
                setState(() {
                  selectedTimeEvening = pickedTime;
                });
                CacheHelper.saveData(
                    key: 'Evening',
                    value:
                        "${selectedTimeEvening!.hour}:${selectedTimeEvening!.minute}");
                await NotificationService.showNotification(
                  title: "التنبية بأذكار المساء",
                  payload: {
                    "navigate": "true",
                  },
                  actionButtons: [
                    NotificationActionButton(
                      key: 'check',
                      label: 'الدخول إلى التطبيق الآن',
                      color: AppColors.primaryColor,
                    ),
                  ],
                  scheduled: true,
                  selectedTimeEvening: selectedTimeEvening,
                  interval: 0,
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: AppText(
                    selectedTimeEvening != null
                        ? DateFormat('hh:mma ').format(
                            DateTime(
                              0,
                              1,
                              1,
                              selectedTimeEvening!.hour,
                              selectedTimeEvening!.minute,
                            ),
                          )
                        : 'اختر التوقيت',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDarkModee
                        ? const Color(0xff0c8ee1)
                        : AppColors.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const Flexible(
                  flex: 8,
                  child: RowWithTextAndIcon(
                    'التنبية لأذكار المساء',
                    Icons.dark_mode,
                  ),
                ),
              ],
            ),
          ),
          const CustomSpace(),
          // Row(
          //   children: [
          //     Container(),
          //     Transform.scale(
          //       scale: 0.37,
          //       child: DayNightSwitch(
          //         size: Size(120.w, 35.h),
          //         value: isDarkMode,
          //         sunColor: isDarkModee ? Colors.grey : AppColors.primaryColor,
          //         moonColor: isDarkModee ? Colors.grey : AppColors.primaryColor,
          //         dayColor: isDarkModee ? Colors.black26 : Colors.black26,
          //         nightColor: isDarkModee ? Colors.black26 : Colors.black26,
          //         onChanged: (value) {
          //           setState(() {
          //             isDarkMode = value;
          //           });
          //         },
          //       ),
          //     ),
          //     const Flexible(
          //       flex: 14,
          //       child: RowWithTextAndIcon(
          //         'تفعيل الوضع الليلي',
          //         Icons.wb_sunny_rounded,
          //       ),
          //     ),
          //   ],
          // ),
          // const CustomSpace(),
          //////////////////////////////////////
          InkWell(
            onTap: () {
              showappinfo(context);
            },
            child: const RowWithTextAndIcon(
              'معلومات عن التطبيق',
              Icons.info,
            ),
          ),
          const CustomSpace(),

          InkWell(
            onTap: () {
              showprivacy(context);
            },
            child: const RowWithTextAndIcon(
              'سياسة الخصوصية',
              Icons.privacy_tip_rounded,
            ),
          ),
          const CustomSpace(),

          InkWell(
            onTap: () {
              shareFeedback(context);
            },
            child: const RowWithTextAndIcon(
              'تقييم التطبيق',
              Icons.star,
            ),
          ),
          const CustomSpace(),

          InkWell(
            onTap: () {
              shareOptions(context);
            },
            child: const RowWithTextAndIcon(
              'شارك التطبيق',
              Icons.share,
            ),
          ),
          const CustomSpace(),

          InkWell(
            onTap: () {
              sendEmail();
            },
            child: const RowWithTextAndIcon(
              'تواصل معنا',
              Icons.mail_rounded,
            ),
          ),
          const CustomSpace(),

          InkWell(
            onTap: () {
              Donate();
            },
            child: const RowWithTextAndIcon(
              'ادعمنا',
              FontAwesomeIcons.circleDollarToSlot,
            ),
          ),
          const CustomSpace(),
        ],
      ),
    );
  }
}
