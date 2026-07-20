// Rasterizes the app-icon design (assets/brand/app_icon.svg) to the 1024px
// PNG that flutter_launcher_icons consumes. The geometry here mirrors the
// SVG master; keep the two in sync when the icon changes.
//
// Run: dart run tool/generate_icon.dart

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  // Render supersampled, then downscale for clean anti-aliased edges.
  const scale = 4;
  const size = 1024 * scale;
  final canvas = img.Image(width: size, height: size, numChannels: 4);

  final surface = img.ColorRgba8(0xFA, 0xF7, 0xF2, 255);
  final ink = img.ColorRgba8(0x1D, 0x1B, 0x17, 255);
  final clay = img.ColorRgba8(0xA8, 0x56, 0x38, 255);

  img.fill(canvas, color: surface);

  void ring(int cx, int cy, int radius, int strokeWidth, img.Color color) {
    final half = strokeWidth ~/ 2;
    img.fillCircle(canvas, x: cx, y: cy, radius: radius + half, color: color);
    img.fillCircle(canvas, x: cx, y: cy, radius: radius - half, color: surface);
  }

  void thickLine(int x1, int y1, int x2, int y2, int width, img.Color color) {
    // Round-capped stroke: dense circle stamping along the segment.
    final length = math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
    final steps = length.ceil();
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      img.fillCircle(
        canvas,
        x: (x1 + (x2 - x1) * t).round(),
        y: (y1 + (y2 - y1) * t).round(),
        radius: width ~/ 2,
        color: color,
      );
    }
  }

  // The lineup (three rings), scaled from the 1024 design grid.
  for (final cx in [152, 392, 872]) {
    ring(cx * scale, 512 * scale, 56 * scale, 16 * scale, ink);
  }

  // The magnifier ring, then the culprit inside the lens.
  ring(632 * scale, 512 * scale, 120 * scale, 28 * scale, ink);
  img.fillCircle(canvas,
      x: 632 * scale, y: 512 * scale, radius: 56 * scale, color: clay);

  // Handle.
  thickLine(722 * scale, 602 * scale, 838 * scale, 718 * scale, 28 * scale, ink);

  final icon = img.copyResize(
    canvas,
    width: 1024,
    height: 1024,
    interpolation: img.Interpolation.average,
  );
  File('assets/brand/app_icon_1024.png')
      .writeAsBytesSync(img.encodePng(icon));
  stdout.writeln('Wrote assets/brand/app_icon_1024.png');
}
