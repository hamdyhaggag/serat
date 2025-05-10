class AzkarState {
  final int currentIndex;
  final int completedCards;
  final int totalCards;

  AzkarState({
    required this.currentIndex,
    this.completedCards = 0,
    this.totalCards = 0,
  });

  double get progress => totalCards > 0 ? completedCards / totalCards : 0;

  AzkarState copyWith({
    int? currentIndex,
    int? completedCards,
    int? totalCards,
  }) {
    return AzkarState(
      currentIndex: currentIndex ?? this.currentIndex,
      completedCards: completedCards ?? this.completedCards,
      totalCards: totalCards ?? this.totalCards,
    );
  }
}
