import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';

class CopyButton extends StatelessWidget {
  final String textToCopy;

  const CopyButton(this.textToCopy, {super.key});

  void copyTextToClipboard() {
    Clipboard.setData(ClipboardData(text: textToCopy));
    Fluttertoast.showToast(
      msg: 'تم النسخ ',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 0, bottom: 10),
      child: IconButton(
        icon: Icon(
          FontAwesomeIcons.copy,
          color: isDarkMode ? Colors.white : AppColors.primaryColor,
        ),
        onPressed: copyTextToClipboard,
      ),
    );
  }
}
