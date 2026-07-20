import 'package:flutter/material.dart';
import '../home_tokens.dart';

class HomePressable extends StatefulWidget {
  const HomePressable({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<HomePressable> createState() => _HomePressableState();
}

class _HomePressableState extends State<HomePressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown:
          widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? HomeTokens.pressScale : 1,
        duration: HomeTokens.durationPress,
        curve: HomeTokens.easeOut,
        child: widget.child,
      ),
    );
  }
}
