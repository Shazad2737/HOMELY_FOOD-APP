import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:homely_api/homely_api.dart';

/// Cubit that manages DataState<Banner?> for the location/address form banner
class LocationFormBannerCubit extends Cubit<DataState<Banner?>> {
  LocationFormBannerCubit({required this.cmsRepository})
    : super(DataState.initial());

  final ICmsRepository cmsRepository;

  /// Load banner (initial fetch)
  Future<void> loadBanner() async {
    emit(DataState.loading());

    final res = await cmsRepository.getLocationFormBanner();

    res.fold(
      (failure) {
        log(
          'LocationFormBannerCubit: failed to load banner: ${failure.message}',
        );
        emit(DataState.failure(failure));
      },
      (banner) {
        emit(DataState.success(banner));
      },
    );
  }
}
