import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedRow extends StatelessWidget {
  const AnimatedRow({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize,
    this.spacing,
    this.textBaseline,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.animationDuration,
  });

  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final MainAxisSize? mainAxisSize;
  final double? spacing;
  final CrossAxisAlignment? crossAxisAlignment;
  final int? animationDuration;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        MoveEffect(
          duration: Duration(milliseconds: animationDuration ?? 400),
          begin: const Offset(20, 0),
        ),
      ],
      child: Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        mainAxisSize: mainAxisSize ?? MainAxisSize.max,
        children: spacing != null ? _addSpacing(children, spacing!) : children,
      ),
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i != children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }
    return spacedChildren;
  }
}
