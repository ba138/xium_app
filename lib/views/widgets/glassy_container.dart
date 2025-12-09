import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double width;
  final double height;
  final double borderRadius;
  final double blurSigma;
  final BoxDecoration? decoration;
  final EdgeInsets padding;

  const GlassContainer({
    super.key,
    this.child,
    this.width = 300,
    this.height = 180,
    this.borderRadius = 20,
    this.blurSigma = 8.0,
    this.decoration,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    // default glassy decoration if none provided
    final defaultDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xff0F2656).withValues(alpha: 0.15),
          Color(0xff0F2656).withValues(alpha: 0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Color(0xff353E50).withValues(alpha: 0.33),
        width: 1.0,
      ),
      // subtle shadow (optional)
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: Offset(0, 6),
        ),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: decoration ?? defaultDecoration,
          child: child,
        ),
      ),
    );
  }
}
