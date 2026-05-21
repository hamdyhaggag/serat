import 'package:flutter/material.dart';
import 'package:serat/features/quran_reader/screens/professional_quran_screen.dart';

class QuranScreen extends StatelessWidget {
  final int? initialPage;
  
  const QuranScreen({super.key, this.initialPage});

  @override
  Widget build(BuildContext context) {
    // The ProfessionalQuranScreen from quran_library creates a full-featured
    // Quran reader experience. It includes:
    // 1. A complete Index (Surahs, Juz, Hizb)
    // 2. Powerful Search functionality
    // 3. Bookmarks management
    // 4. Exact Madinah Mushaf rendering
    //
    // By returning this directly, we replace the custom list with the
    // professional, built-in tools provided by the library.
    return ProfessionalQuranScreen(initialPage: initialPage);
  }
}
