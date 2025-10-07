import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;

/// Multiplier for the gap size.
const double _kGapSize = 8;

/// {@template gap}
/// Creates a widget that takes a [extent] amount of multiple of 8 logical
///  pixels of space in the direction of its parent.
/// {@endtemplate}
class Space extends StatelessWidget {
  /// {@macro gap}
  const Space([int extent = 1]) : extent = extent + .0;

  const Space.half({super.key}) : extent = .5;

  /// The extent of the gap.
  ///
  /// This is multiplied by [_kGapSize] to determine the size of the gap.
  final double extent;

  @override
  Widget build(BuildContext context) {
    return Gap(
      extent * _kGapSize,
    );
  }
}
