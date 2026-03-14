import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Родитель'),
      ),
      body: const Center(
        child: Text(
          'Parent Screen',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
