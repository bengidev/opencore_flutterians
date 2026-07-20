import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_layout.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_layer_pack.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_metrics.dart';

/// Rasterizes orb assets on the main isolate so [ui.Image] handles stay valid
/// in widget tests without isolate transfer. A future optimization can build
/// particle lists in a worker isolate and rasterize on the UI isolate.
class HomeOrbBaker {
  HomeOrbBaker._();

  static Future<HomeOrbLayerPack> bake({
    required Color tint,
    required Color accent,
  }) async {
    final sparkSeeds = HomeOrbLayout.makeSparkSeeds(seedOffset: 11200, count: 28);
    final outerOrbitDotImage = await _renderOrbitDot(tint: tint);
    final outerOrbitDotSeeds =
        HomeOrbLayout.makeOuterOrbitDotSeeds(seedOffset: 12800, count: 42);

    final layers = <HomeOrbLayerDescriptor>[
      await _makeLayer(
        image: await _renderDots(
          tint: tint,
          dots: HomeOrbLayout.makeOuterDots(seedOffset: 0, count: 138, radiusBias: 0.72),
        ),
        restOpacity: 0.36,
        opacityRange: 0.05,
        opacityDuration: 6.8,
        restScale: 1,
        scaleRange: 0.018,
        scaleDuration: 8.4,
        rotationRange: 0.09,
        rotationDuration: 21,
        phaseOffset: 0,
        crispEdges: false,
        driftRadius: 5,
        driftVerticalScale: 0.72,
        driftDuration: 16,
      ),
      await _makeLayer(
        image: await _renderDots(
          tint: tint,
          dots: HomeOrbLayout.makeOuterDots(seedOffset: 1200, count: 126, radiusBias: 0.66),
        ),
        restOpacity: 0.28,
        opacityRange: 0.05,
        opacityDuration: 7.6,
        restScale: 0.98,
        scaleRange: 0.022,
        scaleDuration: 9.2,
        rotationRange: 0.07,
        rotationDuration: 17.5,
        phaseOffset: 1.9,
        crispEdges: false,
        driftRadius: 7,
        driftVerticalScale: 0.56,
        driftDuration: 19,
      ),
      await _makeLayer(
        image: await _renderDots(
          tint: tint,
          dots: HomeOrbLayout.makePulseDots(seedOffset: 1800, count: 86),
        ),
        restOpacity: 0.20,
        opacityRange: 0.10,
        opacityDuration: 5.2,
        restScale: 0.78,
        scaleRange: 0.12,
        scaleDuration: 5.8,
        rotationRange: 0.04,
        rotationDuration: 13,
        phaseOffset: 0.4,
        crispEdges: false,
        driftRadius: 2,
        driftVerticalScale: 0.70,
        driftDuration: 11,
      ),
      await _makeLayer(
        image: await _renderBlocks(
          tint: accent,
          blocks: HomeOrbLayout.makeCoreBlocks(seedOffset: 2400, count: 236, prominence: 0.96),
        ),
        restOpacity: 0.78,
        opacityRange: 0.10,
        opacityDuration: 5.8,
        restScale: 1,
        scaleRange: 0.028,
        scaleDuration: 6.6,
        rotationRange: 0.10,
        rotationDuration: 12,
        phaseOffset: 0.8,
        crispEdges: true,
        driftRadius: 4,
        driftVerticalScale: 0.74,
        driftDuration: 8.5,
      ),
      await _makeLayer(
        image: await _renderBlocks(
          tint: accent,
          blocks: HomeOrbLayout.makeCoreBlocks(seedOffset: 4800, count: 220, prominence: 0.78),
        ),
        restOpacity: 0.52,
        opacityRange: 0.09,
        opacityDuration: 6.4,
        restScale: 1.02,
        scaleRange: 0.024,
        scaleDuration: 6.1,
        rotationRange: 0.14,
        rotationDuration: 9.8,
        phaseOffset: 2.2,
        crispEdges: true,
        driftRadius: 5,
        driftVerticalScale: 0.68,
        driftDuration: 7.8,
      ),
      await _makeLayer(
        image: await _renderBlocks(
          tint: accent,
          blocks: HomeOrbLayout.makeCoreBlocks(seedOffset: 7200, count: 158, prominence: 0.58),
        ),
        restOpacity: 0.30,
        opacityRange: 0.06,
        opacityDuration: 6.4,
        restScale: 1.04,
        scaleRange: 0.018,
        scaleDuration: 6.1,
        rotationRange: 0.18,
        rotationDuration: 7.4,
        phaseOffset: 3.1,
        crispEdges: true,
        driftRadius: 6,
        driftVerticalScale: 0.64,
        driftDuration: 6.9,
      ),
      await _makeLayer(
        image: await _renderDots(
          tint: tint,
          dots: HomeOrbLayout.makeOrbDust(seedOffset: 9600, count: 132),
        ),
        restOpacity: 0.30,
        opacityRange: 0.08,
        opacityDuration: 4.4,
        restScale: 1.01,
        scaleRange: 0.032,
        scaleDuration: 5.6,
        rotationRange: 0.12,
        rotationDuration: 10.6,
        phaseOffset: 1.5,
        crispEdges: false,
        driftRadius: 8,
        driftVerticalScale: 0.62,
        driftDuration: 12.4,
      ),
    ];

    final sparks = <HomeOrbSparkDescriptor>[];
    for (final seed in sparkSeeds) {
      sparks.add(
        HomeOrbSparkDescriptor(
          image: await _renderSpark(tint: tint, glyph: seed.glyph, pointSize: seed.pointSize),
          imageSize: const ui.Size(18, 18),
          orbitRadius: seed.orbitRadius,
          verticalScale: seed.verticalScale,
          angleOffset: seed.angleOffset,
          radialPulse: seed.radialPulse,
          orbitDuration: seed.orbitDuration,
          opacityDuration: seed.opacityDuration,
          scaleDuration: seed.scaleDuration,
          phaseOffset: seed.phaseOffset,
          restOpacity: seed.restOpacity,
          restScale: seed.restScale,
          scaleRange: seed.scaleRange,
        ),
      );
    }

    return HomeOrbLayerPack(
      layers: layers,
      outerOrbitDots: outerOrbitDotSeeds
          .map(
            (seed) => HomeOrbOrbitDotDescriptor(
              image: outerOrbitDotImage,
              imageSize: const ui.Size(10, 10),
              orbitRadius: seed.orbitRadius,
              verticalScale: seed.verticalScale,
              angleOffset: seed.angleOffset,
              radialPulse: seed.radialPulse,
              orbitDuration: seed.orbitDuration,
              opacityDuration: seed.opacityDuration,
              scaleDuration: seed.scaleDuration,
              phaseOffset: seed.phaseOffset,
              restOpacity: seed.restOpacity,
              restScale: seed.restScale,
              scaleRange: seed.scaleRange,
            ),
          )
          .toList(),
      sparks: sparks,
    );
  }

  static Future<HomeOrbLayerDescriptor> _makeLayer({
    required ui.Image image,
    required double restOpacity,
    required double opacityRange,
    required double opacityDuration,
    required double restScale,
    required double scaleRange,
    required double scaleDuration,
    required double rotationRange,
    required double rotationDuration,
    required double phaseOffset,
    required bool crispEdges,
    required double driftRadius,
    required double driftVerticalScale,
    required double driftDuration,
  }) async {
    return HomeOrbLayerDescriptor(
      image: image,
      restOpacity: restOpacity,
      opacityRange: opacityRange,
      opacityDuration: opacityDuration,
      restScale: restScale,
      scaleRange: scaleRange,
      scaleDuration: scaleDuration,
      rotationRange: rotationRange,
      rotationDuration: rotationDuration,
      phaseOffset: phaseOffset,
      crispEdges: crispEdges,
      driftRadius: driftRadius,
      driftVerticalScale: driftVerticalScale,
      driftDuration: driftDuration,
    );
  }

  static Future<ui.Image> _renderDots({
    required Color tint,
    required List<HomeOrbDot> dots,
  }) {
    return _renderCanvasImage(
      size: HomeOrbMetrics.canvasSize,
      draw: (canvas) {
        for (final dot in dots) {
          final paint = Paint()
            ..color = tint.withValues(alpha: dot.opacity)
            ..style = PaintingStyle.fill;
          final rect = Rect.fromCenter(
            center: dot.point,
            width: dot.size,
            height: dot.size,
          );
          canvas.drawOval(rect, paint);
        }
      },
    );
  }

  static Future<ui.Image> _renderBlocks({
    required Color tint,
    required List<HomeOrbBlock> blocks,
  }) {
    return _renderCanvasImage(
      size: HomeOrbMetrics.canvasSize,
      draw: (canvas) {
        for (final block in blocks) {
          final builder = ui.ParagraphBuilder(
            ui.ParagraphStyle(
              fontFamily: 'monospace',
              fontSize: block.size,
            ),
          )
            ..pushStyle(
              ui.TextStyle(
                color: tint.withValues(alpha: block.opacity),
                fontFamily: 'monospace',
                fontSize: block.size,
              ),
            )
            ..addText(block.glyph);
          final paragraph = builder.build()
            ..layout(const ui.ParagraphConstraints(width: double.infinity));
          canvas.drawParagraph(
            paragraph,
            Offset(
              block.point.dx - paragraph.maxIntrinsicWidth / 2,
              block.point.dy - paragraph.height / 2,
            ),
          );
        }
      },
    );
  }

  static Future<ui.Image> _renderSpark({
    required Color tint,
    required String glyph,
    required double pointSize,
  }) {
    const logicalSize = 18.0;
    return _renderCanvasImage(
      size: const ui.Size(logicalSize, logicalSize),
      draw: (canvas) {
        final builder = ui.ParagraphBuilder(
          ui.ParagraphStyle(
            fontFamily: 'monospace',
            fontSize: pointSize,
          ),
        )
          ..pushStyle(
            ui.TextStyle(
              color: tint,
              fontFamily: 'monospace',
              fontSize: pointSize,
            ),
          )
          ..addText(glyph);
        final paragraph = builder.build()
          ..layout(const ui.ParagraphConstraints(width: double.infinity));
        canvas.drawParagraph(
          paragraph,
          Offset(
            (logicalSize - paragraph.maxIntrinsicWidth) / 2,
            (logicalSize - paragraph.height) / 2,
          ),
        );
      },
    );
  }

  static Future<ui.Image> _renderOrbitDot({required Color tint}) {
    const logicalSize = 10.0;
    return _renderCanvasImage(
      size: const ui.Size(logicalSize, logicalSize),
      draw: (canvas) {
        final innerPaint = Paint()
          ..color = tint.withValues(alpha: 0.82)
          ..style = PaintingStyle.fill;
        canvas.drawOval(const Rect.fromLTWH(2, 2, 6, 6), innerPaint);

        final outerPaint = Paint()
          ..color = tint.withValues(alpha: 0.18)
          ..style = PaintingStyle.fill;
        canvas.drawOval(const Rect.fromLTWH(0.6, 0.6, 8.8, 8.8), outerPaint);
      },
    );
  }

  static Future<ui.Image> _renderCanvasImage({
    required ui.Size size,
    required void Function(Canvas canvas) draw,
  }) async {
    final scale = HomeOrbMetrics.renderScale;
    final width = (size.width * scale).round();
    final height = (size.height * scale).round();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    );
    canvas.scale(scale);
    draw(canvas);
    final picture = recorder.endRecording();
    return picture.toImage(width, height);
  }
}

class HomeOrbBakeCache {
  HomeOrbBakeCache._();

  static HomeOrbLayerPack? _pack;
  static int? _key;

  static Future<HomeOrbLayerPack> obtain({
    required Color tint,
    required Color accent,
  }) async {
    final key = Object.hash(_colorKey(tint), _colorKey(accent));
    if (_pack != null && _key == key) {
      return _pack!;
    }
    _pack?.dispose();
    final pack = await HomeOrbBaker.bake(tint: tint, accent: accent);
    _pack = pack;
    _key = key;
    return pack;
  }

  @visibleForTesting
  static void clear() {
    _pack?.dispose();
    _pack = null;
    _key = null;
  }

  static int _colorKey(Color color) {
    return color.toARGB32();
  }
}
