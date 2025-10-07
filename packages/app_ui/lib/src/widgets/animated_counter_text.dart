import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

// /// {@template animated_counter_text}
// /// Widget that implicitly animates the text from 0 to [text].
// /// {@endtemplate}
// class AnimatedCounterText extends StatefulWidget {
//   /// {@macro animated_counter_text}
//   const AnimatedCounterText({
//     required this.text,
//     this.style,
//     this.color = AppColors.white,
//     this.precision = 2,
//     this.duration = const Duration(milliseconds: 1000),
//     super.key,
//   });

//   /// The text to animate to.
//   ///
//   /// The widget will rebuild when this value changes.
//   final double text;

//   /// The style to use for the text.
//   ///
//   /// Defaults to [ThemeData.textTheme.titleLarge].
//   final TextStyle? style;

//   /// Color of the text.
//   /// Will be overridden by [style].
//   /// Defaults to [AppColors.white].
//   final Color color;

//   ///Precision of the text.
//   /// Defaults to 2.
//   final int precision;

//   ///Default duration of the animation.
//   final Duration duration;

//   @override
//   State<AnimatedCounterText> createState() => _AnimatedCounterTextState();
// }

// class _AnimatedCounterTextState extends State<AnimatedCounterText>
//     with SingleTickerProviderStateMixin {
//   // final Duration _duration = const Duration(milliseconds: 1000);

//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: widget.duration,
//       // upperBound: widget.text,
//     );
//     if (widget.text > 0) {
//       _controller.forward();
//     }
//   }

//   @override
//   void didUpdateWidget(covariant AnimatedCounterText oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.text != widget.text && widget.text > 0) {
//       if (_controller.isAnimating) {
//         _controller.stop();
//       }
//       _controller.forward(
//         from: 0,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Text(
//           (_controller.value * widget.text).toStringAsFixed(widget.precision),
//           style: widget.style ??
//               Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: widget.color,
//                     height: 1,
//                     fontSize: 50,
//                     fontWeight: FontWeight.bold,
//                   ),
//         );
//       },
//     );
//   }
// }

class AnimatedCounterText extends ImplicitlyAnimatedWidget {
  /// {@macro animated_counter_text}
  const AnimatedCounterText({
    required this.text,
    this.style,
    this.color = AppColors.white,
    this.precision = 2,
    super.duration = const Duration(milliseconds: 300),
    super.key,
    this.maxLines,
  });

  /// The text to animate to.
  ///
  /// The widget will rebuild when this value changes.
  final double text;

  /// The style to use for the text.
  ///
  /// Defaults to [ThemeData.textTheme.titleLarge].
  final TextStyle? style;

  /// Color of the text.
  /// Will be overridden by [style].
  /// Defaults to [AppColors.white].
  final Color color;

  ///Precision of the text.
  /// Defaults to 2.
  final int precision;

  final int? maxLines;

  @override
  _AnimatedCounterTextState createState() => _AnimatedCounterTextState();
}

class _AnimatedCounterTextState
    extends AnimatedWidgetBaseState<AnimatedCounterText> {
  Tween<double>? _value;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _value = visitor(
      _value,
      widget.text,
      (dynamic value) => Tween<double>(begin: value as double),
    )! as Tween<double>;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _value?.evaluate(animation).toStringAsFixed(widget.precision) ?? '',
      maxLines: widget.maxLines,
      overflow: TextOverflow.ellipsis,
      style: widget.style ??
          Theme.of(context).textTheme.titleLarge?.copyWith(
                color: widget.color,
                height: 1,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
    );
  }
}
