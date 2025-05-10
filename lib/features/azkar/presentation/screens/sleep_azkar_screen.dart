import 'package:flutter/material.dart';
import '../../domain/azkar_model.dart';
import '../../data/azkar_repository.dart';
import '../widgets/azkar_card.dart';

class SleepAzkarScreen extends StatefulWidget {
  const SleepAzkarScreen({Key? key}) : super(key: key);

  @override
  State<SleepAzkarScreen> createState() => _SleepAzkarScreenState();
}

class _SleepAzkarScreenState extends State<SleepAzkarScreen> {
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

      final azkar = await _azkarRepository.getSleepAzkar();

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
        title: const Text('أذكار النوم'),
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
                    final azkar = _azkar[index];
                    return AzkarCard(
                      text: azkar.text,
                      count: azkar.count,
                      benefit: azkar.benefit,
                      category: azkar.category,
                    );
                  },
                ),
    );
  }
}
