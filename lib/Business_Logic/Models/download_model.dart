import 'package:equatable/equatable.dart';

enum DownloadStatus {
  notStarted,
  downloading,
  completed,
  failed,
  paused,
  cancelled,
}

class DownloadProgress extends Equatable {
  final String reciterId;
  final String moshafId;
  final int surahNumber;
  final DownloadStatus status;
  final double progress; // 0.0 to 1.0
  final int downloadedBytes;
  final int totalBytes;
  final String? errorMessage;
  final DateTime? startTime;
  final DateTime? completedTime;

  const DownloadProgress({
    required this.reciterId,
    required this.moshafId,
    required this.surahNumber,
    required this.status,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.errorMessage,
    this.startTime,
    this.completedTime,
  });

  DownloadProgress copyWith({
    String? reciterId,
    String? moshafId,
    int? surahNumber,
    DownloadStatus? status,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
    String? errorMessage,
    DateTime? startTime,
    DateTime? completedTime,
  }) {
    return DownloadProgress(
      reciterId: reciterId ?? this.reciterId,
      moshafId: moshafId ?? this.moshafId,
      surahNumber: surahNumber ?? this.surahNumber,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      errorMessage: errorMessage ?? this.errorMessage,
      startTime: startTime ?? this.startTime,
      completedTime: completedTime ?? this.completedTime,
    );
  }

  @override
  List<Object?> get props => [
        reciterId,
        moshafId,
        surahNumber,
        status,
        progress,
        downloadedBytes,
        totalBytes,
        errorMessage,
        startTime,
        completedTime,
      ];
}

class DownloadBatch {
  final String reciterId;
  final String reciterName;
  final String moshafId;
  final String moshafName;
  final List<int> surahNumbers;
  final List<DownloadProgress> progressList;
  final DateTime createdAt;

  const DownloadBatch({
    required this.reciterId,
    required this.reciterName,
    required this.moshafId,
    required this.moshafName,
    required this.surahNumbers,
    required this.progressList,
    required this.createdAt,
  });

  double get overallProgress {
    if (progressList.isEmpty) return 0.0;
    final completedCount = progressList
        .where((progress) => progress.status == DownloadStatus.completed)
        .length;
    return completedCount / progressList.length;
  }

  DownloadStatus get overallStatus {
    if (progressList.isEmpty) return DownloadStatus.notStarted;

    final hasFailed =
        progressList.any((p) => p.status == DownloadStatus.failed);
    final hasDownloading =
        progressList.any((p) => p.status == DownloadStatus.downloading);
    final hasPaused =
        progressList.any((p) => p.status == DownloadStatus.paused);
    final allCompleted =
        progressList.every((p) => p.status == DownloadStatus.completed);

    if (hasFailed) return DownloadStatus.failed;
    if (allCompleted) return DownloadStatus.completed;
    if (hasDownloading) return DownloadStatus.downloading;
    if (hasPaused) return DownloadStatus.paused;
    return DownloadStatus.notStarted;
  }

  int get completedCount => progressList
      .where((progress) => progress.status == DownloadStatus.completed)
      .length;

  int get totalCount => progressList.length;
}
