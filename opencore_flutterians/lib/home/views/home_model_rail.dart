import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home_theme.dart';
import '../home_tokens.dart';
import 'home_popup_menu.dart';
import 'home_pressable.dart';

class HomeModelRail extends StatelessWidget {
  const HomeModelRail({
    super.key,
    required this.modelLabel,
    required this.speedLabel,
    required this.onModelSelected,
    required this.onSpeedSelected,
  });

  final String modelLabel;
  final String speedLabel;
  final ValueChanged<String> onModelSelected;
  final ValueChanged<String> onSpeedSelected;

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);

    return Row(
      children: [
        Flexible(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Builder(
              builder: (chipContext) {
                return HomePressable(
                  onPressed: () async {
                    final choice = await showHomePopupMenu<String>(
                      context: chipContext,
                      entries: [
                        for (final title in HomeTokens.stubModelTitles)
                          PopupMenuItem(value: title, child: Text(title)),
                      ],
                    );
                    if (choice != null) {
                      onModelSelected(choice);
                    }
                  },
                  child: _RailChip(label: modelLabel, colors: colors),
                );
              },
            ),
          ),
        ),
        Builder(
          builder: (chipContext) {
            return HomePressable(
              onPressed: () async {
                final choice = await showHomePopupMenu<String>(
                  context: chipContext,
                  entries: [
                    for (final title in HomeTokens.stubSpeedTitles)
                      PopupMenuItem(value: title, child: Text(title)),
                  ],
                );
                if (choice != null) {
                  onSpeedSelected(choice);
                }
              },
              child: _RailChip(label: speedLabel, colors: colors),
            );
          },
        ),
        const SizedBox(width: 8),
        HomePressable(
          onPressed: () {
            HapticFeedback.selectionClick();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text(HomeTokens.snackbarContext)),
              );
          },
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(HomeTokens.radiusControl),
              border: Border.all(color: colors.border),
            ),
            child: Text(
              HomeTokens.contextLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
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
        borderRadius: BorderRadius.circular(HomeTokens.radiusControl),
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
