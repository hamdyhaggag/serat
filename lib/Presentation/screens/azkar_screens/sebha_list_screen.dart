import 'package:flutter/material.dart';
import 'package:serat/Presentation/Widgets/Shared/custom_reset_button.dart'
    show AppButton;

import 'package:serat/imports.dart';

final ValueNotifier<List<AzkarItem>> azkarNotifier = ValueNotifier([]);

class SebhaAzkarListScreen extends StatefulWidget {
  const SebhaAzkarListScreen({super.key});

  @override
  State<SebhaAzkarListScreen> createState() => _SebhaAzkarListScreenState();
}

class _SebhaAzkarListScreenState extends State<SebhaAzkarListScreen> {
  final _service = SebhaAzkarService();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAzkarItems();
  }

  Future<void> _loadAzkarItems() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final items = await _service.loadAzkarItems();
      azkarNotifier.value = items;
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ أثناء تحميل الأذكار';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1F1F1F) : Colors.white,
      appBar: const CustomAppBar(title: 'السبحة الإلكترونية', isHome: true),
      body: _buildBody(),
      persistentFooterButtons: [
        AppButton(
          horizontalPadding: 20.w,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAzkarScreen()),
            );
            _loadAzkarItems();
          },
          title: 'إضافة ذكر',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAzkarItems,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return ValueListenableBuilder<List<AzkarItem>>(
      valueListenable: azkarNotifier,
      builder: (context, azkar, child) {
        if (azkar.isEmpty) {
          return const Center(child: Text('لا توجد أذكار مضافة'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: azkar.length,
          itemBuilder: (context, index) {
            final item = azkar[index];
            return SebhaListItem(
              item: item,
              index: index,
              onDelete: () async {
                try {
                  await _service.removeAzkarItem(item.text);
                  _loadAzkarItems();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('حدث خطأ أثناء حذف الذكر'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
