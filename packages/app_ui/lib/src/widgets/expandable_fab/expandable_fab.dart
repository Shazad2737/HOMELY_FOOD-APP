import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A controller for managing the state of an [ExpandableFab].
class ExpandableFabController extends ChangeNotifier {
  bool _isOpen = false;

  /// Whether the [ExpandableFab] is currently open.
  bool get isOpen => _isOpen;

  /// Opens the [ExpandableFab] if it's not already open.
  void open() {
    if (!_isOpen) {
      _isOpen = true;
      notifyListeners();
    }
  }

  /// Closes the [ExpandableFab] if it's not already closed.
  void close() {
    if (_isOpen) {
      _isOpen = false;
      notifyListeners();
    }
  }

  /// Toggles the [ExpandableFab] between open and closed states.
  void toggle() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  /// Finds the [ExpandableFabController] from the closest [ExpandableFab]
  /// ancestor.
  static ExpandableFabController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ExpandableFabScope>();
    if (scope == null) {
      throw FlutterError('ExpandableFabController not found in context');
    }
    return scope.controller;
  }
}

/// Defines the layout style for the ExpandableFab
enum ExpandableFabStyle {
  /// Fans out the buttons in a radial pattern
  radial,

  /// Stacks the buttons vertically with labels on the side
  vertical
}

/// A Floating Action Button that expands to reveal additional action buttons.
class ExpandableFab extends StatefulWidget {
  /// Creates an [ExpandableFab].
  const ExpandableFab({
    // required this.distance,
    required this.childrenBuilder,
    super.key,
    this.initialOpen,
    this.openIcon,
    this.controller,
    this.style = ExpandableFabStyle.radial,
    this.spacing = 55.0,
    this.showLabels = true,
  });

  /// The widgets (typically [ActionButton]s) to display when the FAB is expanded.
  final List<Widget> Function(BuildContext context) childrenBuilder;

  /// Whether the FAB should be initially open.
  final bool? initialOpen;

  /// The icon to display on the main FAB when it's closed.
  /// Defaults to an add icon.
  final Widget? openIcon;

  /// An optional controller to manage the FAB's state externally.
  final ExpandableFabController? controller;

  /// The layout style of the expandable FAB
  final ExpandableFabStyle style;

  // final double distance;

  // The spacing between buttons in vertical mode

  /// The distance that the child buttons should move when the FAB expands.
  /// If [style] is [ExpandableFabStyle.radial], this is the radius of the
  /// circle that the buttons fan out from.
  /// If [style] is [ExpandableFabStyle.vertical], this is the distance that
  /// the buttons move vertically.
  final double spacing;

  /// Whether to show labels in vertical mode
  final bool showLabels;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final ExpandableFabController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = widget.controller ?? ExpandableFabController();
    _fabController._isOpen = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _fabController._isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: _controller,
    );
    _fabController.addListener(_handleControllerChanged);
  }

  void _handleControllerChanged() {
    if (_fabController.isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    if (widget.controller == null) {
      _fabController.dispose();
    } else {
      _fabController.removeListener(_handleControllerChanged);
    }
    super.dispose();
  }

  void _toggle() {
    _fabController.toggle();
  }

  @override
  Widget build(BuildContext context) {
    return _ExpandableFabScope(
      controller: _fabController,
      child: Builder(
        builder: (context) {
          return SizedBox.expand(
            child: Stack(
              alignment: Alignment.bottomRight,
              clipBehavior: Clip.none,
              children: [
                if (_fabController.isOpen)
                  GestureDetector(
                    onTap: _toggle,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                _buildTapToCloseFab(),
                ...widget.style == ExpandableFabStyle.radial
                    ? _buildRadialActionButtons(context)
                    : _buildVerticalActionButtons(context),
                _buildTapToOpenFab(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRadialActionButtons(
    BuildContext context,
  ) {
    final children = <Widget>[];
    final widgetChildren = widget.childrenBuilder(context);
    final count = widgetChildren.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          // maxDistance: widget.distance,
          maxDistance: widget.spacing,
          progress: _expandAnimation,
          showLabel: widget.showLabels,
          child: widgetChildren[i],
        ),
      );
    }
    return children;
  }

  List<Widget> _buildVerticalActionButtons(
    BuildContext context,
  ) {
    final children = <Widget>[];
    final widgetChildren = widget.childrenBuilder(context);
    final count = widgetChildren.length;

    for (var i = 0; i < count; i++) {
      // final child = widget.children[i];
      final child = widgetChildren[i];
      if (child is ActionButton) {
        children.add(
          _VerticalActionButton(
            index: i,
            spacing: widget.spacing,
            // maxDistance: widget.distance,
            maxDistance: widget.spacing,
            progress: _expandAnimation,
            showLabel: widget.showLabels,
            child: child,
          ),
        );
      } else {
        children.add(
          _VerticalActionButton(
            index: i,
            spacing: widget.spacing,
            // maxDistance: widget.distance,
            maxDistance: widget.spacing,
            progress: _expandAnimation,
            showLabel: widget.showLabels,
            child: child,
          ),
        );
      }
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _fabController.isOpen,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _fabController.isOpen ? 0.7 : 1.0,
          _fabController.isOpen ? 0.7 : 1.0,
          1,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _fabController.isOpen ? 0.0 : 1.0,
          curve: const Interval(0.25, 1, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            heroTag: 'fab',
            child: widget.openIcon ?? const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class _ExpandableFabScope extends InheritedWidget {
  const _ExpandableFabScope({
    required this.controller,
    required super.child,
  });

  final ExpandableFabController controller;

  @override
  bool updateShouldNotify(_ExpandableFabScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
    this.showLabel = true,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, childWidget) {
        final offset = Offset.fromDirection(
          (180 + directionInDegrees) * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4,
          bottom: 4,
          child: Transform.translate(
            offset: offset,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLabel && child is ActionButton)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Opacity(
                      opacity: progress.value,
                      child: Material(
                        elevation: 4,
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            (child as ActionButton).label ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                Opacity(
                  opacity: progress.value,
                  child: childWidget,
                ),
              ],
            ),
          ),
        );
      },
      child: child,
    );
  }
}

@immutable
class _VerticalActionButton extends StatelessWidget {
  const _VerticalActionButton({
    required this.index,
    required this.spacing,
    required this.maxDistance,
    required this.progress,
    required this.child,
    this.showLabel = true,
  });

  final int index;
  final double spacing;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset(
          0,
          -spacing * (index + 1) * progress.value,
        );

        return Positioned(
          right: 4,
          bottom: 4,
          child: Transform.translate(
            offset: offset,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLabel && child is ActionButton)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Opacity(
                      opacity: progress.value,
                      child: Material(
                        elevation: 4,
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            child.label ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                Opacity(
                  opacity: progress.value,
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// A circular button designed to be used as a child of [ExpandableFab].
class ActionButton extends StatelessWidget {
  /// Creates an [ActionButton].
  const ActionButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.label,
  });

  /// The callback that is called when the button is tapped.
  final VoidCallback? onPressed;

  /// The icon to display inside the button.
  final Widget icon;

  /// The label to display next to the button in vertical mode.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondary,
      elevation: 4,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}
