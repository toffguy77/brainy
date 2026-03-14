import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class BrainyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const BrainyCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
