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
    image: "assets/onboarding/onboarding6.png",
    desc:
        "احفظ أذكار الصباح والمساء، واستمتع بمجموعة واسعة من الأذكار والأدعية لتمتلك قلبًا مطمئنًا في جميع الأوقات",
  ),
  OnboardingContents(
    title: "التقويم الهجري",
    image: "assets/onboarding/onboarding3.png",
    desc:
        "تابع التقويم الهجري بسهولة، واحتفل بالمناسبات الإسلامية المهمة مع تذكيرات مخصصة",
  ),
  OnboardingContents(
    title: "القبلة",
    image: "assets/onboarding/onboarding4.png",
    desc:
        "حدد اتجاه القبلة بدقة عالية باستخدام البوصلة الإلكترونية، مع تحديثات مستمرة لموقعك",
  ),
  OnboardingContents(
    title: "أسماء الله الحسنى",
    image: "assets/onboarding/onboarding5.png",
    desc: "تعرف على أسماء الله الحسنى وشرحها وفضلها، مع أدعية مخصصة لكل اسم",
  ),
  OnboardingContents(
    title: "التاريخ الإسلامي",
    image: "assets/onboarding/onboarding7.png",
    desc:
        "اكتشف أحداث ومواقف مهمة من التاريخ الإسلامي، مع قصص ملهمة من حياة الصحابة والتابعين",
  ),
  OnboardingContents(
    title: "تصميم عصري وسهل الاستخدام",
    image: "assets/onboarding/onboarding8.png",
    desc:
        "استمتع بتجربة استخدام سلسة وأنيقة، مع واجهة مستخدم بسيطة وواضحة تناسب جميع المستخدمين",
  ),
];
