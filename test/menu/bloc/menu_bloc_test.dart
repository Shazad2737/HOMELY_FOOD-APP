import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homely_api/homely_api.dart';
import 'package:homely_app/menu/bloc/menu_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockMenuRepository extends Mock implements IMenuRepository {}

class _MockCmsRepository extends Mock implements ICmsRepository {}

void main() {
  group('MenuBloc', () {
    late _MockMenuRepository menuRepository;
    late _MockCmsRepository cmsRepository;

    setUp(() {
      menuRepository = _MockMenuRepository();
      cmsRepository = _MockCmsRepository();
    });

    test('initial state is MenuState.initial()', () {
      final bloc = MenuBloc(
        menuRepository: menuRepository,
        cmsRepository: cmsRepository,
      );
      expect(bloc.state.menuState, isA<DataStateInitial<MenuData>>());
    });

    blocTest<MenuBloc, MenuState>(
      'emits failure when categories are empty (avoids stuck loading)',
      build: () {
        when(
          () => cmsRepository.getCategories(),
        ).thenAnswer((_) async => right(<Category>[]));
        return MenuBloc(
          menuRepository: menuRepository,
          cmsRepository: cmsRepository,
        );
      },
      act: (bloc) => bloc.add(MenuInitializedEvent()),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<MenuState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<MenuState>()
            .having((s) => s.isFailure, 'isFailure', isTrue)
            .having(
              (s) => s.failure?.message,
              'failure.message',
              'No categories available',
            ),
      ],
      verify: (_) {
        verify(() => cmsRepository.getCategories()).called(1);
        verifyNever(
          () => menuRepository.getMenu(
            categoryId: any(named: 'categoryId'),
            planId: any(named: 'planId'),
            search: any(named: 'search'),
          ),
        );
      },
    );
  });
}
