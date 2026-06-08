import 'package:flutter/material.dart';

class FormHeaderIcon extends StatelessWidget {
  final IconData icon;

  const FormHeaderIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF0F766E).withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 48,
          color: const Color(0xFF0F766E),
        ),
      ),
    );
  }
}
