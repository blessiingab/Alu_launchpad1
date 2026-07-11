import 'package:flutter/material.dart';

/// A card shape with one corner sliced off diagonally — the app's
/// signature silhouette, used instead of plain rounded rectangles
/// wherever a surface should feel distinct rather than generic.
///
/// Usage: wrap a Container (with its own gradient/color/padding) in
/// `ClipPath(clipper: NotchedCornerClipper(), child: ...)`. Rounded
/// corners on the *other* three sides come from clipping a
/// pre-rounded-rect path, so the container's own BorderRadius is
/// ignored — set radius here instead.
class NotchedCornerClipper extends CustomClipper<Path> {
  const NotchedCornerClipper({
    this.notch = 22,
    this.radius = 20,
    this.corner = NotchCorner.topRight,
  });

  final double notch;
  final double radius;
  final NotchCorner corner;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = radius;
    final n = notch;

    final path = Path();
    switch (corner) {
      case NotchCorner.topRight:
        path.moveTo(r, 0);
        path.lineTo(w - n, 0);
        path.lineTo(w, n);
        path.lineTo(w, h - r);
        path.quadraticBezierTo(w, h, w - r, h);
        path.lineTo(r, h);
        path.quadraticBezierTo(0, h, 0, h - r);
        path.lineTo(0, r);
        path.quadraticBezierTo(0, 0, r, 0);
        break;
      case NotchCorner.bottomLeft:
        path.moveTo(r, 0);
        path.lineTo(w - r, 0);
        path.quadraticBezierTo(w, 0, w, r);
        path.lineTo(w, h - r);
        path.quadraticBezierTo(w, h, w - r, h);
        path.lineTo(n, h);
        path.lineTo(0, h - n);
        path.lineTo(0, r);
        path.quadraticBezierTo(0, 0, r, 0);
        break;
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant NotchedCornerClipper oldClipper) =>
      oldClipper.notch != notch ||
      oldClipper.radius != radius ||
      oldClipper.corner != corner;
}

enum NotchCorner { topRight, bottomLeft }