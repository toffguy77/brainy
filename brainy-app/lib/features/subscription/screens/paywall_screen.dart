import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Premium'),
      ),
      body: const Center(
        child: Text(
          'Paywall Screen',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
