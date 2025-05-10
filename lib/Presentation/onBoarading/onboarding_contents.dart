class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: " مرحبًا بك في تطبيق تَطْمَئِن ",
    image: "assets/onboarding/onboarding1.png",
    desc: "رفيقك الشامل للارتقاء بتجربتك الدينية",
  ),
  OnboardingContents(
    title: "مواقيت الصلاة الدقيقة",
    image: "assets/onboarding/onboarding2.png",
    desc: "اعرف أوقات الصلاة بدقة و أدِّ الفرائض في وقتها",
  ),
  OnboardingContents(
    title: "سبحة إلكترونية",
    image: "assets/onboarding/onboarding3.png",
    desc:
        "ارفع روحك مع الله من خلال استخدام السبحة الإلكترونية ، و قم بذكر الله في كل زمان",
  ),
  OnboardingContents(
    title: "الأذكار والأدعية",
    image: "assets/onboarding/onboarding6.png",
    desc:
        "استمتع بمجموعة واسعة من الأذكار والأدعية لتمتلك قلبًا مطمئنًا في جميع الأوقات",
  ),
  OnboardingContents(
    title: "اتجاه القبلة",
    image: "assets/onboarding/onboarding4.png",
    desc: "دع التطبيق يرشدك لاتجاه القبلة أثناء الصلاة ، بُناءً على موقعك",
  ),
  OnboardingContents(
    title: "تصميم بسيط وسهل الاستخدام",
    image: "assets/onboarding/onboarding5.png",
    desc: "استمتع بتجربة استخدام سلسة ، بغض النظر عن مستوى خبرتك التكنولوجية",
  ),
];
