import 'package:flutter/material.dart';

class QasasScreen extends StatefulWidget {
  const QasasScreen({super.key});

  @override
  State<QasasScreen> createState() => _QasasScreenState();
}

class _QasasScreenState extends State<QasasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قصص'),
      ),
      body: const Center(
        child: Text('قصص'),
      ),
    );
  }
}
