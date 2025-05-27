import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import '../screens/screen_layout.dart';
import 'onboarding_contents.dart';
import 'size_config.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _currentPage = 0;
  List colors = const [
    Color(0xfff3eded),
    Color(0xfff3eded),
    Color(0xfff3eded),
    Color(0xfff3eded),
    Color(0xfff3eded),
    Color(0xfff3eded),
  ];

  AnimatedContainer _buildDots({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        color: AppColors.primaryColor,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      height: 10,
      curve: Curves.easeIn,
      width: _currentPage == index ? 20 : 10,
    );
  }

  void _nextPage() {
    if (_currentPage < contents.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double width = SizeConfig.screenW!;
    double height = SizeConfig.screenH!;

    // Calculate responsive values
    bool isSmallScreen = width <= 550;
    bool isVerySmallScreen = width <= 360;
    bool isLargeScreen = width > 1200;

    // Responsive padding and spacing
    double horizontalPadding =
        isVerySmallScreen ? 16.0 : (isSmallScreen ? 24.0 : 32.0);
    double verticalPadding =
        isVerySmallScreen ? 16.0 : (isSmallScreen ? 24.0 : 32.0);
    double imageHeight =
        height * (isVerySmallScreen ? 0.20 : (isSmallScreen ? 0.25 : 0.30));
    double titleFontSize =
        isVerySmallScreen ? 24.0 : (isSmallScreen ? 28.0 : 32.0);
    double descFontSize =
        isVerySmallScreen ? 16.0 : (isSmallScreen ? 18.0 : 20.0);
    double buttonFontSize =
        isVerySmallScreen ? 16.0 : (isSmallScreen ? 18.0 : 20.0);
    double buttonPadding =
        isVerySmallScreen ? 12.0 : (isSmallScreen ? 16.0 : 20.0);

    return Scaffold(
      backgroundColor: colors[_currentPage],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: _controller,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: contents.length,
                itemBuilder: (context, i) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: height * 0.02),
                          Image.asset(
                            contents[i].image,
                            height: imageHeight,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: height * 0.03),
                          Text(
                            contents[i].title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "DIN",
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                              fontSize: titleFontSize,
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          Text(
                            contents[i].desc,
                            style: TextStyle(
                              fontFamily: "DIN",
                              fontWeight: FontWeight.w300,
                              color: AppColors.primaryColor,
                              fontSize: descFontSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        contents.length,
                        (index) => _buildDots(index: index),
                      ),
                    ),
                  ),
                  _currentPage + 1 == contents.length
                      ? Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: ElevatedButton(
                          onPressed: () {
                            navigateTo(context, const ScreenLayout());
                            CacheHelper.saveData(
                              key: 'isEnterBefore',
                              value: true,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.15,
                              vertical: buttonPadding,
                            ),
                            textStyle: TextStyle(
                              fontSize: buttonFontSize,
                              fontFamily: 'DIN',
                            ),
                          ),
                          child: const Text(
                            "ابدأ الآن",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      : Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                navigateTo(context, const ScreenLayout());
                                CacheHelper.saveData(
                                  key: 'isEnterBefore',
                                  value: true,
                                );
                              },
                              style: TextButton.styleFrom(
                                elevation: 0,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: buttonFontSize,
                                  fontFamily: 'DIN',
                                ),
                              ),
                              child: Text(
                                "التخطي",
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.08,
                                  vertical: buttonPadding,
                                ),
                                textStyle: TextStyle(
                                  fontSize: buttonFontSize,
                                  fontFamily: 'DIN',
                                ),
                              ),
                              child: const Text(
                                "التالي",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
