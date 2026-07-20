import 'package:flutter/material.dart';
import '../home_theme.dart';

class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);
    return SafeArea(
      bottom: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
