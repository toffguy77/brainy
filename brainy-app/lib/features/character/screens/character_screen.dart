import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Персонаж'),
      ),
      body: const Center(
        child: Text(
          'Character Screen',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
