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
    title: "مرحبًا بك في تطبيق صراط",
    image: "assets/onboarding/onboarding1.png",
    desc: "رفيقك الشامل للإرتقاء بتجربتك الدينية وتقوية إيمانك",
  ),
  OnboardingContents(
    title: "القرآن الكريم",
    image: "assets/onboarding/onboarding2.png",
    desc:
        "استمتع بتلاوة القرآن الكريم مع مجموعة متنوعة من القراء المميزين، واختر من بين العديد من التفاسير والترجمات",
  ),
  OnboardingContents(
    title: "الأذكار والأدعية",
    image: "assets/onboarding/onboarding3.png",
    desc:
        "احفظ أذكار الصباح والمساء، واستمتع بمجموعة واسعة من الأذكار والأدعية لتمتلك قلبًا مطمئنًا في جميع الأوقات",
  ),
  OnboardingContents(
    title: "القبلة",
    image: "assets/onboarding/onboarding4.png",
    desc:
        "حدد اتجاه القبلة بدقة عالية باستخدام البوصلة الإلكترونية، مع تحديثات مستمرة لموقعك",
  ),
  OnboardingContents(
    title: "راديو إسلامي مباشر",
    image: "assets/onboarding/onboarding5.png",
    desc:
        "استمع إلى إذاعات إسلامية مباشرة من مختلف أنحاء العالم، لتبقى على اتصال دائم بالقرآن والدروس الدينية",
  )
];
