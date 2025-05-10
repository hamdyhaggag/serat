import 'package:flutter/material.dart';

class AzkarCard extends StatelessWidget {
  final String text;
  final int count;
  final String benefit;
  final String category;

  const AzkarCard({
    Key? key,
    required this.text,
    required this.count,
    required this.benefit,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              'عدد المرات: $count',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (benefit.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'الفضل: $benefit',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ],
            if (category.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'التصنيف: $category',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
