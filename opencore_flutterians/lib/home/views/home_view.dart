import 'package:flutter/material.dart';

import '../home_theme.dart';
import 'home_pressable.dart';
import 'home_welcome_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);

    return ColoredBox(
      color: colors.surfaceBase,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HomePressable(
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.menu, color: colors.textPrimary),
                  ),
                ),
                HomePressable(
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.add, color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: HomeWelcomeView()),
        ],
      ),
    );
  }
}
