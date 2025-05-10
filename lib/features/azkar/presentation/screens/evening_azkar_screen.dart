import 'package:flutter/material.dart';
import '../../domain/azkar_model.dart';
import '../../data/azkar_repository.dart';
import '../widgets/azkar_card.dart';

class EveningAzkarScreen extends StatefulWidget {
  const EveningAzkarScreen({Key? key}) : super(key: key);

  @override
  State<EveningAzkarScreen> createState() => _EveningAzkarScreenState();
}

class _EveningAzkarScreenState extends State<EveningAzkarScreen> {
  final AzkarRepository _azkarRepository = AzkarRepository();
  List<Azkar> _azkar = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAzkar();
  }

  Future<void> _loadAzkar() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final azkar = await _azkarRepository.getEveningAzkar();

      setState(() {
        _azkar = azkar;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أذكار المساء'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'حدث خطأ: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAzkar,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _azkar.length,
                  itemBuilder: (context, index) {
                    final zikr = _azkar[index];
                    return AzkarCard(
                      text: zikr.text,
                      count: zikr.count,
                      benefit: zikr.benefit,
                      category: zikr.category,
                    );
                  },
                ),
    );
  }
}
