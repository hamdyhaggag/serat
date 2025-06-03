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
      if (currentCount + 1 >= maxValue) {
        final currentCompleted = List<int>.from(state.completedCards);
        if (!currentCompleted.contains(cardIndex)) {
          currentCompleted.add(cardIndex);
          final newProgress = currentCompleted.length / state.totalCards;
          emit(
            state.copyWith(
              counters: currentCounters,
              completedCards: currentCompleted,
              cachedProgress: newProgress,
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
      final newProgress = currentCompleted.length / state.totalCards;
      emit(
        state.copyWith(
          completedCards: currentCompleted,
          cachedProgress: newProgress,
        ),
      );
    }
  }

  void updateTotalCards(int newTotalCount) {
    emit(state.copyWith(totalCards: newTotalCount));
  }

  void updateMaxValues(Map<int, int> newMaxValues) {
    // Initialize counters for new max values if they don't exist
    final currentCounters = Map<int, int>.from(state.counters);
    newMaxValues.forEach((key, value) {
      if (!currentCounters.containsKey(key)) {
        currentCounters[key] = 0;
      }
    });

    emit(state.copyWith(maxValues: newMaxValues, counters: currentCounters));
  }

  void resetProgress() {
    emit(
      state.copyWith(
        completedCards: [],
        counters: Map<int, int>.fromEntries(
          state.maxValues.entries.map((e) => MapEntry(e.key, 0)),
        ),
        cachedProgress: 0.0,
      ),
    );
  }

  void setCounter(int cardIndex, int value) {
    final currentCounters = Map<int, int>.from(state.counters);
    currentCounters[cardIndex] = value;
    emit(state.copyWith(counters: currentCounters));
  }
}
