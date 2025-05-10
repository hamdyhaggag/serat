import 'package:flutter/material.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';
import 'package:vibration/vibration.dart';
import 'Share_button.dart';
import 'copy_button.dart';

class CustomContainer extends StatefulWidget {
  final String title;
  final String? headtitle;

  final int maxValue;
  final int initialCounterValue;

  const CustomContainer({
    super.key,
    this.headtitle,
    required this.title,
    required this.maxValue,
    this.initialCounterValue = 0,
  });

  @override
  CustomContainerState createState() => CustomContainerState();
}

class CustomContainerState extends State<CustomContainer> {
  late int counterValue;
  bool showCheckIcon = false;
  @override
  void initState() {
    super.initState();
    counterValue = widget.initialCounterValue;
  }

  void incrementCounter() {
    if (counterValue < widget.maxValue) {
      setState(() {
        counterValue++;
        if (counterValue == widget.maxValue) {
          showCheckIcon = true;
          Vibration.vibrate();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: incrementCounter, // Change to incrementCounter
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
            ),
          ),
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CopyButton(widget.title),
                      ShareButton(widget.title),
                    ],
                  ),
                  Column(
                    children: [
                      if (widget.headtitle != null)
                        Text(
                          widget.headtitle!,
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : AppColors.primaryColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : AppColors.primaryColor,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stack(
                      //   children: [
                      //     Container(
                      //       height: 2,
                      //       width: 300,
                      //       color: isDarkMode
                      //           ? Colors.white
                      //           : AppColors.primaryColor,
                      //     ),
                      //     Positioned(
                      //       top: 10,
                      //       left: (300 - 54) / 2,
                      //       child: CircleAvatar(
                      //         backgroundColor: showCheckIcon
                      //             ? isDarkMode
                      //                 ? const Color(0xff0c8ee1)
                      //                 : AppColors.primaryColor
                      //             : const Color.fromARGB(255, 195, 205, 212),
                      //         radius: 27,
                      //         child: showCheckIcon
                      //             ? const Icon(
                      //                 Icons.check,
                      //                 size: 30,
                      //                 color: Colors.white,
                      //               )
                      //             : Text(
                      //                 counterValue.toString(),
                      //                 style: const TextStyle(
                      //                   fontFamily: 'DIN',
                      //                   fontSize: 20,
                      //                   color: Colors.white,
                      //                 ),
                      //               ),
                      //       ),
                      //     ),
                      //     Positioned(
                      //       top: 10,
                      //       left: (300 - 54) / 2,
                      //       child: CustomPaint(
                      //         painter: CircleProgressPainter(
                      //           isDarkMode: isDarkMode,
                      //           progress: counterValue / widget.maxValue,
                      //           showCheckIcon: showCheckIcon,
                      //         ),
                      //         child: const SizedBox(
                      //           width: 54,
                      //           height: 54,
                      //         ),
                      //       ),
                      //     ),
                      //     const SizedBox(
                      //       height: 70,
                      //     ),
                      //   ],
                      // ),
                      // Text(
                      //   ' ${widget.maxValue} : عدد التكرارات ',
                      //   style: TextStyle(
                      //     color: isDarkMode
                      //         ? Colors.white
                      //         : AppColors.primaryColor,
                      //     fontSize: 20.0,
                      //   ),
                      // )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
