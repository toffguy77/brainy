import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Прогресс'),
      ),
      body: const Center(
        child: Text(
          'Progress Screen',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
