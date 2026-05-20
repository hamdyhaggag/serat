import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:serat/Business_Logic/Models/download_model.dart';
import 'package:serat/Business_Logic/Models/reciter_model.dart';

class DownloadService {
  static const String _downloadsKey = 'quran_downloads';
  static const String _downloadsDir = 'quran_downloads';
  static const int _maxConcurrentDownloads = 3;

  final Map<String, DownloadProgress> _activeDownloads = {};
  final Map<String, DownloadBatch> _downloadBatches = {};
  bool _isInitialized = false;
  Directory? _downloadsDirectory;
  // Debounce timer: prevents writing to SharedPreferences on every download chunk.
  // Terminal state changes (completed/failed/cancelled) bypass this via _saveNow().
  Timer? _saveDebounce;

  // Singleton pattern
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  /// Schedules a debounced save (fires after 2 s of inactivity).
  /// Used for intermediate progress updates during streaming.
  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(seconds: 2), _saveDownloadBatches);
  }

  /// Saves immediately, cancelling any pending debounced save.
  /// Used for terminal state changes (completed / failed / cancelled).
  Future<void> _saveNow() async {
    _saveDebounce?.cancel();
    await _saveDownloadBatches();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      _downloadsDirectory = Directory('${appDir.path}/$_downloadsDir');

      if (!await _downloadsDirectory!.exists()) {
        await _downloadsDirectory!.create(recursive: true);
      }

      await _loadDownloadBatches();
      _isInitialized = true;
    } catch (e) {
      log('Error initializing DownloadService: $e');
    }
  }

  Future<void> _loadDownloadBatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final batchesJson = prefs.getString(_downloadsKey);

      if (batchesJson != null) {
        final List<dynamic> batchesList = json.decode(batchesJson);
        for (final batchJson in batchesList) {
          final batch = _downloadBatchFromJson(batchJson);
          _downloadBatches[batch.reciterId + '_' + batch.moshafId] = batch;
        }
      }
    } catch (e) {
      log('Error loading download batches: $e');
    }
  }

  Future<void> _saveDownloadBatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final batchesList = _downloadBatches.values
          .map((batch) => _downloadBatchToJson(batch))
          .toList();
      await prefs.setString(_downloadsKey, json.encode(batchesList));
    } catch (e) {
      log('Error saving download batches: $e');
    }
  }

  Map<String, dynamic> _downloadBatchToJson(DownloadBatch batch) {
    return {
      'reciterId': batch.reciterId,
      'reciterName': batch.reciterName,
      'moshafId': batch.moshafId,
      'moshafName': batch.moshafName,
      'surahNumbers': batch.surahNumbers,
      'progressList':
          batch.progressList.map((p) => _downloadProgressToJson(p)).toList(),
      'createdAt': batch.createdAt.millisecondsSinceEpoch,
    };
  }

  DownloadBatch _downloadBatchFromJson(Map<String, dynamic> json) {
    return DownloadBatch(
      reciterId: json['reciterId'],
      reciterName: json['reciterName'],
      moshafId: json['moshafId'],
      moshafName: json['moshafName'],
      surahNumbers: List<int>.from(json['surahNumbers']),
      progressList: (json['progressList'] as List)
          .map((p) => _downloadProgressFromJson(p))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    );
  }

  Map<String, dynamic> _downloadProgressToJson(DownloadProgress progress) {
    return {
      'reciterId': progress.reciterId,
      'moshafId': progress.moshafId,
      'surahNumber': progress.surahNumber,
      'status': progress.status.index,
      'progress': progress.progress,
      'downloadedBytes': progress.downloadedBytes,
      'totalBytes': progress.totalBytes,
      'errorMessage': progress.errorMessage,
      'startTime': progress.startTime?.millisecondsSinceEpoch,
      'completedTime': progress.completedTime?.millisecondsSinceEpoch,
    };
  }

  DownloadProgress _downloadProgressFromJson(Map<String, dynamic> json) {
    return DownloadProgress(
      reciterId: json['reciterId'],
      moshafId: json['moshafId'],
      surahNumber: json['surahNumber'],
      status: DownloadStatus.values[json['status']],
      progress: json['progress']?.toDouble() ?? 0.0,
      downloadedBytes: json['downloadedBytes'] ?? 0,
      totalBytes: json['totalBytes'] ?? 0,
      errorMessage: json['errorMessage'],
      startTime: json['startTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['startTime'])
          : null,
      completedTime: json['completedTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedTime'])
          : null,
    );
  }

  Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> downloadSurah({
    required Reciter reciter,
    required Moshaf moshaf,
    required int surahNumber,
    required Function(DownloadProgress) onProgress,
    required Function(DownloadProgress) onComplete,
    required Function(DownloadProgress) onError,
  }) async {
    if (!_isInitialized) await initialize();

    final downloadKey = '${reciter.id}_${moshaf.id}_$surahNumber';

    // Check if already downloaded
    if (await _isSurahDownloaded(
        reciter.id.toString(), moshaf.id.toString(), surahNumber)) {
      final progress = DownloadProgress(
        reciterId: reciter.id.toString(),
        moshafId: moshaf.id.toString(),
        surahNumber: surahNumber,
        status: DownloadStatus.completed,
        progress: 1.0,
      );
      onComplete(progress);
      return;
    }

    // Check if already downloading
    if (_activeDownloads.containsKey(downloadKey)) {
      return;
    }

    // Check concurrent downloads limit
    if (_activeDownloads.length >= _maxConcurrentDownloads) {
      final progress = DownloadProgress(
        reciterId: reciter.id.toString(),
        moshafId: moshaf.id.toString(),
        surahNumber: surahNumber,
        status: DownloadStatus.failed,
        errorMessage: 'Too many concurrent downloads',
      );
      onError(progress);
      return;
    }

    // Check connectivity
    if (!await isConnected()) {
      final progress = DownloadProgress(
        reciterId: reciter.id.toString(),
        moshafId: moshaf.id.toString(),
        surahNumber: surahNumber,
        status: DownloadStatus.failed,
        errorMessage: 'No internet connection',
      );
      onError(progress);
      return;
    }

    final audioUrl = _buildAudioUrl(moshaf.server, surahNumber);
    final fileName =
        '${reciter.id}_${moshaf.id}_${surahNumber.toString().padLeft(3, '0')}.mp3';
    final filePath = '${_downloadsDirectory!.path}/$fileName';

    var progress = DownloadProgress(
      reciterId: reciter.id.toString(),
      moshafId: moshaf.id.toString(),
      surahNumber: surahNumber,
      status: DownloadStatus.downloading,
      startTime: DateTime.now(),
    );

    _activeDownloads[downloadKey] = progress;
    onProgress(progress);
    _updateBatchProgress(reciter, moshaf, progress);

    try {
      final request = http.Request('GET', Uri.parse(audioUrl));
      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        throw Exception('HTTP ${streamedResponse.statusCode}');
      }

      final totalBytes = streamedResponse.contentLength ?? 0;
      int downloadedBytes = 0;

      final file = File(filePath);
      final sink = file.openWrite();

      await for (final chunk in streamedResponse.stream) {
        if (_activeDownloads[downloadKey]?.status == DownloadStatus.cancelled) {
          sink.close();
          await file.delete();
          return;
        }

        sink.add(chunk);
        downloadedBytes += chunk.length;

        if (totalBytes > 0) {
          final newProgress = downloadedBytes / totalBytes;
          progress = progress.copyWith(
            progress: newProgress,
            downloadedBytes: downloadedBytes,
            totalBytes: totalBytes,
          );
          _activeDownloads[downloadKey] = progress;
          onProgress(progress);
        }
      }

      await sink.close();

      progress = progress.copyWith(
        status: DownloadStatus.completed,
        progress: 1.0,
        completedTime: DateTime.now(),
      );

      _activeDownloads.remove(downloadKey);
      onComplete(progress);

      // Update batch progress
      _updateBatchProgress(reciter, moshaf, progress);
    } catch (e) {
      progress = progress.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
      _activeDownloads.remove(downloadKey);
      onError(progress);

      // Clean up partial file
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> downloadMultipleSurahs({
    required Reciter reciter,
    required Moshaf moshaf,
    required List<int> surahNumbers,
    required Function(DownloadBatch) onBatchCreated,
    required Function(DownloadProgress) onProgress,
    required Function(DownloadBatch) onComplete,
    required Function(DownloadBatch) onError,
  }) async {
    if (!_isInitialized) await initialize();

    final batchKey = '${reciter.id}_${moshaf.id}';

    // Create or get existing batch
    var batch = _downloadBatches[batchKey];
    if (batch == null) {
      final progressList = surahNumbers
          .map((surah) => DownloadProgress(
                reciterId: reciter.id.toString(),
                moshafId: moshaf.id.toString(),
                surahNumber: surah,
                status: DownloadStatus.notStarted,
              ))
          .toList();

      batch = DownloadBatch(
        reciterId: reciter.id.toString(),
        reciterName: reciter.name,
        moshafId: moshaf.id.toString(),
        moshafName: moshaf.name,
        surahNumbers: surahNumbers,
        progressList: progressList,
        createdAt: DateTime.now(),
      );

      _downloadBatches[batchKey] = batch;
      await _saveDownloadBatches();
      onBatchCreated(batch);
    }

    // Start downloads concurrently in batches of _maxConcurrentDownloads
    final pending = surahNumbers.where((surahNumber) {
      final existingProgress = batch!.progressList.firstWhere(
        (p) => p.surahNumber == surahNumber,
        orElse: () => DownloadProgress(
          reciterId: reciter.id.toString(),
          moshafId: moshaf.id.toString(),
          surahNumber: surahNumber,
          status: DownloadStatus.notStarted,
        ),
      );
      return existingProgress.status != DownloadStatus.completed;
    }).toList();

    for (var i = 0; i < pending.length; i += _maxConcurrentDownloads) {
      final end = (i + _maxConcurrentDownloads).clamp(0, pending.length);
      final chunk = pending.sublist(i, end);

      await Future.wait(chunk.map((surahNumber) => downloadSurah(
        reciter: reciter,
        moshaf: moshaf,
        surahNumber: surahNumber,
        onProgress: (progress) {
          _updateBatchProgress(reciter, moshaf, progress);
          onProgress(progress);
        },
        onComplete: (progress) {
          _updateBatchProgress(reciter, moshaf, progress);
          final updatedBatch = _downloadBatches[batchKey];
          if (updatedBatch != null &&
              updatedBatch.overallStatus == DownloadStatus.completed) {
            onComplete(updatedBatch);
          }
        },
        onError: (progress) {
          _updateBatchProgress(reciter, moshaf, progress);
          final updatedBatch = _downloadBatches[batchKey];
          if (updatedBatch != null) {
            onError(updatedBatch);
          }
        },
      )));
    }
  }

  Future<void> resumeBatch({
    required Reciter reciter,
    required Moshaf moshaf,
    required Function(DownloadProgress) onProgress,
    required Function(DownloadBatch) onComplete,
    required Function(DownloadBatch) onError,
  }) async {
    if (!_isInitialized) await initialize();

    final batchKey = '${reciter.id}_${moshaf.id}';
    final batch = _downloadBatches[batchKey];
    if (batch == null) {
      return;
    }

    final pending = batch.surahNumbers.where((surahNumber) {
      final p = batch.progressList.firstWhere(
        (x) => x.surahNumber == surahNumber,
        orElse: () => DownloadProgress(
          reciterId: reciter.id.toString(),
          moshafId: moshaf.id.toString(),
          surahNumber: surahNumber,
          status: DownloadStatus.notStarted,
        ),
      );
      return p.status != DownloadStatus.completed &&
          p.status != DownloadStatus.downloading;
    }).toList();

    for (var i = 0; i < pending.length; i += _maxConcurrentDownloads) {
      final end = (i + _maxConcurrentDownloads).clamp(0, pending.length);
      final chunk = pending.sublist(i, end);
      await Future.wait(chunk.map((surah) => downloadSurah(
        reciter: reciter,
        moshaf: moshaf,
        surahNumber: surah,
        onProgress: (progress) {
          _updateBatchProgress(reciter, moshaf, progress);
          onProgress(progress);
        },
        onComplete: (progress) {
          _updateBatchProgress(reciter, moshaf, progress);
          final updatedBatch = _downloadBatches[batchKey];
          if (updatedBatch != null &&
              updatedBatch.overallStatus == DownloadStatus.completed) {
            onComplete(updatedBatch);
          }
        },
        onError: (progress) {
          _updateBatchProgress(reciter, moshaf, progress);
          final updatedBatch = _downloadBatches[batchKey];
          if (updatedBatch != null) onError(updatedBatch);
        },
      )));
    }
  }

  void _updateBatchProgress(
      Reciter reciter, Moshaf moshaf, DownloadProgress progress) {
    final batchKey = '${reciter.id}_${moshaf.id}';
    final existing = _downloadBatches[batchKey];

    if (existing == null) {
      // Create a batch for single-surah downloads automatically
      final newBatch = DownloadBatch(
        reciterId: reciter.id.toString(),
        reciterName: reciter.name,
        moshafId: moshaf.id.toString(),
        moshafName: moshaf.name,
        surahNumbers: [progress.surahNumber],
        progressList: [progress],
        createdAt: DateTime.now(),
      );
      _downloadBatches[batchKey] = newBatch;
      _saveNow(); // New batch — always save immediately
      return;
    }

    // Ensure the surah exists in the batch
    final progressIndex = existing.progressList.indexWhere(
      (p) => p.surahNumber == progress.surahNumber,
    );

    if (progressIndex == -1) {
      final updatedProgressList =
          List<DownloadProgress>.from(existing.progressList)..add(progress);
      final updatedSurahNumbers = List<int>.from(existing.surahNumbers)
        ..add(progress.surahNumber);

      _downloadBatches[batchKey] = DownloadBatch(
        reciterId: existing.reciterId,
        reciterName: existing.reciterName,
        moshafId: existing.moshafId,
        moshafName: existing.moshafName,
        surahNumbers: updatedSurahNumbers,
        progressList: updatedProgressList,
        createdAt: existing.createdAt,
      );
      _saveNow(); // Structural change — save immediately
      return;
    }

    // Update existing entry
    final updatedProgressList =
        List<DownloadProgress>.from(existing.progressList);
    updatedProgressList[progressIndex] = progress;

    _downloadBatches[batchKey] = DownloadBatch(
      reciterId: existing.reciterId,
      reciterName: existing.reciterName,
      moshafId: existing.moshafId,
      moshafName: existing.moshafName,
      surahNumbers: existing.surahNumbers,
      progressList: updatedProgressList,
      createdAt: existing.createdAt,
    );

    // For terminal states (completed/failed/cancelled) save immediately;
    // for in-progress updates use debounced save to reduce I/O.
    const terminalStates = {DownloadStatus.completed, DownloadStatus.failed, DownloadStatus.cancelled};
    if (terminalStates.contains(progress.status)) {
      _saveNow();
    } else {
      _scheduleSave();
    }
  }

  Future<bool> _isSurahDownloaded(
      String reciterId, String moshafId, int surahNumber) async {
    final fileName =
        '${reciterId}_${moshafId}_${surahNumber.toString().padLeft(3, '0')}.mp3';
    final filePath = '${_downloadsDirectory!.path}/$fileName';
    final file = File(filePath);
    return await file.exists();
  }

  Future<String?> getOfflineAudioPath(
      String reciterId, String moshafId, int surahNumber) async {
    if (!_isInitialized) await initialize();

    final fileName =
        '${reciterId}_${moshafId}_${surahNumber.toString().padLeft(3, '0')}.mp3';
    final filePath = '${_downloadsDirectory!.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) {
      return filePath;
    }
    return null;
  }

  Future<void> cancelDownload(
      String reciterId, String moshafId, int surahNumber) async {
    final downloadKey = '${reciterId}_${moshafId}_$surahNumber';
    final progress = _activeDownloads[downloadKey];

    if (progress != null) {
      _activeDownloads[downloadKey] =
          progress.copyWith(status: DownloadStatus.cancelled);
    }
  }

  Future<void> cancelBatch(String reciterId, String moshafId) async {
    final batchKey = '${reciterId}_$moshafId';
    final batch = _downloadBatches[batchKey];

    if (batch != null) {
      // Cancel all active downloads in this batch
      for (final progress in batch.progressList) {
        if (progress.status == DownloadStatus.downloading) {
          await cancelDownload(
              progress.reciterId, progress.moshafId, progress.surahNumber);
        }
      }
    }
  }

  Future<void> deleteDownloadedSurah(
      String reciterId, String moshafId, int surahNumber) async {
    if (!_isInitialized) await initialize();

    final fileName =
        '${reciterId}_${moshafId}_${surahNumber.toString().padLeft(3, '0')}.mp3';
    final filePath = '${_downloadsDirectory!.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }

    // Update batch progress
    final batchKey = '${reciterId}_$moshafId';
    final batch = _downloadBatches[batchKey];
    if (batch != null) {
      final progressIndex = batch.progressList.indexWhere(
        (p) => p.surahNumber == surahNumber,
      );

      if (progressIndex != -1) {
        final updatedProgressList =
            List<DownloadProgress>.from(batch.progressList);
        updatedProgressList[progressIndex] = DownloadProgress(
          reciterId: reciterId,
          moshafId: moshafId,
          surahNumber: surahNumber,
          status: DownloadStatus.notStarted,
        );

        _downloadBatches[batchKey] = DownloadBatch(
          reciterId: batch.reciterId,
          reciterName: batch.reciterName,
          moshafId: batch.moshafId,
          moshafName: batch.moshafName,
          surahNumbers: batch.surahNumbers,
          progressList: updatedProgressList,
          createdAt: batch.createdAt,
        );

        await _saveDownloadBatches();
      }
    }
  }

  Future<void> deleteBatch(String reciterId, String moshafId) async {
    if (!_isInitialized) await initialize();

    final batchKey = '${reciterId}_$moshafId';
    final batch = _downloadBatches[batchKey];

    if (batch != null) {
      // Delete all downloaded files
      for (final progress in batch.progressList) {
        if (progress.status == DownloadStatus.completed) {
          await deleteDownloadedSurah(
              progress.reciterId, progress.moshafId, progress.surahNumber);
        }
      }

      // Remove batch from memory and storage
      _downloadBatches.remove(batchKey);
      await _saveDownloadBatches();
    }
  }

  Future<Map<String, dynamic>> getStorageInfo() async {
    if (!_isInitialized) await initialize();

    int totalFiles = 0;
    int totalSize = 0;

    if (await _downloadsDirectory!.exists()) {
      await for (final entity in _downloadsDirectory!.list()) {
        if (entity is File) {
          totalFiles++;
          totalSize += await entity.length();
        }
      }
    }

    return {
      'totalFiles': totalFiles,
      'totalSize': totalSize,
      'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
    };
  }

  List<DownloadBatch> getAllBatches() {
    return _downloadBatches.values.toList();
  }

  DownloadBatch? getBatch(String reciterId, String moshafId) {
    return _downloadBatches['${reciterId}_$moshafId'];
  }

  List<DownloadProgress> getActiveDownloads() {
    return _activeDownloads.values.toList();
  }

  String _buildAudioUrl(String server, int surah) {
    String serverUrl = server;
    if (!serverUrl.endsWith('/')) serverUrl = '$serverUrl/';
    return '$serverUrl${surah.toString().padLeft(3, '0')}.mp3';
  }
}
