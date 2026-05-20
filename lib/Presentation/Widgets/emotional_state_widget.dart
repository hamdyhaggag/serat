import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

class EmotionalStateWidget extends StatefulWidget {
  final bool isDarkMode;

  const EmotionalStateWidget({super.key, required this.isDarkMode});

  @override
  State<EmotionalStateWidget> createState() => _EmotionalStateWidgetState();
}

class _EmotionalStateWidgetState extends State<EmotionalStateWidget> {
  int? _selectedIndex;

  static const List<Map<String, dynamic>> _emotions = [
    {
      'title': 'قلق',
      'emoji': '😟',
      'color': Colors.deepPurple,
      'dua':
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ، وَغَلَبَةِ الرَّجَالِ',
      'verse': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ'
    },
    {
      'title': 'حزين',
      'emoji': '😢',
      'color': Colors.blueGrey,
      'dua':
          'اللَّهُمَّ رَحْمَتَكَ أَرْجُو فَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ، وَأَصْلِحْ لِي شَأْنِي كُلَّهُ لَا إِلَهَ إِلَّا أَنْتَ',
      'verse':
          'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ'
    },
    {
      'title': 'تائه',
      'emoji': '🤔',
      'color': Colors.indigo,
      'dua':
          'اللَّهُمَّ دُلَّنِي عَلَى مَنْ يَدُلُّني عَلَيْكَ، وَأَوْصِلْنِي بِمَنْ يُوصِلُنِي إِلَيْكَ',
      'verse': 'وَوَجَدَكَ ضَالًّا فَهَدَى'
    },
    {
      'title': 'مهموم',
      'emoji': '😔',
      'color': Colors.brown,
      'dua':
          'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      'verse': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا * إِنَّ مَعَ الْعُسْرِ يُسْرًا'
    },
    {
      'title': 'مكسور',
      'emoji': '💔',
      'color': Colors.redAccent,
      'dua':
          'اللَّهُمَّ اجْبُرْ كَسْرِي، وَارْحَمْ ضَعْفِي، وَتَوَلَّ أَمْرِي',
      'verse': 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ'
    },
    {
      'title': 'خائف',
      'emoji': '😨',
      'color': Colors.orange,
      'dua': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'verse':
          'الَّذِينَ قَالَ لَهُمُ النَّاسُ إِنَّ النَّاسَ قَدْ جَمَعُوا لَكُمْ فَاخْشَوْهُمْ فَزَادَهُمْ إِيمَانًا وَقَالُوا حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ'
    },
    {
      'title': 'غاضب',
      'emoji': '😠',
      'color': Colors.red,
      'dua': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الشَّيْطَانِ الرَّجِيمِ',
      'verse':
          'وَالْكَاظِمِينَ الْغَيْظَ وَالْعَافِينَ عَنِ النَّاسِ ۗ وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ'
    },
    {
      'title': 'وحيد',
      'emoji': '🥺',
      'color': Colors.blue,
      'dua': 'اللَّهُمَّ آنِسْ وَحْشَتِي، وَارْحَمْ غُرْبَتِي',
      'verse': 'وَنَحْنُ أَقْرَبُ إِلَيْهِ مِنْ حَبْلِ الْوَرِيدِ'
    },
    {
      'title': 'ضعيف',
      'emoji': '🥀',
      'color': Colors.grey,
      'dua':
          'اللَّهُمَّ إِنِّي ضَعِيفٌ فَقَوِّنِي، وَذَلِيلٌ فَأَعِزَّنِي، وَفَقِيرٌ فَارْزُقْنِي',
      'verse':
          'اللَّهُ الَّذِي خَلَقَكُم مِّن ضَعْفٍ ثُمَّ جَعَلَ مِن بَعْدِ ضَعْفٍ قُوَّةً'
    },
    {
      'title': 'مذنب',
      'emoji': '😞',
      'color': Colors.teal,
      'dua':
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
      'verse':
          'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ'
    },
    {
      'title': 'يائس',
      'emoji': '😩',
      'color': Colors.cyan,
      'dua':
          'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ',
      'verse':
          'وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ ۖ إِنَّهُ لَا يَيْأَسُ مِن رَّوْحِ اللَّهِ إِلَّا الْقَوْمُ الْكَافِرُونَ'
    },
    {
      'title': 'سعيد',
      'emoji': '😊',
      'color': Colors.green,
      'dua': 'الْحَمْدُ لِلَّهِ الَّذِي بِنِعْمَتِهِ تَتِمُّ الصَّالِحَاتُ',
      'verse': 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ'
    },
    {
      'title': 'ممتن',
      'emoji': '🥰',
      'color': Colors.lightGreen,
      'dua':
          'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ، وَشُكْرِكَ، وَحُسْنِ عِبَادَتِكَ',
      'verse': 'وَإِذْ تَأَذَّنَ رَبُّكُمْ لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    const primaryColor = Color(0xff137058); // app's primary color

    // Check if we have an active selection
    final selectedEmotion =
        _selectedIndex != null ? _emotions[_selectedIndex!] : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xff16201B), // Deep spiritual dark green-grey hue
                  const Color(0xff0E1412),
                ]
              : [
                  const Color(
                      0xffF2FAF7), // Elegant and soft primary mint-white gradient
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.04)
              : primaryColor.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.4)
                : primaryColor.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Beating/pulsing heart icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.redAccent.withOpacity(0.12)
                            : Colors.redAccent.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    )
                        .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true))
                        .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.15, 1.15),
                            duration: 1000.ms,
                            curve: Curves.easeInOut),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'كيف حال قلبك اليوم؟',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'شارِكنا شعورك لِنُواسيكَ بالآياتِ والأدعيةِ',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Cairo',
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Soft clear button if selected
                if (_selectedIndex != null)
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedIndex = null;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'إعادة تعيين',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white38 : Colors.grey[600],
                      ),
                    ),
                  ).animate().fadeIn(),
              ],
            ),
          ),

          // Emotion Selectors List
          SizedBox(
            height: 180,
            child: ShaderMask(
              shaderCallback: (Rect rect) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    isDarkMode ? const Color(0xff16201B) : const Color(0xffF2FAF7),
                    Colors.transparent,
                    Colors.transparent,
                    isDarkMode ? const Color(0xff0E1412) : Colors.white,
                  ],
                  stops: const [0.0, 0.05, 0.95, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstOut,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                child: Wrap(
                  direction: Axis.vertical,
                  spacing: 0,
                  runSpacing: 0,
                  children: List.generate(_emotions.length, (index) {
                    final emotion = _emotions[index];
                    final Color emotionColor = emotion['color'] as Color;
                    final bool isSelected = _selectedIndex == index;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedIndex = isSelected ? null : index;
                          });
                        },
                        borderRadius: BorderRadius.circular(22),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 78,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      emotionColor,
                                      emotionColor.withOpacity(0.8),
                                    ],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : isDarkMode
                                    ? Colors.white.withOpacity(0.03)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected
                                  ? emotionColor.withOpacity(0.8)
                                  : isDarkMode
                                      ? Colors.white.withOpacity(0.06)
                                      : Colors.black.withOpacity(0.04),
                              width: isSelected ? 2 : 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: emotionColor.withOpacity(0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.01),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Emoji inside circular badge
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : isDarkMode
                                          ? emotionColor.withOpacity(0.12)
                                          : emotionColor.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  emotion['emoji'] as String,
                                  style: const TextStyle(fontSize: 22),
                                ).animate(target: isSelected ? 1.0 : 0.0)
                                 .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                 .scale(
                                    begin: const Offset(0.9, 0.9),
                                    end: const Offset(1.1, 1.1),
                                    curve: Curves.easeInOut,
                                    duration: 2000.ms),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                emotion['title'] as String,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // Expanded Solace Card
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1.0,
                    child: child,
                  ),
                );
              },
              child: selectedEmotion == null
                  ? const SizedBox.shrink()
                  : _buildSolaceCard(context, selectedEmotion, isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolaceCard(
      BuildContext context, Map<String, dynamic> emotion, bool isDarkMode) {
    final Color emotionColor = emotion['color'] as Color;

    return Container(
      key: ValueKey<String>(emotion['title'] as String),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant separator line
          Container(
            height: 1,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  emotionColor.withOpacity(0.0),
                  emotionColor.withOpacity(0.3),
                  emotionColor.withOpacity(0.0),
                ],
              ),
            ),
          ),

          // Solace header with a custom warm message
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: emotionColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'طمأنينة لقلبك الـ${emotion['title']}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: emotionColor,
                ),
              ),
            ],
          ).animate().fadeIn().slideX(begin: 0.1, end: 0),
          const SizedBox(height: 16),

          // Quran Verse Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? emotionColor.withOpacity(0.06)
                  : emotionColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkMode
                    ? emotionColor.withOpacity(0.12)
                    : emotionColor.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Decorative icon/header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_outline_rounded,
                      size: 14,
                      color: emotionColor.withOpacity(0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'مواساة قرآنية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.star_outline_rounded,
                      size: 14,
                      color: emotionColor.withOpacity(0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Quran verse text
                Text(
                  '﴿ ${emotion['verse']} ﴾',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    height: 1.8,
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.95)
                        : Colors.black87,
                    shadows: isDarkMode
                        ? [
                            Shadow(
                              color: emotionColor.withOpacity(0.2),
                              blurRadius: 10,
                            )
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),
          const SizedBox(height: 12),

          // Prophet's Dua Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.02)
                  : Colors.black.withOpacity(0.01),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.03),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 16,
                      color: isDarkMode ? Colors.white38 : Colors.black45,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'دعاء يُريح القلب',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  emotion['dua'] as String,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    height: 1.7,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.85)
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0),
          const SizedBox(height: 18),

          // Actions Toolbar
          Row(
            children: [
              // Copy Button
              Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _copyEmotionText(context, emotion);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.04)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.06)
                            : Colors.black.withOpacity(0.03),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'نسخ',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Share Button
              Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _shareEmotionText(context, emotion);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.04)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.06)
                            : Colors.black.withOpacity(0.03),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share_rounded,
                          size: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'مشاركة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Immersive Meditative Sheet Button ("أرح قلبي")
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showEmotionBottomSheet(context, emotion);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          emotionColor,
                          emotionColor.withOpacity(0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: emotionColor.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.spa_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'أرِحْ قلبي كلياً',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  void _copyEmotionText(BuildContext context, Map<String, dynamic> emotion) {
    final String textToCopy =
        'مواساة قرآنية:\n﴿ ${emotion['verse']} ﴾\n\nدعاء يريح قلبك:\n« ${emotion['dua']} »\n\nتمت المشاركة من تطبيق صراط 🌿';
    Clipboard.setData(ClipboardData(text: textToCopy));

    // Show a beautiful modern snackbar with custom styling
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'تم نسخ طمأنينة القلب لـ ${emotion['title']} 💛',
              style: const TextStyle(
                  fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: emotion['color'] as Color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareEmotionText(BuildContext context, Map<String, dynamic> emotion) {
    final String textToShare =
        'مواساة قرآنية:\n﴿ ${emotion['verse']} ﴾\n\nدعاء يريح قلبك:\n« ${emotion['dua']} »\n\nتمت المشاركة من تطبيق صراط 🌿';
    Share.share(textToShare);
  }

  void _showEmotionBottomSheet(
      BuildContext context, Map<String, dynamic> emotion) {
    final Color emotionColor = emotion['color'] as Color;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 16, bottom: 32),
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? const Color(0xff141B18).withOpacity(0.92)
                      : Colors.white.withOpacity(0.95),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(36)),
                  border: Border.all(
                    color: widget.isDarkMode
                        ? Colors.white.withOpacity(0.08)
                        : emotionColor.withOpacity(0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 40,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top drag handle
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? Colors.white24
                              : Colors.black12,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Floating Meditative Glowing Emoji Orb
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: emotionColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: emotionColor.withOpacity(0.25),
                              blurRadius: 35,
                              spreadRadius: 3,
                            )
                          ],
                          border: Border.all(
                            color: emotionColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          emotion['emoji'] as String,
                          style: const TextStyle(fontSize: 48),
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1),
                              duration: 1500.ms,
                              curve: Curves.easeInOut)
                          .shimmer(delay: 500.ms, duration: 1800.ms),
                      const SizedBox(height: 20),

                      // Emotion Title
                      Text(
                        'طمأنينة لقلبك الـ${emotion['title']}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),

                      // Soft spiritual subtitle
                      const SizedBox(height: 6),
                      Text(
                        '« إِنَّ مَعَ الْعُسْرِ يُسْرًا »',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Amiri',
                          fontStyle: FontStyle.italic,
                          color: emotionColor,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 24),
                      // Breathing Text
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: emotionColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'تنفّس بعمق...',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: emotionColor.withOpacity(0.8),
                          ),
                        )
                            .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true))
                            .fadeIn(duration: 1500.ms)
                            .fadeOut(duration: 1500.ms, delay: 500.ms),
                      ),
                      const SizedBox(height: 32),

                      // Quran Solace Card (Meditation style)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: widget.isDarkMode
                                ? [
                                    emotionColor.withOpacity(0.1),
                                    Colors.white.withOpacity(0.01),
                                  ]
                                : [
                                    emotionColor.withOpacity(0.05),
                                    Colors.white,
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: widget.isDarkMode
                                ? Colors.white.withOpacity(0.06)
                                : emotionColor.withOpacity(0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star_rounded,
                                    size: 14, color: emotionColor),
                                const SizedBox(width: 6),
                                Text(
                                  'الآية الكريمة',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                    color: emotionColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.star_rounded,
                                    size: 14, color: emotionColor),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '﴿ ${emotion['verse']} ﴾',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'Amiri',
                                height: 1.8,
                                color: widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 16),

                      // Prophet's Dua Card (Meditation style)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? Colors.white.withOpacity(0.02)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: widget.isDarkMode
                                ? Colors.white.withOpacity(0.04)
                                : Colors.black.withOpacity(0.03),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.spa_outlined,
                                    size: 16,
                                    color: widget.isDarkMode
                                        ? Colors.white38
                                        : Colors.black45),
                                const SizedBox(width: 8),
                                Text(
                                  'الدعاء المبارك',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                    color: widget.isDarkMode
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              emotion['dua'] as String,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Cairo',
                                height: 1.7,
                                fontWeight: FontWeight.w500,
                                color: widget.isDarkMode
                                    ? Colors.white.withOpacity(0.85)
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 28),

                      // Modal Actions Row
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _copyEmotionText(context, emotion),
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: const Text('نسخ',
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.isDarkMode
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.grey[200],
                                foregroundColor: widget.isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: widget.isDarkMode
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.05),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _shareEmotionText(context, emotion),
                              icon: const Icon(Icons.share_rounded, size: 18),
                              label: const Text('مشاركة',
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.isDarkMode
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.grey[200],
                                foregroundColor: widget.isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: widget.isDarkMode
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.05),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('آمين يا رب',
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: emotionColor,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: emotionColor.withOpacity(0.3),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
