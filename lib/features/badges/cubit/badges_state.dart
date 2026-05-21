part of 'badges_cubit.dart';

abstract class BadgesState {
  const BadgesState();
}

class BadgesInitial extends BadgesState {}

class BadgesLoading extends BadgesState {}

class BadgesLoaded extends BadgesState {
  final List<BadgeModel> badges;
  const BadgesLoaded(this.badges);
}

class BadgesError extends BadgesState {
  final String message;
  const BadgesError(this.message);
}

class BadgesSubmissionLoading extends BadgesState {}

class BadgesSubmissionSuccess extends BadgesState {
  final BadgeModel badge;
  final String reason;
  final bool isNewlyUnlocked;

  const BadgesSubmissionSuccess({
    required this.badge,
    required this.reason,
    required this.isNewlyUnlocked,
  });
}

class BadgesSubmissionRejected extends BadgesState {
  final String message;
  const BadgesSubmissionRejected(this.message);
}
