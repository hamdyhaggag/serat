import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_app_bar.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';

class ZakahCalculatorScreen extends StatefulWidget {
  const ZakahCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<ZakahCalculatorScreen> createState() => _ZakahCalculatorScreenState();
}

class _ZakahCalculatorScreenState extends State<ZakahCalculatorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _cashController = TextEditingController();
  final _goldController = TextEditingController();
  final _silverController = TextEditingController();
  final _stocksController = TextEditingController();
  final _businessController = TextEditingController();
  final _otherAssetsController = TextEditingController();
  final _debtsController = TextEditingController();

  double _totalZakah = 0;
  bool _showResults = false;
  bool _nisabNotMet = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const double _nisabCash = 595 * 0.5;
  static const double _zakahRate = 0.025;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  void _showResultModal(double zakahValue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 30,
            left: 20,
            right: 20,
            bottom: 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF00A19D),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'مقدار الزكاة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DIN',
                  color: Color(0xFF00A19D),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${zakahValue.toStringAsFixed(0)} جنيه',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DIN',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A19D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'حساب قيمة أخرى',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'DIN',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _calculateZakah() {
    if (!_formKey.currentState!.validate()) return;

    double totalAssets = 0;
    totalAssets += double.tryParse(_cashController.text) ?? 0;
    totalAssets += (double.tryParse(_goldController.text) ?? 0) * 2000;
    totalAssets += (double.tryParse(_silverController.text) ?? 0) * 25;
    totalAssets += double.tryParse(_stocksController.text) ?? 0;
    totalAssets += double.tryParse(_businessController.text) ?? 0;
    totalAssets += double.tryParse(_otherAssetsController.text) ?? 0;
    double debts = double.tryParse(_debtsController.text) ?? 0;
    totalAssets -= debts;

    if (totalAssets < _nisabCash) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(
              top: 30,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'لا تجب الزكاة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DIN',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'يرجى استشارة عالم شرعي للتأكد من صحة الحساب.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'DIN',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'حساب قيمة أخرى',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DIN',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
      return;
    }

    _showResultModal(totalAssets * _zakahRate);
  }

  @override
  void dispose() {
    _cashController.dispose();
    _goldController.dispose();
    _silverController.dispose();
    _stocksController.dispose();
    _businessController.dispose();
    _otherAssetsController.dispose();
    _debtsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA);
    final cardColor = isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final hintColor =
        isDarkMode ? Colors.grey[400] ?? Colors.grey : const Color(0xFFCCCCCC);
    final borderColor =
        isDarkMode ? Colors.grey[700] ?? Colors.grey : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(title: 'حاسبة الزكاة', isHome: false),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'حاسبة الزكاة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'DIN',
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'يجب مراعاة الشروط الاسلامية عند حساب الزكاة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontFamily: 'DIN',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildInputField(
                          label: 'النقود',
                          controller: _cashController,
                          example: '( 250.000 جنيه )',
                          icon: Icons.money,
                          isDarkMode: isDarkMode,
                          cardColor: cardColor,
                          textColor: textColor,
                          hintColor: hintColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          label: 'الذهب (غرام)',
                          controller: _goldController,
                          example: '( 100 غرام )',
                          icon: Icons.monetization_on,
                          isDarkMode: isDarkMode,
                          cardColor: cardColor,
                          textColor: textColor,
                          hintColor: hintColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          label: 'الفضة (غرام)',
                          controller: _silverController,
                          example: '( 1000 غرام )',
                          icon: Icons.monetization_on_outlined,
                          isDarkMode: isDarkMode,
                          cardColor: cardColor,
                          textColor: textColor,
                          hintColor: hintColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          label: 'الأسهم',
                          controller: _stocksController,
                          example: '( 250.000 جنيه )',
                          icon: Icons.show_chart,
                          isDarkMode: isDarkMode,
                          cardColor: cardColor,
                          textColor: textColor,
                          hintColor: hintColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          label: 'الأعمال التجارية',
                          controller: _businessController,
                          example: '( 250.000 جنيه )',
                          icon: Icons.business,
                          isDarkMode: isDarkMode,
                          cardColor: cardColor,
                          textColor: textColor,
                          hintColor: hintColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          label: 'أصول أخرى',
                          controller: _otherAssetsController,
                          example: '( 250.000 جنيه )',
                          icon: Icons.category,
                          isDarkMode: isDarkMode,
                          cardColor: cardColor,
                          textColor: textColor,
                          hintColor: hintColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          label: 'الديون',
                          controller: _debtsController,
                          example: '( 250.000 جنيه )',
                          icon: Icons.credit_card,
                          isDarkMode: isDarkMode,
                          cardColor: cardColor,
                          textColor: textColor,
                          hintColor: hintColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.3,
                                  ),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _calculateZakah,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'احسب الزكاة',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'DIN',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String example,
    required IconData icon,
    required bool isDarkMode,
    required Color cardColor,
    required Color textColor,
    required Color? hintColor,
    required Color borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'DIN',
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: example,
              hintStyle: TextStyle(
                color: hintColor,
                fontSize: 14,
                fontFamily: 'DIN',
              ),
              suffixIcon: Icon(icon, color: AppColors.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              fillColor: cardColor,
              filled: true,
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator:
                (value) =>
                    (value == null || value.isEmpty)
                        ? 'الرجاء إدخال قيمة'
                        : null,
            style: TextStyle(fontFamily: 'DIN', fontSize: 14, color: textColor),
          ),
        ],
      ),
    );
  }
}
