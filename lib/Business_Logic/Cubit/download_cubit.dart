import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:serat/Data/services/download_service.dart';
import 'package:serat/Business_Logic/Models/download_model.dart';
import 'package:serat/Business_Logic/Models/reciter_model.dart';

// States
abstract class DownloadState extends Equatable {
  const DownloadState();

  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadState {}

class DownloadLoading extends DownloadState {}

class DownloadProgressUpdated extends DownloadState {
  final DownloadProgress progress;
  final DownloadBatch? batch;

  const DownloadProgressUpdated(this.progress, [this.batch]);

  @override
  List<Object?> get props => [progress, batch];
}

class DownloadBatchCreated extends DownloadState {
  final DownloadBatch batch;

  const DownloadBatchCreated(this.batch);

  @override
  List<Object?> get props => [batch];
}

class DownloadBatchCompleted extends DownloadState {
  final DownloadBatch batch;

  const DownloadBatchCompleted(this.batch);

  @override
  List<Object?> get props => [batch];
}

class DownloadBatchFailed extends DownloadState {
  final DownloadBatch batch;
  final String error;

  const DownloadBatchFailed(this.batch, this.error);

  @override
  List<Object?> get props => [batch, error];
}

class DownloadStorageInfoLoaded extends DownloadState {
  final Map<String, dynamic> storageInfo;
  final List<DownloadBatch> batches;

  const DownloadStorageInfoLoaded(this.storageInfo, this.batches);

  @override
  List<Object?> get props => [storageInfo, batches];
}

class DownloadError extends DownloadState {
  final String message;

  const DownloadError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class DownloadCubit extends Cubit<DownloadState> {
  final DownloadService _downloadService = DownloadService();

  DownloadCubit() : super(DownloadInitial());

  static DownloadCubit get(context) => BlocProvider.of(context);

  Future<void> initialize() async {
    try {
      await _downloadService.initialize();
      await loadStorageInfo();
    } catch (e) {
      emit(DownloadError('Failed to initialize download service: $e'));
    }
  }

  Future<void> downloadSurah({
    required Reciter reciter,
    required Moshaf moshaf,
    required int surahNumber,
  }) async {
    try {
      await _downloadService.downloadSurah(
        reciter: reciter,
        moshaf: moshaf,
        surahNumber: surahNumber,
        onProgress: (progress) {
          emit(DownloadProgressUpdated(progress));
        },
        onComplete: (progress) {
          emit(DownloadProgressUpdated(progress));
          loadStorageInfo(); // Refresh storage info
        },
        onError: (progress) {
          emit(DownloadProgressUpdated(progress));
        },
      );
    } catch (e) {
      emit(DownloadError('Failed to download surah: $e'));
    }
  }

  Future<void> downloadMultipleSurahs({
    required Reciter reciter,
    required Moshaf moshaf,
    required List<int> surahNumbers,
  }) async {
    try {
      await _downloadService.downloadMultipleSurahs(
        reciter: reciter,
        moshaf: moshaf,
        surahNumbers: surahNumbers,
        onBatchCreated: (batch) {
          emit(DownloadBatchCreated(batch));
        },
        onProgress: (progress) {
          final batch = _downloadService.getBatch(
              reciter.id.toString(), moshaf.id.toString());
          emit(DownloadProgressUpdated(progress, batch));
        },
        onComplete: (batch) {
          emit(DownloadBatchCompleted(batch));
          loadStorageInfo(); // Refresh storage info
        },
        onError: (batch) {
          emit(DownloadBatchFailed(batch, 'Some downloads failed'));
        },
      );
    } catch (e) {
      emit(DownloadError('Failed to download multiple surahs: $e'));
    }
  }

  Future<void> cancelDownload(
      String reciterId, String moshafId, int surahNumber) async {
    try {
      await _downloadService.cancelDownload(reciterId, moshafId, surahNumber);
    } catch (e) {
      emit(DownloadError('Failed to cancel download: $e'));
    }
  }

  Future<void> cancelBatch(String reciterId, String moshafId) async {
    try {
      await _downloadService.cancelBatch(reciterId, moshafId);
    } catch (e) {
      emit(DownloadError('Failed to cancel batch: $e'));
    }
  }

  Future<void> resumeBatch({
    required Reciter reciter,
    required Moshaf moshaf,
  }) async {
    try {
      await _downloadService.resumeBatch(
        reciter: reciter,
        moshaf: moshaf,
        onProgress: (progress) {
          final batch = _downloadService.getBatch(
              reciter.id.toString(), moshaf.id.toString());
        	  emit(DownloadProgressUpdated(progress, batch));
        },
        onComplete: (batch) {
          emit(DownloadBatchCompleted(batch));
          loadStorageInfo();
        },
        onError: (batch) {
          emit(DownloadBatchFailed(batch, 'Some downloads failed'));
        },
      );
    } catch (e) {
      emit(DownloadError('Failed to resume batch: $e'));
    }
  }

  Future<void> deleteDownloadedSurah(
      String reciterId, String moshafId, int surahNumber) async {
    try {
      await _downloadService.deleteDownloadedSurah(
          reciterId, moshafId, surahNumber);
      await loadStorageInfo(); // Refresh storage info
    } catch (e) {
      emit(DownloadError('Failed to delete downloaded surah: $e'));
    }
  }

  Future<void> deleteBatch(String reciterId, String moshafId) async {
    try {
      await _downloadService.deleteBatch(reciterId, moshafId);
      await loadStorageInfo(); // Refresh storage info
    } catch (e) {
      emit(DownloadError('Failed to delete batch: $e'));
    }
  }

  Future<void> loadStorageInfo() async {
    try {
      final storageInfo = await _downloadService.getStorageInfo();
      final batches = _downloadService.getAllBatches();
      emit(DownloadStorageInfoLoaded(storageInfo, batches));
    } catch (e) {
      emit(DownloadError('Failed to load storage info: $e'));
    }
  }

  Future<String?> getOfflineAudioPath(
      String reciterId, String moshafId, int surahNumber) async {
    try {
      return await _downloadService.getOfflineAudioPath(
          reciterId, moshafId, surahNumber);
    } catch (e) {
      emit(DownloadError('Failed to get offline audio path: $e'));
      return null;
    }
  }

  bool isSurahDownloaded(String reciterId, String moshafId, int surahNumber) {
    final batch = _downloadService.getBatch(reciterId, moshafId);
    if (batch != null) {
      final progress = batch.progressList.firstWhere(
        (p) => p.surahNumber == surahNumber,
        orElse: () => DownloadProgress(
          reciterId: reciterId,
          moshafId: moshafId,
          surahNumber: surahNumber,
          status: DownloadStatus.notStarted,
        ),
      );
      return progress.status == DownloadStatus.completed;
    }
    return false;
  }

  DownloadBatch? getBatch(String reciterId, String moshafId) {
    return _downloadService.getBatch(reciterId, moshafId);
  }

  List<DownloadProgress> getActiveDownloads() {
    return _downloadService.getActiveDownloads();
  }

  List<DownloadBatch> getAllBatches() {
    return _downloadService.getAllBatches();
  }
}
