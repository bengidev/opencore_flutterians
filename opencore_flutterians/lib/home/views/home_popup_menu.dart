import 'package:flutter/material.dart';

import '../home_theme.dart';
import '../home_tokens.dart';

Future<T?> showHomePopupMenu<T>({
  required BuildContext context,
  required List<PopupMenuEntry<T>> entries,
}) {
  final box = context.findRenderObject()! as RenderBox;
  final overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
  final bottomRight = box.localToGlobal(
    box.size.bottomRight(Offset.zero),
    ancestor: overlay,
  );
  final position = RelativeRect.fromRect(
    Rect.fromPoints(topLeft, bottomRight),
    Offset.zero & overlay.size,
  );
  final colors = HomeColors.of(context);

  return showMenu<T>(
    context: context,
    position: position,
    color: colors.surfaceRaised,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(HomeTokens.radius),
      side: BorderSide(color: colors.border),
    ),
    items: entries,
  );
}
