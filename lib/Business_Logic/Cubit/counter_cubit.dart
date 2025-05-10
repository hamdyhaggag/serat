import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Data/Shared/cache_helper.dart';

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterInitialState());

  static CounterCubit get(context) => BlocProvider.of(context);

  int counter = 0;
  int totalCounter = 0;
  int cycleCounter = 0;
  int maxCounter = 33;

  void initializeCounters({
    required int counter,
    required int totalCounter,
    required int cycleCounter,
  }) {
    this.counter = counter;
    this.totalCounter = totalCounter;
    this.cycleCounter = cycleCounter;
    emit(CounterInitialState());
  }

  void incrementCounter() {
    counter++;
    totalCounter++;
    if (counter >= maxCounter) {
      counter = 0;
      cycleCounter++;
    }
    emit(CounterIncrementedState());
  }

  void resetCounter() {
    counter = 0;
    totalCounter = 0;
    cycleCounter = 0;
    emit(ChangeCounterState());
  }

  void changeMaxCounter(int value) {
    maxCounter = value;
    CacheHelper.putData(key: 'maxCounter', value: value);
    emit(ChangeMaxCounterState());
  }
}

// Counter States
abstract class CounterState {}

class CounterInitialState extends CounterState {}

class ChangeCounterState extends CounterState {}

class ChangeMaxCounterState extends CounterState {}

class CounterIncrementedState extends CounterState {}
