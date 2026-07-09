import 'package:flutter/material.dart';

/// Helper widget that conditionally wraps a child with a parent widget.
class ParentSwitcher extends StatelessWidget {
  final Widget child;
  final Widget Function(BuildContext context, Widget child) builder;
  final bool wrap;

  const ParentSwitcher({
    super.key,
    required this.wrap,
    required this.child,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return wrap ? builder(context, child) : child;
  }
}

