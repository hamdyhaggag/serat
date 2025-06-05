import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:serat/Features/NamesOfAllah/Data/Model/names_of_allah_model.dart';
import 'package:serat/Features/NamesOfAllah/Data/Model/text_scale_model.dart';
import 'package:serat/Features/NamesOfAllah/Business_Logic/Services/names_of_allah_service.dart';
import 'package:serat/Features/NamesOfAllah/Presentation/Widgets/name_card.dart';
import 'package:serat/Features/NamesOfAllah/Presentation/Widgets/text_size_slider.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart';
import 'package:shimmer/shimmer.dart';

class NamesOfAllahScreen extends StatefulWidget {
  const NamesOfAllahScreen({super.key});

  @override
  State<NamesOfAllahScreen> createState() => _NamesOfAllahScreenState();
}

class _NamesOfAllahScreenState extends State<NamesOfAllahScreen>
    with SingleTickerProviderStateMixin {
  List<NamesOfAllahModel> _names = [];
  bool _isLoading = true;
  double _textScale = 1.0;
  bool _showSlider = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadNames();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadNames() async {
    try {
      final names = await NamesOfAllahService.loadNamesOfAllah();
      if (mounted) {
        setState(() {
          _names = names;
          _isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showNameDetails(NamesOfAllahModel name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NameDetailsSheet(
        name: name,
        textScale: TextScaleModel.fromScale(_textScale),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textScaleModel = TextScaleModel.fromScale(_textScale);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.grey[50],
      appBar: CustomAppBar(
        title: 'أسماء الله الحسنى',
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              setState(() {
                _showSlider = !_showSlider;
              });
            },
            tooltip: 'تغيير حجم الخط',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            _buildShimmerLoading()
          else
            FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _names.length,
                itemBuilder: (context, index) {
                  final name = _names[index];
                  return NameCard(
                    name: name,
                    textScale: textScaleModel,
                    onTap: () => _showNameDetails(name),
                  );
                },
              ),
            ),
          if (_showSlider)
            Positioned(
              top: 16,
              right: 16,
              child: TextSizeSlider(
                value: _textScale,
                onChanged: (value) {
                  setState(() {
                    _textScale = value;
                  });
                },
                onClose: () {
                  setState(() {
                    _showSlider = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}

class NameDetailsSheet extends StatelessWidget {
  final NamesOfAllahModel name;
  final TextScaleModel textScale;

  const NameDetailsSheet({
    super.key,
    required this.name,
    required this.textScale,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  const Color(0xff2F2F2F),
                  const Color(0xff252525),
                ]
              : [
                  Colors.white,
                  Colors.grey[50]!,
                ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name.name,
                    style: TextStyle(
                      fontSize: textScale.detailNameScale,
                      fontFamily: 'Amiri',
                      color: isDarkMode ? Colors.white : AppColors.primaryColor,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    name.text,
                    style: TextStyle(
                      fontSize: textScale.detailDescriptionScale,
                      fontFamily: 'DIN',
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
