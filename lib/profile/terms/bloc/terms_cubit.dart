import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:instamess_api/instamess_api.dart';

/// Cubit that manages DataState<Terms>
class TermsCubit extends Cubit<DataState<Terms>> {
  TermsCubit({required this.cmsRepository}) : super(DataState.initial());

  final ICmsRepository cmsRepository;

  /// Load terms (initial fetch)
  Future<void> loadTerms() async {
    emit(DataState.loading());

    final res = await cmsRepository.getTerms();

    res.fold(
      (failure) {
        log('TermsCubit: failed to load terms: ${failure.message}');
        emit(DataState.failure(failure));
      },
      (terms) {
        emit(DataState.success(terms));
      },
    );
  }

  /// Refresh terms. If we already have data emit refreshing(currentData).
  Future<void> refreshTerms() async {
    final current = state;
    if (current is DataStateSuccess<Terms>) {
      emit(DataState.refreshing(current.data));
    } else {
      emit(DataState.loading());
    }

    final res = await cmsRepository.getTerms();

    res.fold(
      (failure) {
        log('TermsCubit: failed to refresh terms: ${failure.message}');
        emit(DataState.failure(failure));
      },
      (terms) {
        emit(DataState.success(terms));
      },
    );
  }
}
