import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template bloc_to_change_notifier}
/// A [ChangeNotifier] that listens to a [Bloc] and notifies listeners when
/// the bloc emits a new state.
/// {@endtemplate}
class BlocToChangeNotifier<T extends BlocBase<S>, S> extends ChangeNotifier {
  /// {@macro bloc_to_change_notifier}
  BlocToChangeNotifier(this.bloc) {
    bloc.stream.listen((_) {
      notifyListeners();
    });
  }

  /// The bloc that the [ChangeNotifier] will listen to.
  final T bloc;

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}
