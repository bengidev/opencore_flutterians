import 'package:flutter/material.dart';

import '../home_theme.dart';
import '../home_tokens.dart';

class HomeModelRail extends StatelessWidget {
  const HomeModelRail({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);

    return Row(
      children: [
        Expanded(
          child: _RailChip(
            label: HomeTokens.modelTitle,
            colors: colors,
          ),
        ),
        const SizedBox(width: 8),
        _RailChip(
          label: HomeTokens.speedTitle,
          colors: colors,
        ),
        const SizedBox(width: 8),
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.border),
          ),
          child: Text(
            HomeTokens.contextLabel,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _RailChip extends StatelessWidget {
  const _RailChip({required this.label, required this.colors});

  final String label;
  final HomeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(HomeTokens.radiusPill),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
