import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_animator.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_baker.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_layer_pack.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_metrics.dart';
import 'package:opencore_flutterians/home/home_theme.dart';

class HomeOrbView extends StatefulWidget {
  const HomeOrbView({super.key, this.active = true});

  final bool active;

  @override
  State<HomeOrbView> createState() => _HomeOrbViewState();
}

class _HomeOrbViewState extends State<HomeOrbView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  /// Monotonic clock — never resets. Layer loops use `% duration` themselves.
  /// A repeating [AnimationController] used to snap `elapsed` 20→0 and teleport
  /// layers whose durations do not divide 20 evenly.
  final Stopwatch _clock = Stopwatch();
  final ValueNotifier<double> _elapsedSeconds = ValueNotifier(0);

  Ticker? _ticker;
  HomeOrbLayerPack? _pack;
  Color? _loadedTint;
  Color? _loadedAccent;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;
  bool _wasAnimating = false;

  bool get _shouldAnimate {
    if (!widget.active) {
      return false;
    }
    if (_lifecycleState != AppLifecycleState.resumed) {
      return false;
    }
    return !MediaQuery.disableAnimationsOf(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    _elapsedSeconds.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    _syncAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensurePack();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant HomeOrbView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _onTick(Duration _) {
    _elapsedSeconds.value = _clock.elapsedMicroseconds / 1e6;
  }

  void _ensurePack() {
    final colors = HomeColors.of(context);
    final tint = colors.orbTint;
    final accent = colors.orbAccent;

    if (_pack != null && _loadedTint == tint && _loadedAccent == accent) {
      return;
    }

    _loadedTint = tint;
    _loadedAccent = accent;
    setState(() => _pack = null);

    HomeOrbBakeCache.obtain(tint: tint, accent: accent).then((pack) {
      if (!mounted) {
        return;
      }
      if (_loadedTint != tint || _loadedAccent != accent) {
        return;
      }
      setState(() => _pack = pack);
      _syncAnimation();
    });
  }

  void _syncAnimation() {
    final ticker = _ticker;
    if (ticker == null) {
      return;
    }

    final shouldAnimate = _shouldAnimate && _pack != null;
    if (shouldAnimate) {
      if (!_clock.isRunning) {
        _clock.start();
      }
      if (!ticker.isActive) {
        ticker.start();
      }
    } else {
      if (_clock.isRunning) {
        _clock.stop();
      }
      if (ticker.isActive) {
        ticker.stop();
      }
    }

    if (_wasAnimating != shouldAnimate) {
      _wasAnimating = shouldAnimate;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pack = _pack;
    if (pack == null) {
      return const SizedBox.shrink();
    }

    final shouldAnimate = _shouldAnimate;

    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: HomeOrbMetrics.canvasSize.width,
            height: HomeOrbMetrics.canvasSize.height,
            child: RepaintBoundary(
              child: ValueListenableBuilder<double>(
                valueListenable: _elapsedSeconds,
                builder: (context, elapsed, child) {
                  return _HomeOrbCanvas(
                    pack: pack,
                    elapsed: elapsed,
                    animate: shouldAnimate,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeOrbCanvas extends StatelessWidget {
  const _HomeOrbCanvas({
    required this.pack,
    required this.elapsed,
    required this.animate,
  });

  final HomeOrbLayerPack pack;
  final double elapsed;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final descriptor in pack.layers) _buildLayer(descriptor),
        for (final descriptor in pack.outerOrbitDots) _buildOrbitDot(descriptor),
        for (final descriptor in pack.sparks) _buildSpark(descriptor),
      ],
    );
  }

  Widget _buildLayer(HomeOrbLayerDescriptor descriptor) {
    final sample = homeOrbSampleLayer(
      descriptor: descriptor,
      elapsed: elapsed,
      animate: animate,
    );

    return _positionedImage(
      image: descriptor.image,
      position: sample.position,
      size: HomeOrbMetrics.canvasSize,
      opacity: sample.opacity,
      scale: sample.scale,
      rotation: sample.rotation,
      filterQuality: descriptor.crispEdges ? FilterQuality.none : FilterQuality.medium,
    );
  }

  Widget _buildOrbitDot(HomeOrbOrbitDotDescriptor descriptor) {
    final sample = homeOrbSampleOrbitDot(
      descriptor: descriptor,
      elapsed: elapsed,
      animate: animate,
    );

    return _positionedImage(
      image: descriptor.image,
      position: sample.position,
      size: descriptor.imageSize,
      opacity: sample.opacity,
      scale: sample.scale,
    );
  }

  Widget _buildSpark(HomeOrbSparkDescriptor descriptor) {
    final sample = homeOrbSampleSpark(
      descriptor: descriptor,
      elapsed: elapsed,
      animate: animate,
    );

    return _positionedImage(
      image: descriptor.image,
      position: sample.position,
      size: descriptor.imageSize,
      opacity: sample.opacity,
      scale: sample.scale,
    );
  }

  Widget _positionedImage({
    required ui.Image image,
    required Offset position,
    required Size size,
    required double opacity,
    required double scale,
    double rotation = 0,
    FilterQuality filterQuality = FilterQuality.medium,
  }) {
    final left = position.dx - size.width * 0.5;
    final top = position.dy - size.height * 0.5;

    return Positioned(
      left: left,
      top: top,
      width: size.width,
      height: size.height,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: RawImage(
              image: image,
              width: size.width,
              height: size.height,
              fit: BoxFit.fill,
              filterQuality: filterQuality,
            ),
          ),
        ),
      ),
    );
  }
}
