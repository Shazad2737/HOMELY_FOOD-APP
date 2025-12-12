import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/menu/bloc/menu_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockMenuRepository extends Mock implements IMenuRepository {}

class _MockCmsRepository extends Mock implements ICmsRepository {}

void main() {
  group('MenuBloc plan clearing', () {
    late _MockMenuRepository menuRepository;
    late _MockCmsRepository cmsRepository;
    late Category category;

    setUp(() {
      menuRepository = _MockMenuRepository();
      cmsRepository = _MockCmsRepository();
      category = const Category(id: 'cat1', name: 'Auth');

      when(
        () => cmsRepository.getCategories(),
      ).thenAnswer((_) async => right([category]));

      when(
        () => menuRepository.getMenu(
          categoryId: any(named: 'categoryId'),
          planId: any(named: 'planId'),
          search: any(named: 'search'),
        ),
      ).thenAnswer(
        (_) async => right(
          const MenuData(
            availablePlans: [],
            mealTypes: [],
            menu: {},
          ),
        ),
      );
    });

    blocTest<MenuBloc, MenuState>(
      'clears selectedPlan when All Plans tapped',
      build: () => MenuBloc(
        menuRepository: menuRepository,
        cmsRepository: cmsRepository,
      ),
      act: (bloc) async {
        bloc.add(MenuInitializedEvent());
        await bloc.stream.firstWhere((s) => s.selectedCategory != null);
        // Select a plan
        bloc.add(
          MenuPlanSelectedEvent(
            plan: const MenuPlan(id: 'p1', name: 'X', type: PlanType.basic),
          ),
        );
        await bloc.stream.firstWhere((s) => s.selectedPlan?.id == 'p1');
        // Clear plan
        bloc.add(MenuPlanSelectedEvent());
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state.selectedPlan, isNull);
      },
    );
  });
}
