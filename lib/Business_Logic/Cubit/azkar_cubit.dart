import 'package:flutter_bloc/flutter_bloc.dart';
import 'azkar_state.dart';

class AzkarCubit extends Cubit<AzkarState> {
  AzkarCubit() : super(AzkarState(currentIndex: 0));

  void updateIndex(int newIndex) {
    emit(state.copyWith(currentIndex: newIndex));
  }

  void updateCompletedCards(int newCompletedCount) {
    emit(state.copyWith(completedCards: newCompletedCount));
  }

  void updateTotalCards(int newTotalCount) {
    emit(state.copyWith(totalCards: newTotalCount));
  }
}
