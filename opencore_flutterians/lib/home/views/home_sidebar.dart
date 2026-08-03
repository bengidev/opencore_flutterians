import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home_theme.dart';
import '../home_tokens.dart';
import 'home_pressable.dart';

const _maxSidebarWidth = 320.0;
const _scrimOpacity = 0.12;

/// A left slide-out sidebar that lists recent chats/drafts.
///
/// Open with [HomeSidebar.open]. The drawer animates in from the left with a
/// subtle scrim, respects reduced-motion settings, and uses the monochrome
/// home palette.
class HomeSidebar extends StatefulWidget {
  const HomeSidebar({super.key, required this.onChatSelected});

  final ValueChanged<String>? onChatSelected;

  /// Shows the sidebar and returns when it has closed.
  static Future<void> open(
    BuildContext context, {
    ValueChanged<String>? onChatSelected,
  }) {
    final navigator = Navigator.of(context);
    final theme = HomeTheme.light();
    return navigator.push(
      _HomeSidebarRoute(
        builder:
            (context) => Theme(
              data: theme,
              child: HomeSidebar(onChatSelected: onChatSelected),
            ),
      ),
    );
  }

  @override
  State<HomeSidebar> createState() => _HomeSidebarState();
}

class _HomeSidebarState extends State<HomeSidebar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _scrim;
  var _opened = false;
  var _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: HomeTokens.durationUi,
      vsync: this,
    );
    _slide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: HomeTokens.easeOut));
    _scrim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: HomeTokens.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    _controller.duration = reduceMotion ? Duration.zero : HomeTokens.durationUi;
    if (!_opened) {
      _opened = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_isClosing) return;
    _isClosing = true;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    await _controller.animateBack(
      0,
      duration: reduceMotion ? Duration.zero : HomeTokens.durationUi,
      curve: HomeTokens.easeOut,
    );
    if (mounted) Navigator.of(context).pop();
  }

  void _select(String title) {
    HapticFeedback.lightImpact();
    widget.onChatSelected?.call(title);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);
    final width = MediaQuery.sizeOf(context).width * 0.75;
    final drawerWidth = width.clamp(0.0, _maxSidebarWidth);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: _scrim,
                builder: (context, _) {
                  return ColoredBox(
                    color: colors.textPrimary.withValues(
                      alpha: _scrimOpacity * _scrim.value,
                    ),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.primaryDelta != null &&
                    details.primaryDelta! < -8) {
                  _close();
                }
              },
              // Absorb taps on the panel so they don't hit the scrim.
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: SlideTransition(
                position: _slide,
                child: SizedBox(
                  width: drawerWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceRaised,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(HomeTokens.radius),
                      ),
                      border: Border(
                        right: BorderSide(color: colors.border),
                      ),
                    ),
                    child: SafeArea(
                      right: false,
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(onClose: _close),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              itemCount: HomeTokens.stubChatTitles.length,
                              itemBuilder: (context, index) {
                                final title =
                                    HomeTokens.stubChatTitles[index];
                                return _ChatRow(
                                  title: title,
                                  onTap: () => _select(title),
                                  reduceMotion: reduceMotion,
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.paddingOf(context).bottom,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'Chats',
              style: GoogleFonts.spaceGrotesk(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.2,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          HomePressable(
            key: const Key('homeSidebarCloseButton'),
            onPressed: () {
              HapticFeedback.lightImpact();
              onClose();
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.close, color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.title,
    required this.onTap,
    required this.reduceMotion,
  });

  final String title;
  final VoidCallback onTap;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: HomePressable.builder(
        onPressed: onTap,
        builder: (context, pressed, child) {
          final duration = reduceMotion
              ? Duration.zero
              : (pressed
                  ? HomeTokens.durationPress
                  : HomeTokens.durationRelease);
          return AnimatedContainer(
            duration: duration,
            curve: HomeTokens.easeOut,
            decoration: BoxDecoration(
              color: pressed ? colors.surfaceMuted : Colors.transparent,
              borderRadius: BorderRadius.circular(HomeTokens.radiusControl),
            ),
            child: AnimatedScale(
              scale: pressed ? HomeTokens.pressScale : 1,
              duration: duration,
              curve: HomeTokens.easeOut,
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: colors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A full-screen transparent route that lets the drawer manage its own
/// animations and gestures without blocking the underlying scaffold.
class _HomeSidebarRoute<T> extends PageRouteBuilder<T> {
  _HomeSidebarRoute({required WidgetBuilder builder})
    : super(
        opaque: false,
        barrierDismissible: false,
        pageBuilder:
            (context, animation, secondaryAnimation) => builder(context),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) => child,
      );

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => false;
}
