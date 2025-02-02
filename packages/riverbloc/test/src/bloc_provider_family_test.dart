import 'package:riverbloc/riverbloc.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

final counterProviderFamily = BlocProvider.family<CounterCubit, int, int>(
  (ref, int arg) => CounterCubit(arg),
);

void main() {
  test('bloc provider family contructor', () async {
    final container = ProviderContainer();

    final counter1a = container.read(counterProviderFamily(1));
    final counter1b = container.read(counterProviderFamily(1));

    expect(counter1a, counter1b);
    expect(
      container.read(counterProviderFamily(1).bloc),
      equals(container.read(counterProviderFamily(1).bloc)),
    );

    final counter2a = container.read(counterProviderFamily(2));
    final counter2b = container.read(counterProviderFamily(2));
    expect(counter2a, counter2b);
    expect(
      container.read(counterProviderFamily(2).bloc),
      equals(container.read(counterProviderFamily(2).bloc)),
    );

    expect(
      container.read(counterProviderFamily(1).bloc),
      isNot(equals(container.read(counterProviderFamily(2).bloc))),
    );
  });

  group('BlocProviderFamily.name', () {
    test('Unamed BlocProviderFamily', () async {
      final counterProviderFamily = BlocProviderFamily<CounterCubit, int, int>(
        (ref, int arg) => CounterCubit(arg),
      );

      final counterProvider = counterProviderFamily(0);
      expect(counterProvider.name, isNull);
      expect(counterProvider.bloc.name, isNull);
    });

    test('Named BlocProviderFamily', () async {
      final counterProviderFamily = BlocProviderFamily<CounterCubit, int, int>(
        (ref, int arg) => CounterCubit(arg),
        name: 'counterProvider',
      );

      final counterProvider1 = counterProviderFamily(0);
      expect(counterProvider1.name, 'counterProvider');
      expect(counterProvider1.bloc.name, 'counterProvider.notifier');

      final counterProvider2 = counterProviderFamily(1);
      expect(counterProvider2.name, 'counterProvider');
      expect(counterProvider2.bloc.name, 'counterProvider.notifier');
    });
  });

  group('Override BlocProviderFamily', () {
    final _family =
        BlocProviderFamily<CounterCubit, int, int>.scoped('someName');

    test('reads with error', () {
      final container = ProviderContainer();

      expect(
        () => container.read(_family(1)),
        throwsA(isA<ProviderException>()),
      );

      try {
        container.read(_family(1).bloc);
      } on ProviderException catch (e) {
        expect(e.exception, isA<UnimplementedProviderError>());
        final unimplementedProviderError =
            e.exception as UnimplementedProviderError;
        expect(unimplementedProviderError.name, 'someName');
      } catch (e) {
        fail('unexpected exception $e');
      }
    });

    test('reads with success', () {
      final container = ProviderContainer(
        overrides: [
          _family.overrideWithProvider((arg) {
            return BlocProvider((ref) => CounterCubit(arg));
          }),
        ],
      );

      expect(container.read(_family(1)), 1);
    });
  });

  group('BlocProviderFamily overrides itself', () {
    final family = BlocProviderFamily<CounterCubit, int, int>(
      (ref, int arg) => CounterCubit(arg),
    );

    test('without overrideWithProvider', () async {
      final container1 = ProviderContainer();

      final container2 = ProviderContainer(
        parent: container1,
        overrides: [family],
      );

      container1.read(family(1).bloc).increment();
      await Future(() {});

      expect(container1.read(family(1)), 2);
      expect(container2.read(family(1)), 1);
    });
  });
}
