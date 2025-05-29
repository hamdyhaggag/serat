import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:serat/features/azkar/domain/azkar_model.dart';

class GenericAzkarScreen extends StatelessWidget {
  final String title;
  final List<String> azkarList;
  final List<int> maxValues;
  final IconData icon;
  final VoidCallback? onRetry;
  final AzkarState? initialAzkarState;
  final void Function(AzkarState)? onProgressChanged;

  const GenericAzkarScreen({
    super.key,
    required this.title,
    required this.azkarList,
    required this.maxValues,
    required this.icon,
    this.onRetry,
    this.initialAzkarState,
    this.onProgressChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: title),
      body: BlocProvider(
        create: (context) => AzkarCubit(),
        child: AzkarModelView(
          title: title,
          azkarList: azkarList,
          maxValues: maxValues,
          onRetry: onRetry,
          initialAzkarState: initialAzkarState,
          onProgressChanged: onProgressChanged,
        ),
      ),
    );
  }
}
