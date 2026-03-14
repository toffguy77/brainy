import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Результат'),
      ),
      body: const Center(
        child: Text(
          'Result Screen',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
