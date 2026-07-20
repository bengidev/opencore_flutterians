import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home_orb/home_orb_view.dart';
import '../home_theme.dart';
import '../home_tokens.dart';
import 'home_welcome_layout.dart';

class HomeWelcomeView extends StatelessWidget {
  const HomeWelcomeView({super.key, this.orbActive = true});

  final bool orbActive;

  static const _horizontalPad = 4.0;

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = (constraints.maxWidth - (_horizontalPad * 2))
            .clamp(0.0, double.infinity);
        final textBlockHeight = _measureTextBlockHeight(
          maxWidth: maxWidth,
          textScaler: textScaler,
          colors: colors,
        );
        final metrics = HomeWelcomeLayoutMetrics.resolve(
          constraints.maxHeight,
          textBlockHeight: textBlockHeight,
        );
        final contentHeight = metrics.topSpacerMinLength +
            metrics.orbHeight +
            metrics.orbBottomPadding +
            textBlockHeight +
            metrics.bottomSpacerMinLength;
        final needsScroll = contentHeight > constraints.maxHeight + 0.5;

        final column = Column(
          children: [
            if (needsScroll)
              SizedBox(height: metrics.topSpacerMinLength)
            else
              Flexible(child: SizedBox(height: metrics.topSpacerMinLength)),
            SizedBox(
              key: const Key('homeOrbSlot'),
              height: metrics.orbHeight,
              width: double.infinity,
              child: HomeOrbView(active: orbActive),
            ),
            SizedBox(height: metrics.orbBottomPadding),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _horizontalPad),
              child: _GreetingCopy(colors: colors),
            ),
            if (needsScroll)
              SizedBox(height: metrics.bottomSpacerMinLength)
            else
              Flexible(child: SizedBox(height: metrics.bottomSpacerMinLength)),
          ],
        );

        if (!needsScroll) return column;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: column,
          ),
        );
      },
    );
  }

  static double _measureTextBlockHeight({
    required double maxWidth,
    required TextScaler textScaler,
    required HomeColors colors,
  }) {
    final greeting = TextPainter(
      text: TextSpan(
        text: HomeTokens.greeting,
        style: GoogleFonts.spaceMono(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.1,
          color: colors.textPrimary,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 3,
    )..layout(maxWidth: maxWidth);

    final lineStyle = GoogleFonts.spaceMono(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 1.2,
      color: colors.textSecondary,
    );

    final line1 = TextPainter(
      text: TextSpan(text: HomeTokens.encryptionLine1, style: lineStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 2,
    )..layout(maxWidth: maxWidth);

    final line2 = TextPainter(
      text: TextSpan(text: HomeTokens.encryptionLine2, style: lineStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 2,
    )..layout(maxWidth: maxWidth);

    // 4px gap between greeting and encryption lines.
    return greeting.height + 4 + line1.height + line2.height;
  }
}

class _GreetingCopy extends StatelessWidget {
  const _GreetingCopy({required this.colors});

  final HomeColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          HomeTokens.greeting,
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.spaceMono(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.1,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          HomeTokens.encryptionLine1,
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.spaceMono(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            height: 1.2,
            color: colors.textSecondary,
          ),
        ),
        Text(
          HomeTokens.encryptionLine2,
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.spaceMono(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            height: 1.2,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
