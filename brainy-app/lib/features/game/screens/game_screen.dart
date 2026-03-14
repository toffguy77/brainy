import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Игра'),
      ),
      body: const Center(
        child: Text(
          'Game Screen',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
