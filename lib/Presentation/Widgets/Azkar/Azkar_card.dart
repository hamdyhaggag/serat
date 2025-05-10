import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:serat/Business_Logic/Cubit/azkar_cubit.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';
import 'package:serat/Presentation/Widgets/Shared/Share_button.dart';
import 'package:serat/Presentation/Widgets/Shared/circle_progress.dart';
import 'package:serat/Presentation/Widgets/Shared/copy_button.dart';
import 'package:vibration/vibration.dart';

class AzkarCard extends StatefulWidget {
  final double screenWidth;
  final String text;
  final int maxValue;
  final int initialCounterValue;
  final VoidCallback onShowCheckIcon;
  final VoidCallback onCheckIconShown;
  final bool showCheckIcon;

  const AzkarCard({
    super.key,
    required this.screenWidth,
    required this.text,
    this.maxValue = 1,
    this.initialCounterValue = 0,
    required this.onShowCheckIcon,
    required this.onCheckIconShown,
    required this.showCheckIcon,
  });

  @override
  AzkarCardState createState() => AzkarCardState();
}

class AzkarCardState extends State<AzkarCard> {
  late int counterValue;
  bool showCheckIcon = false;
  bool hasConfettiBeenTriggered = false;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    counterValue = widget.initialCounterValue;
    showCheckIcon = widget.showCheckIcon;
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void didUpdateWidget(AzkarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showCheckIcon != widget.showCheckIcon) {
      setState(() {
        showCheckIcon = widget.showCheckIcon;
      });
    }
  }

  void incrementCounter() {
    if (counterValue < widget.maxValue) {
      setState(() {
        counterValue++;
        if (counterValue == widget.maxValue) {
          showCheckIcon = true;
          widget.onShowCheckIcon();
          widget.onCheckIconShown();
          Vibration.vibrate();

          if (!hasConfettiBeenTriggered) {
            hasConfettiBeenTriggered = true;
            Future.delayed(const Duration(milliseconds: 100), () {
              if (showCheckIcon) {
                _confettiController.play();
              }
            });
          }

          BlocProvider.of<AzkarCubit>(context).updateCompletedCards(
            BlocProvider.of<AzkarCubit>(context).state.completedCards + 1,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: incrementCounter,
      child: Card(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        margin: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(widget.screenWidth * 0.04),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CopyButton(widget.text),
                      ShareButton(widget.text),
                    ],
                  ),
                  Center(
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: widget.screenWidth * 0.06,
                          fontFamily: 'DIN',
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? const Color(0xffffffff)
                              : AppColors.primaryColor),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        painter: CircleProgressPainter(
                          isDarkMode: isDarkMode,
                          progress: showCheckIcon
                              ? 1.0
                              : counterValue / widget.maxValue,
                          showCheckIcon: showCheckIcon,
                        ),
                        child: SizedBox(
                          width: 54.w,
                          height: 90.h,
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: showCheckIcon
                            ? isDarkMode
                                ? const Color(0xff0c8ee1)
                                : AppColors.primaryColor
                            : const Color.fromARGB(255, 195, 205, 212),
                        radius: 27,
                        child: showCheckIcon
                            ? const Icon(
                                Icons.check,
                                size: 30,
                                color: Colors.white,
                              )
                            : Text(
                                counterValue.toString(),
                                style: const TextStyle(
                                  fontFamily: 'DIN',
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        shouldLoop: false,
                        colors: const [
                          Colors.red,
                          Colors.green,
                          Colors.blue,
                          Colors.orange
                        ],
                        createParticlePath: (size) {
                          return Path()
                            ..moveTo(size.width / 2, size.height / 2)
                            ..lineTo(size.width, size.height);
                        },
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -13),
                    child: Text(
                      '${widget.maxValue} : عدد التكرارات ',
                      style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : AppColors.primaryColor,
                          fontSize: 20.0,
                          fontFamily: 'DIN'),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
