import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home_theme.dart';
import '../home_tokens.dart';
import 'home_popup_menu.dart';
import 'home_pressable.dart';

class HomeComposerView extends StatefulWidget {
  const HomeComposerView({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<HomeComposerView> createState() => _HomeComposerViewState();
}

class _HomeComposerViewState extends State<HomeComposerView> {
  late final FocusNode _focusNode;
  var _focused = false;
  var _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant HomeComposerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
      _hasText = widget.controller.text.trim().isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    final next = _focusNode.hasFocus;
    if (next == _focused) return;
    setState(() => _focused = next);
  }

  void _onTextChanged() {
    final next = widget.controller.text.trim().isNotEmpty;
    if (next == _hasText) return;
    setState(() => _hasText = next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : HomeTokens.durationUi;
    final borderColor = _focused ? colors.textPrimary.withValues(alpha: 0.28) : colors.border;
    final fillColor = _focused ? colors.surfaceBase : colors.surfaceRaised;

    return AnimatedContainer(
      duration: duration,
      curve: HomeTokens.easeOut,
      constraints: const BoxConstraints(minHeight: HomeTokens.composerMinHeight),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(HomeTokens.radiusComposer),
        border: Border.all(color: borderColor),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: HomeTokens.composerHint,
                hintStyle: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              ),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w400,
              ),
              cursorColor: colors.textPrimary,
              cursorWidth: 1.5,
              maxLines: HomeTokens.composerMaxLines,
              minLines: HomeTokens.composerMinLines,
              textInputAction: TextInputAction.newline,
              keyboardAppearance: Brightness.light,
              scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom + 120,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Builder(
                  builder: (buttonContext) {
                    return _ComposerIconButton(
                      tooltip: 'Add attachment',
                      onPressed: () async {
                        final choice = await showHomePopupMenu<String>(
                          context: buttonContext,
                          entries: const [
                            PopupMenuItem(value: 'Photo', child: Text('Photo')),
                            PopupMenuItem(value: 'File', child: Text('File')),
                            PopupMenuItem(value: 'Camera', child: Text('Camera')),
                          ],
                        );
                        if (!buttonContext.mounted || choice == null) return;
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(content: Text(HomeTokens.snackbarAttachment(choice))));
                      },
                      child: _MutedGlyph(
                        colors: colors,
                        icon: Icons.add_rounded,
                      ),
                    );
                  },
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: duration,
                  switchInCurve: HomeTokens.easeOut,
                  switchOutCurve: HomeTokens.easeOut,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        ...previousChildren,
                        ?currentChild,
                      ],
                    );
                  },
                  transitionBuilder: (child, animation) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: HomeTokens.easeOut,
                    );
                    return FadeTransition(
                      opacity: curved,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1).animate(curved),
                        child: child,
                      ),
                    );
                  },
                  child: _hasText
                      ? _ComposerIconButton(
                          key: const ValueKey('send'),
                          tooltip: 'Send',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            widget.controller.clear();
                            _focusNode.unfocus();
                          },
                          child: _SendGlyph(colors: colors),
                        )
                      : _ComposerIconButton(
                          key: const ValueKey('mic'),
                          tooltip: 'Voice input',
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(const SnackBar(content: Text(HomeTokens.snackbarVoiceSoon)));
                          },
                          child: _MutedGlyph(
                            colors: colors,
                            icon: Icons.mic_none_rounded,
                          ),
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

class _ComposerIconButton extends StatelessWidget {
  const _ComposerIconButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.tooltip,
  });

  final VoidCallback onPressed;
  final Widget child;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: HomePressable(
        onPressed: onPressed,
        child: SizedBox(
          width: HomeTokens.hitTarget,
          height: HomeTokens.hitTarget,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _MutedGlyph extends StatelessWidget {
  const _MutedGlyph({required this.colors, required this.icon});

  final HomeColors colors;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: HomeTokens.composerActionSize,
      height: HomeTokens.composerActionSize,
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(HomeTokens.radiusControl),
      ),
      child: Icon(icon, color: colors.textSecondary, size: 20),
    );
  }
}

class _SendGlyph extends StatelessWidget {
  const _SendGlyph({required this.colors});

  final HomeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: HomeTokens.composerActionSize,
      height: HomeTokens.composerActionSize,
      decoration: BoxDecoration(
        color: colors.textPrimary,
        borderRadius: BorderRadius.circular(HomeTokens.radiusControl),
      ),
      child: Icon(
        Icons.arrow_upward_rounded,
        color: colors.surfaceBase,
        size: 18,
      ),
    );
  }
}
