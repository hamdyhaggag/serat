import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:serat/Business_Logic/Cubit/settings_cubit.dart';
import 'package:serat/Business_Logic/Cubit/settings_states.dart';
import 'package:serat/Data/utils/functions.dart';
import 'package:serat/Presentation/Config/constants/app_text.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';
import 'package:serat/Presentation/screens/SettingsScreen/app_info.dart';
import 'package:share_plus/share_plus.dart';
import 'package:serat/Presentation/screens/SettingsScreen/privacy_policy.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:serat/Presentation/Widgets/Shared/app_dialog.dart';
import 'package:serat/imports.dart';

Widget prayTimeRow({
  required String en,
  required String time,
  required String ar,
}) {
  return Builder(
    builder: (context) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: AppText(en, fontSize: 20, align: TextAlign.end),
            ),
            Expanded(
              flex: 0,
              child: AppText(
                time,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode
                        ? const Color(0xff0c8ee1)
                        : AppColors.primaryColor,
              ),
            ),
            Expanded(flex: 1, child: AppText(ar, fontSize: 20)),
          ],
        ),
      );
    },
  );
}

Widget buildRadioButton(BuildContext context, String title, int value) {
  return BlocConsumer<SettingsCubit, SettingsState>(
    listener: (context, state) {},
    builder: (context, state) {
      var settingsCubit = SettingsCubit.get(context);
      return RadioListTile<int>(
        title: AppText(title, fontSize: 16, fontWeight: FontWeight.bold),
        value: value,
        groupValue: settingsCubit.radioValue,
        onChanged: (int? newValue) {
          if (newValue != null) {
            settingsCubit.changeRadio(newValue);
          }
        },
      );
    },
  );
}

void showMethods(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {},
        builder: (context, state) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return SimpleDialog(
            titlePadding: const EdgeInsets.fromLTRB(0, 10, 12, 0),
            title: AppText(
              'طريقة تحديد مواقيت الصلاة',
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'DIN',
            ),
            contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            children: <Widget>[
              buildRadioButton(context, 'رابطة العالم الإسلامي', 3),
              buildRadioButton(context, 'الهيئة المصرية العامة للمساحة', 5),
              buildRadioButton(context, 'جامعة العلوم الإسلامية في كراتشي', 1),
              buildRadioButton(
                context,
                'الجمعية الإسلامية لأمريكا الشمالية',
                2,
              ),
              buildRadioButton(context, 'معهد الجيوفيزياء في جامعة طهران', 7),
            ],
          );
        },
      );
    },
  );
}

const String googlePlayUrl =
    'https://play.google.com/store/apps/developer?id=dev.hamdyhaggag';
void _launchURL(String link) async {
  Uri url = Uri.parse(link);

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}

Widget buildRow(IconData icon, String url, String title, Color color) {
  return InkWell(
    onTap: () {
      _launchURL(url);
    },
    child: SizedBox(
      height: 40.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Icon(icon, color: color, size: 25), AppText(title)],
      ),
    ),
  );
}

void showDonateDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (BuildContext context) => AppDialog(
          content: 'هل تود دعم التطبيق ؟',
          okAction: AppDialogAction(
            title: 'نعم',
            onTap: () {
              launchUrl(Uri.parse('https://www.paypal.com/paypalme/serat'));
            },
          ),
          cancelAction: AppDialogAction(
            title: 'لا',
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
  );
}

////////////////////////////////////////

showprivacy(context) {
  navigateTo(context, const PrivacyPolicy());
}

showappinfo(context) {
  navigateTo(context, const AppInfo());
}

///////////////////////////////

showAlertdialogExampleDidntused(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const AppText('Magical Portal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('You have discovered a magical portal!'),
            SizedBox(height: 10.h),
            const AppText('Where would you like to go?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Forest'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Mountains'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Beach'),
          ),
        ],
      );
    },
  );
}

////////////////////////////////////////////////

void shareOptions(BuildContext context) async {
  const String text = googlePlayUrl;
  const String subject = "  serat - تطبيق صراط";

  await Share.share(text, subject: subject);
}

////////////////////////////////////////////////
void openGooglePlayForFeedback() async {
  const String packageName = 'com.tafakkur';
  const String googlePlayUrl = 'market://details?id=$packageName';

  final Uri googlePlayUri = Uri.parse(googlePlayUrl);

  if (await canLaunchUrl(googlePlayUri)) {
    await launchUrl(googlePlayUri);
  } else {
    throw 'Could not launch Google Play Store.';
  }
}

void shareFeedback(BuildContext context) {
  openGooglePlayForFeedback();
}

////////////////////////////////////////////////
void sendEmail() async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'arabianatech@gmail.com',
    query:
        'subject=ملاحظات ( تطبيق صراط )&body=  .. السلام عليكم ورحمة الله وبركاته ..\n  تمت تعبئة هذة الرسالة تلقائيا ، امسح نص الرسالة و اترك رسالتك', // Replace with your desired subject and body
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    throw 'Could not launch email';
  }
}
