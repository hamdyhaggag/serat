import 'package:serat/domain/models/hadith_model.dart';

class SearchState {
  final String query;
  final List<HadithModel> filteredHadiths;
  final Map<String, List<HadithModel>> groupedHadiths;

  const SearchState({
    this.query = '',
    this.filteredHadiths = const [],
    this.groupedHadiths = const {},
  });

  SearchState copyWith({
    String? query,
    List<HadithModel>? filteredHadiths,
    Map<String, List<HadithModel>>? groupedHadiths,
  }) {
    return SearchState(
      query: query ?? this.query,
      filteredHadiths: filteredHadiths ?? this.filteredHadiths,
      groupedHadiths: groupedHadiths ?? this.groupedHadiths,
    );
  }
}
