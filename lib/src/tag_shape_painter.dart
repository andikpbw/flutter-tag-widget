import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tag_types.dart';

/// Custom painter that renders specialized tag silhouettes including
/// [TagShape.priceTag], [TagShape.ticket], [TagShape.ribbon], [TagShape.pill],
/// [TagShape.rounded], and [TagShape.square].
class TagShapePainter extends CustomPainter {
  /// Creates a [TagShapePainter].
  const TagShapePainter({
    required this.shape,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    this.gradient,
    this.shadows,
    this.showPriceTagHole = true,
    this.holeColor,
  });

  /// Geometric silhouette to render.
  final TagShape shape;

  /// Background fill color of the tag.
  final Color fillColor;

  /// Border stroke color of the tag.
  final Color borderColor;

  /// Width of the border stroke in logical pixels.
  final double borderWidth;

  /// Corner radius in logical pixels.
  final double borderRadius;

  /// Optional linear or radial gradient overriding [fillColor].
  final Gradient? gradient;

  /// Optional list of drop shadows painted behind the tag path.
  final List<BoxShadow>? shadows;

  /// Whether to draw the circular punch-hole on [TagShape.priceTag].
  final bool showPriceTagHole;

  /// Optional interior fill color for the punch-hole when not using even-odd clipping.
  final Color? holeColor;

  /// Builds the outer vector [Path] for the configured [shape] within [rect].
  static Path buildOuterPath(
    Rect rect, {
    required TagShape shape,
    required double borderRadius,
  }) {
    final r = math.min(
      borderRadius,
      math.min(rect.width, rect.height) / 2.0,
    );

    switch (shape) {
      case TagShape.pill:
        final pillRadius = rect.height / 2.0;
        return Path()
          ..addRRect(
              RRect.fromRectAndRadius(rect, Radius.circular(pillRadius)));

      case TagShape.rounded:
      case TagShape.square:
        return Path()
          ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)));

      case TagShape.priceTag:
        final pointerDepth = math.min(rect.height * 0.44, rect.width * 0.28);
        final cornerR = math.min(r, rect.height * 0.30);
        final leftTipX = rect.left;
        final shoulderX = rect.left + pointerDepth;
        final midY = rect.center.dy;

        final path = Path()
          ..moveTo(leftTipX, midY)
          ..lineTo(shoulderX, rect.top)
          ..lineTo(rect.right - cornerR, rect.top)
          ..arcToPoint(
            Offset(rect.right, rect.top + cornerR),
            radius: Radius.circular(cornerR),
          )
          ..lineTo(rect.right, rect.bottom - cornerR)
          ..arcToPoint(
            Offset(rect.right - cornerR, rect.bottom),
            radius: Radius.circular(cornerR),
          )
          ..lineTo(shoulderX, rect.bottom)
          ..close();
        return path;

      case TagShape.ticket:
        final notchR = math.min(rect.height * 0.22, 6.5);
        final cornerR =
            math.min(r, (rect.height / 2.0) - notchR - 1.0).clamp(2.0, 16.0);
        final midY = rect.center.dy;

        final path = Path()
          ..moveTo(rect.left + cornerR, rect.top)
          ..lineTo(rect.right - cornerR, rect.top)
          ..arcToPoint(
            Offset(rect.right, rect.top + cornerR),
            radius: Radius.circular(cornerR),
          )
          ..lineTo(rect.right, midY - notchR)
          ..arcToPoint(
            Offset(rect.right, midY + notchR),
            radius: Radius.circular(notchR),
            clockwise: false,
          )
          ..lineTo(rect.right, rect.bottom - cornerR)
          ..arcToPoint(
            Offset(rect.right - cornerR, rect.bottom),
            radius: Radius.circular(cornerR),
          )
          ..lineTo(rect.left + cornerR, rect.bottom)
          ..arcToPoint(
            Offset(rect.left, rect.bottom - cornerR),
            radius: Radius.circular(cornerR),
          )
          ..lineTo(rect.left, midY + notchR)
          ..arcToPoint(
            Offset(rect.left, midY - notchR),
            radius: Radius.circular(notchR),
            clockwise: false,
          )
          ..lineTo(rect.left, rect.top + cornerR)
          ..arcToPoint(
            Offset(rect.left + cornerR, rect.top),
            radius: Radius.circular(cornerR),
          )
          ..close();
        return path;

      case TagShape.ribbon:
        final notchDepth = math.min(rect.height * 0.34, rect.width * 0.22);
        final cornerR = math.min(r, rect.height * 0.30);
        final midY = rect.center.dy;

        final path = Path()
          ..moveTo(rect.left + cornerR, rect.top)
          ..lineTo(rect.right, rect.top)
          ..lineTo(rect.right - notchDepth, midY)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left + cornerR, rect.bottom)
          ..arcToPoint(
            Offset(rect.left, rect.bottom - cornerR),
            radius: Radius.circular(cornerR),
          )
          ..lineTo(rect.left, rect.top + cornerR)
          ..arcToPoint(
            Offset(rect.left + cornerR, rect.top),
            radius: Radius.circular(cornerR),
          )
          ..close();
        return path;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final inset = borderWidth > 0 ? borderWidth / 2.0 : 0.0;
    final rect = Offset(inset, inset) &
        Size(
          math.max(0.0, size.width - inset * 2),
          math.max(0.0, size.height - inset * 2),
        );

    final outerPath = buildOuterPath(
      rect,
      shape: shape,
      borderRadius: borderRadius,
    );

    // Draw shadows if provided
    if (shadows != null && shadows!.isNotEmpty) {
      for (final shadow in shadows!) {
        final shadowPaint = Paint()
          ..color = shadow.color
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            shadow.blurSigma,
          );
        canvas.save();
        canvas.translate(shadow.offset.dx, shadow.offset.dy);
        canvas.drawPath(outerPath, shadowPaint);
        canvas.restore();
      }
    }

    Path fillPath = outerPath;
    Rect? holeRect;

    if (shape == TagShape.priceTag && showPriceTagHole) {
      final pointerDepth = math.min(rect.height * 0.44, rect.width * 0.28);
      final holeRadius = (rect.height * 0.11).clamp(2.5, 4.5);
      final holeCenter = Offset(
        rect.left + pointerDepth * 0.78 + holeRadius,
        rect.center.dy,
      );
      holeRect = Rect.fromCircle(center: holeCenter, radius: holeRadius);
      fillPath = Path.combine(
        PathOperation.difference,
        outerPath,
        Path()..addOval(holeRect),
      );
    }

    // Paint background fill or gradient
    final fillPaint = Paint()..style = PaintingStyle.fill;
    if (gradient != null) {
      fillPaint.shader = gradient!.createShader(rect);
    } else {
      fillPaint.color = fillColor;
    }
    canvas.drawPath(fillPath, fillPaint);

    // Paint outer border
    if (borderWidth > 0 && borderColor.a > 0) {
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeJoin = StrokeJoin.round
        ..color = borderColor;
      canvas.drawPath(outerPath, borderPaint);

      if (holeRect != null) {
        canvas.drawOval(holeRect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TagShapePainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.gradient != gradient ||
        oldDelegate.shadows != shadows ||
        oldDelegate.showPriceTagHole != showPriceTagHole ||
        oldDelegate.holeColor != holeColor;
  }
}
