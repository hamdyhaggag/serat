import 'package:flutter_bloc/flutter_bloc.dart';
import 'azkar_state.dart';

class AzkarCubit extends Cubit<AzkarState> {
  AzkarCubit({AzkarState? initialState})
    : super(initialState ?? AzkarState(currentIndex: 0));

  void updateIndex(int newIndex) {
    emit(state.copyWith(currentIndex: newIndex));
  }

  void incrementCounter(int cardIndex) {
    final currentCounters = Map<int, int>.from(state.counters);
    final currentCount = currentCounters[cardIndex] ?? 0;
    final maxValue = state.maxValues[cardIndex] ?? 0;

    if (currentCount < maxValue) {
      currentCounters[cardIndex] = currentCount + 1;

      // If we've reached the max value, mark as completed
      if (currentCount + 1 == maxValue) {
        final currentCompleted = List<int>.from(state.completedCards);
        if (!currentCompleted.contains(cardIndex)) {
          currentCompleted.add(cardIndex);
          emit(
            state.copyWith(
              counters: currentCounters,
              completedCards: currentCompleted,
            ),
          );
        }
      } else {
        emit(state.copyWith(counters: currentCounters));
      }
    }
  }

  void updateCompletedCards(int cardIndex) {
    final currentCompleted = List<int>.from(state.completedCards);
    if (!currentCompleted.contains(cardIndex)) {
      currentCompleted.add(cardIndex);
      emit(state.copyWith(completedCards: currentCompleted));
    }
  }

  void updateTotalCards(int newTotalCount) {
    emit(state.copyWith(totalCards: newTotalCount));
  }

  void updateMaxValues(Map<int, int> newMaxValues) {
    emit(state.copyWith(maxValues: newMaxValues));
  }
}
