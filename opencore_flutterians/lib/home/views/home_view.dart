import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home_theme.dart';
import '../home_tokens.dart';
import 'home_composer_view.dart';
import 'home_model_rail.dart';
import 'home_popup_menu.dart';
import 'home_pressable.dart';
import 'home_welcome_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, this.orbActive = true});

  final bool orbActive;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _draft = TextEditingController();
  var _modelLabel = HomeTokens.modelTitle;
  var _speedLabel = HomeTokens.speedTitle;

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return ColoredBox(
      color: colors.surfaceBase,
      child: SafeArea(
        // Tab bar already insets the bottom (home indicator).
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (menuContext) {
                      return HomePressable(
                        key: const Key('homeMenuButton'),
                        onPressed: () async {
                          final choice = await showHomePopupMenu<String>(
                            context: menuContext,
                            entries: [
                              for (final title in HomeTokens.stubChatTitles)
                                PopupMenuItem(
                                  value: title,
                                  child: Text(title),
                                ),
                            ],
                          );
                          if (choice == null) return;
                          HapticFeedback.lightImpact();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.menu, color: colors.textPrimary),
                        ),
                      );
                    },
                  ),
                  HomePressable(
                    key: const Key('homeNewChatButton'),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _draft.clear();
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text(HomeTokens.snackbarNewChat),
                          ),
                        );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.add, color: colors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: HomeWelcomeView(orbActive: widget.orbActive)),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8 + keyboardInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HomeComposerView(controller: _draft),
                  const SizedBox(height: 10),
                  HomeModelRail(
                    modelLabel: _modelLabel,
                    speedLabel: _speedLabel,
                    onModelSelected: (v) => setState(() => _modelLabel = v),
                    onSpeedSelected: (v) => setState(() => _speedLabel = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
