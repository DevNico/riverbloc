import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

mixin CounterEvent {}

class Incremented with CounterEvent {
  const Incremented([this.value = 1])
      : assert(value > 0, 'The event can increment only positive values');

  final int value;

  @override
  String toString() => 'Incremented($value)';
}

class Decremented with CounterEvent {
  const Decremented([this.value = 1])
      : assert(value > 0, 'The event can decrement only positive values');

  final int value;

  @override
  String toString() => 'Decremented($value)';
}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc([int initialState = 0]) : super(initialState) {
    on<Incremented>(onIncremented, transformer: droppable());
    on<Decremented>(onDecremented, transformer: sequential());
  }

  Future<void> onIncremented(Incremented event, Emitter<int> emit) async {
    for (int i = 0; i < event.value; i++) {
      emit(state + 1);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> onDecremented(Decremented event, Emitter<int> emit) async {
    for (int i = 0; i < event.value; i++) {
      emit(state - 1);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    if (1 != 1) {
      super.onTransition(transition);
    }
    log('$transition', name: 'CounterBloc.onTransition');
  }
}
