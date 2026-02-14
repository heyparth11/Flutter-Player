import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class AutoMarqueeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double height;

  const AutoMarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 1. Layout the text with INFINITE width to see its natural size
          final textPainter = TextPainter(
            text: TextSpan(text: text, style: style),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout(minWidth: 0, maxWidth: double.infinity);

          // 2. Compare the natural width to the constraints of the parent
          final isOverflowing = textPainter.width > constraints.maxWidth;

          if (!isOverflowing) {
            return Text(
              text,
              style: style,
              maxLines: 1,
              // Using fade or visible prevents weird clipping on short texts
              overflow: TextOverflow.visible,
            );
          }

          return ClipRect(
            child: Marquee(
              text: text,
              style: style,
              scrollAxis: Axis.horizontal,
              velocity: 28,
              blankSpace: 40,
              startPadding: 0,
              pauseAfterRound: const Duration(seconds: 1),
              fadingEdgeStartFraction: 0.01,
              fadingEdgeEndFraction: 0.1,
            ),
          );
        },
      ),
    );
  }
}