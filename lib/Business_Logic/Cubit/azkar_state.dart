class AzkarState {
  final int currentIndex;
  final List<int> completedCards;
  final int totalCards;
  final Map<int, int> counters;
  final Map<int, int> maxValues;

  AzkarState({
    required this.currentIndex,
    this.completedCards = const [],
    this.totalCards = 0,
    this.counters = const {},
    this.maxValues = const {},
  });

  double get progress =>
      totalCards > 0 ? completedCards.length / totalCards : 0;

  AzkarState copyWith({
    int? currentIndex,
    List<int>? completedCards,
    int? totalCards,
    Map<int, int>? counters,
    Map<int, int>? maxValues,
  }) {
    return AzkarState(
      currentIndex: currentIndex ?? this.currentIndex,
      completedCards: completedCards ?? this.completedCards,
      totalCards: totalCards ?? this.totalCards,
      counters: counters ?? this.counters,
      maxValues: maxValues ?? this.maxValues,
    );
  }
}
