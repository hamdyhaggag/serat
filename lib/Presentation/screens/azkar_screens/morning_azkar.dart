// import 'package:flutter/material.dart';
// import 'package:serat/imports.dart';

// class MorningAzkar extends StatefulWidget {
//   final String title;

//   const MorningAzkar({super.key, required this.title});

//   @override
//   State<MorningAzkar> createState() => _MorningAzkarState();
// }

// class _MorningAzkarState extends State<MorningAzkar> {
//   final List<Map<String, dynamic>> _morningAzkar = [
//     {
//       "text":
//           "أَعُوذُ بِاللهِ مِنَ الشَّيْطَانِ الرَّجِيمِ\nاللّهُ لاَ إِلَـهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلاَّ بِمَا شَاء وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالأَرْضَ وَلاَ يَؤُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ",
//       "count": 1,
//       "benefit":
//           "من قالها حين يصبح أجير من الجن حتى يمسى ومن قالها حين يمسى أجير من الجن حتى يصبح",
//     },
//     {
//       "text":
//           "بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلْ هُوَ اللَّهُ أَحَدٌ، اللَّهُ الصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ",
//       "count": 3,
//       "benefit": "من قالها حين يصبح وحين يمسى كفته من كل شىء",
//     },
//     {
//       "text":
//           "بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ، مِن شَرِّ مَا خَلَقَ، وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ، وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ، وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ",
//       "count": 3,
//       "benefit": "من قالها حين يصبح وحين يمسى كفته من كل شىء",
//     },
//     {
//       "text":
//           "بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ، مَلِكِ النَّاسِ، إِلَهِ النَّاسِ، مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ، الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ، مِنَ الْجِنَّةِ وَ النَّاسِ",
//       "count": 3,
//       "benefit": "من قالها حين يصبح وحين يمسى كفته من كل شىء",
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.grey[50],
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         title: Text(
//           widget.title,
//           style: TextStyle(
//             fontSize: 24,
//             fontFamily: 'DIN',
//             fontWeight: FontWeight.w700,
//             color: isDarkMode ? Colors.white : AppColors.primaryColor,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: isDarkMode ? Colors.white : AppColors.primaryColor,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: _morningAzkar.length,
//         itemBuilder: (context, index) {
//           final azkar = _morningAzkar[index];
//           return _buildAzkarCard(azkar, isDarkMode);
//         },
//       ),
//     );
//   }

//   Widget _buildAzkarCard(Map<String, dynamic> azkar, bool isDarkMode) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       color: isDarkMode ? const Color(0xff2D2D2D) : Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               azkar['text'],
//               style: TextStyle(
//                 fontSize: 18,
//                 fontFamily: 'DIN',
//                 color: isDarkMode ? Colors.white70 : Colors.black87,
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               azkar['benefit'],
//               style: TextStyle(
//                 fontSize: 14,
//                 fontFamily: 'DIN',
//                 color: isDarkMode ? Colors.white60 : Colors.black54,
//                 fontStyle: FontStyle.italic,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.remove_circle_outline),
//                   onPressed: () {
//                     setState(() {
//                       if (azkar['currentCount'] > 0) {
//                         azkar['currentCount'] =
//                             (azkar['currentCount'] ?? 0) - 1;
//                       }
//                     });
//                   },
//                   color: AppColors.primaryColor,
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.primaryColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '${azkar['currentCount'] ?? 0}/${azkar['count']}',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontFamily: 'DIN',
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.add_circle_outline),
//                   onPressed: () {
//                     setState(() {
//                       if ((azkar['currentCount'] ?? 0) < azkar['count']) {
//                         azkar['currentCount'] =
//                             (azkar['currentCount'] ?? 0) + 1;
//                       }
//                     });
//                   },
//                   color: AppColors.primaryColor,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
