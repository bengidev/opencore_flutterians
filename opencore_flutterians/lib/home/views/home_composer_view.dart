import 'package:flutter/material.dart';

import '../home_theme.dart';
import '../home_tokens.dart';
import 'home_pressable.dart';

class HomeComposerView extends StatelessWidget {
  const HomeComposerView({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(HomeTokens.radiusComposer),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: HomeTokens.composerHint,
                hintStyle: TextStyle(color: colors.textTertiary, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              maxLines: 4,
              minLines: 1,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                HomePressable(
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.add, color: colors.textSecondary, size: 22),
                  ),
                ),
                const Spacer(),
                HomePressable(
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.mic, color: colors.textSecondary, size: 22),
                  ),
                ),
                const SizedBox(width: 4),
                HomePressable(
                  onPressed: () {},
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.textPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_upward, color: colors.surfaceBase, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
