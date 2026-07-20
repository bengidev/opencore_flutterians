import 'package:flutter/material.dart';

import '../home_theme.dart';
import 'home_composer_view.dart';
import 'home_model_rail.dart';
import 'home_pressable.dart';
import 'home_welcome_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _draft = TextEditingController();

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                HomeComposerView(controller: _draft),
                const SizedBox(height: 10),
                const HomeModelRail(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
