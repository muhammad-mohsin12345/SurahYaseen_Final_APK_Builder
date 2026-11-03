import 'package:flutter/material.dart';
import '../../data/local/app_state.dart';

/// Rebuilds [builder] whenever AppState changes.
class Watch extends StatelessWidget {
  final WidgetBuilder builder;
  const Watch({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.I,
      builder: (context, _) => builder(context),
    );
  }
}
