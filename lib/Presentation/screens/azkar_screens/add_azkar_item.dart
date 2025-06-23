import 'package:flutter/material.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_reset_button.dart'
    show AppButton;
import 'package:serat/Presentation/screens/azkar_screens/sebha_list_screen.dart';
import 'package:serat/Presentation/Widgets/Azkar/sebha_azkar_service.dart';
import 'package:serat/imports.dart';

class AddAzkarScreen extends StatefulWidget {
  const AddAzkarScreen({super.key});

  @override
  AddAzkarScreenState createState() => AddAzkarScreenState();
}

class AddAzkarScreenState extends State<AddAzkarScreen>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _countController = TextEditingController();
  final _rewardController = TextEditingController();
  final _service = SebhaAzkarService();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _countController.dispose();
    _rewardController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<bool?> _showSuccessDialog(
      BuildContext context, String text, int count, String reward) {
    _animationController.forward();
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xff2C2C2C)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.primaryColor,
                    size: 50.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'تمت الإضافة بنجاح',
                  style: TextStyle(
                    fontFamily: 'DIN',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DIN',
                    fontSize: 16.sp,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey
                        : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.primaryColor, width: 1.5),
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.w, vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'العودة للقائمة',
                        style: TextStyle(
                          fontFamily: 'DIN',
                          fontSize: 16.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'بدء التسبيح',
                        style: TextStyle(
                          fontFamily: 'DIN',
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addAzkar() async {
    if (_formKey.currentState?.validate() ?? false) {
      final text = _textController.text;
      final count = int.tryParse(_countController.text) ?? 0;
      final reward = _rewardController.text;

      try {
        final newAzkar = AzkarItem(text: text, count: count, reward: reward);
        await _service.addAzkarItem(newAzkar);
        azkarNotifier.value = List.from(azkarNotifier.value)..add(newAzkar);
        await saveSebhaCounter(text, 0, 0, 0);

        if (mounted) {
          final result = await _showSuccessDialog(context, text, count, reward);
          if (result == true) {
            // Navigate to Sebha screen for this item
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Sebha(
                  title: text,
                  subtitle: reward,
                  beadCount: count,
                  maxCounter: count,
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'حدث خطأ أثناء حفظ الذكر',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DIN',
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              margin: EdgeInsets.all(10.w),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Colors.white : AppColors.primaryColor;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      appBar: const CustomAppBar(title: 'إضافة ذكر'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(isDarkMode),
                  SizedBox(height: 30.h),
                  _buildTextField(
                    controller: _textController,
                    label: 'نص الذكر',
                    hint: 'أدخل نص الذكر هنا',
                    maxLines: 3,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'يرجى إدخال نص الذكر';
                      }
                      return null;
                    },
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _countController,
                    label: 'عدد المرات',
                    hint: 'أدخل عدد مرات التكرار',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'يرجى إدخال عدد المرات';
                      }
                      final count = int.tryParse(value!);
                      if (count == null || count <= 0) {
                        return 'يرجى إدخال رقم صحيح أكبر من صفر';
                      }
                      return null;
                    },
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _rewardController,
                    label: 'ثواب الذكر',
                    hint: 'أدخل ثواب الذكر (اختياري)',
                    maxLines: 2,
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                  SizedBox(height: 40.h),
                  AppButton(
                    horizontalPadding: 20.w,
                    onPressed: _addAzkar,
                    title: 'إضافة',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Column(
      children: [
        Icon(
          Icons.add_circle_outline,
          size: 60.sp,
          color: isDarkMode ? Colors.white : AppColors.primaryColor,
        ),
        SizedBox(height: 16.h),
        Text(
          'إضافة ذكر جديد',
          style: TextStyle(
            fontFamily: 'DIN',
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.primaryColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'أدخل تفاصيل الذكر الذي تريد إضافته',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DIN',
            fontSize: 16.sp,
            color: isDarkMode ? Colors.grey : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDarkMode,
    required Color primaryColor,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontFamily: 'DIN',
        fontSize: 16.sp,
        color: isDarkMode ? Colors.white : AppColors.primaryColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          fontFamily: 'DIN',
          fontSize: 16.sp,
          color: primaryColor,
        ),
        hintStyle: TextStyle(
          fontFamily: 'DIN',
          fontSize: 14.sp,
          color: isDarkMode ? Colors.grey : Colors.grey[400],
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.black12 : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }
}
