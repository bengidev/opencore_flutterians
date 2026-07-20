import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home_theme.dart';
import '../home_tokens.dart';
import 'home_welcome_layout.dart';

class HomeWelcomeView extends StatelessWidget {
  const HomeWelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics =
            HomeWelcomeLayoutMetrics.resolve(constraints.maxHeight);

        return Column(
          children: [
            Flexible(
              child: SizedBox(height: metrics.topSpacerMinLength),
            ),
            SizedBox(
              key: const Key('homeOrbSlot'),
              height: metrics.orbHeight,
              child: const ColoredBox(color: Colors.transparent),
            ),
            SizedBox(height: metrics.orbBottomPadding),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  HomeTokens.greeting,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceMono(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  HomeTokens.encryptionLine1,
                  textAlign: TextAlign.center,
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
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            Flexible(
              child: SizedBox(height: metrics.bottomSpacerMinLength),
            ),
          ],
        );
      },
    );
  }
}
