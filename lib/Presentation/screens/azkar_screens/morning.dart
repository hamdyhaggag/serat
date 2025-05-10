import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:serat/features/azkar/domain/azkar_model.dart';
import 'package:serat/services/azkar_service.dart';

class MorningAzkar extends StatefulWidget {
  final String title;
  const MorningAzkar({super.key, required this.title});

  @override
  State<MorningAzkar> createState() => _MorningAzkarState();
}

class _MorningAzkarState extends State<MorningAzkar> {
  late Future<List<Azkar>> _azkarFuture;

  @override
  void initState() {
    super.initState();
    _loadAzkar();
  }

  void _loadAzkar() {
    setState(() {
      _azkarFuture = AzkarService().fetchMorningAzkar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: FutureBuilder<List<Azkar>>(
          future: _azkarFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${snapshot.error}',
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
              );
            }

            final azkar = snapshot.data ?? [];
            return AzkarModelView(
              title: widget.title,
              azkarList: azkar.map((zikr) => zikr.text).toList(),
              maxValues: azkar.map((zikr) => zikr.count).toList(),
              onRetry: _loadAzkar,
            );
          },
        ),
      ),
    );
  }
}
