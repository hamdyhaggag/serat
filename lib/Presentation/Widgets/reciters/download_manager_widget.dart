import 'dart:async';
import 'package:flutter/material.dart';
import 'package:serat/Data/services/audio_player_service.dart';
import 'package:serat/Business_Logic/Cubit/reciters_cubit.dart';
import 'package:serat/Business_Logic/Models/reciter_model.dart';
import 'package:serat/Business_Logic/Cubit/download_cubit.dart';
import 'package:serat/Business_Logic/Models/download_model.dart';
import 'package:serat/imports.dart';

class DownloadManagerWidget extends StatefulWidget {
  const DownloadManagerWidget({super.key});

  @override
  State<DownloadManagerWidget> createState() => _DownloadManagerWidgetState();
}

class _DownloadManagerWidgetState extends State<DownloadManagerWidget> {
  // Selection state for bulk actions
  final Set<String> _selected = {};
  bool get _selectionMode => _selected.isNotEmpty;
  // Local UI state
  String _query = '';
  DownloadStatus? _statusFilter; // null => All
  // Audio player state
  PlaybackState _playerState = PlaybackState.stopped;
  StreamSubscription<PlaybackState>? _playerSub;
  String?
      _currentlyPlayingKey; // reciterId_moshafId of the batch currently played from this widget

  @override
  void initState() {
    super.initState();
    // Listen to audio playback state to toggle Stop/Play buttons
    _playerState = AudioPlayerService().playbackState;
    _playerSub = AudioPlayerService().playbackStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _playerState = state;
        if (state == PlaybackState.stopped) {
          _currentlyPlayingKey = null; // clear association when playback stops
        }
      });
    });
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocConsumer<DownloadCubit, DownloadState>(
              listener: (context, state) {
                if (state is DownloadError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message ?? 'حدث خطأ غير متوقع')),
                  );
                }
              },
              builder: (context, state) {
                if (state is DownloadStorageInfoLoaded) {
                  return _buildContent(context, state);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  // Top grab handle for bottom sheet aesthetics
  Widget _buildTopHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // Search field and status filter chips row (in header)
  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'ابحث عن المقرئ  ...',
              hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontFamily: 'DIN'),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (val) =>
                setState(() => _query = val.trim().toLowerCase()),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            children: [
              _buildFilterChip(null, 'الكل'),
              const SizedBox(width: 6),
              _buildFilterChip(DownloadStatus.downloading, 'جاري التحميل'),
              const SizedBox(width: 6),
              _buildFilterChip(DownloadStatus.paused, 'متوقف مؤقتاً'),
              const SizedBox(width: 6),
              _buildFilterChip(DownloadStatus.completed, 'مكتمل'),
              const SizedBox(width: 6),
              _buildFilterChip(DownloadStatus.failed, 'فشل'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(DownloadStatus? status, String label) {
    final bool selected = _statusFilter == status;
    return ChoiceChip(
      label: AppText(
        label,
        fontSize: 12,
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      selected: selected,
      selectedColor: Colors.white,
      backgroundColor: Colors.white.withValues(alpha: 0.12),
      onSelected: (_) => setState(() => _statusFilter = status),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
    );
  }

  List<DownloadBatch> _applyFilters(List<DownloadBatch> batches) {
    Iterable<DownloadBatch> res = batches;
    if (_statusFilter != null) {
      res = res.where((b) => b.overallStatus == _statusFilter);
    }
    if (_query.isNotEmpty) {
      final q = _query;
      res = res.where((b) =>
          b.reciterName.toLowerCase().contains(q) ||
          b.moshafName.toLowerCase().contains(q));
    }
    return res.toList();
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopHandle(),
              Row(
                children: [
                  const Icon(Icons.download, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          'مدير التحميلات',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        AppText(
                          _selectionMode
                              ? 'تم تحديد ${_selected.length} عنصر'
                              : 'إدارة التحميلات والذاكرة',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                  if (_selectionMode) ...[
                    Tooltip(
                      message: 'إيقاف المؤقت للمحدد',
                      child: IconButton(
                        icon: const Icon(Icons.pause_circle_filled,
                            color: Colors.white),
                        onPressed: _onPauseSelected,
                      ),
                    ),
                    Tooltip(
                      message: 'استئناف المحدد',
                      child: IconButton(
                        icon: const Icon(Icons.play_circle_fill,
                            color: Colors.white),
                        onPressed: _onResumeSelected,
                      ),
                    ),
                    Tooltip(
                      message: 'حذف المحدد',
                      child: IconButton(
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.white),
                        onPressed: _onDeleteSelected,
                      ),
                    ),
                    Tooltip(
                      message: 'إلغاء التحديد',
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(_selected.clear),
                      ),
                    ),
                  ] else ...[
                    IconButton(
                      tooltip: 'إغلاق',
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _buildFilters(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DownloadStorageInfoLoaded state) {
    final List<DownloadBatch> filtered = _applyFilters(state.batches);
    final bool noResults = state.batches.isNotEmpty && filtered.isEmpty;
    return Column(
      children: [
        _buildStorageInfo(state.storageInfo),
        const Divider(height: 1),
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(noResults
                  ? 'لا توجد نتائج مطابقة لبحثك أو عوامل التصفية'
                  : null)
              : _buildBatchesList(context, filtered),
        ),
      ],
    );
  }

  Widget _buildStorageInfo(Map<String, dynamic> storageInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        // Decorated info tile
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryColor.withOpacity(0.12),
                child: Icon(Icons.storage, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'المساحة المستخدمة',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      '${storageInfo['totalSizeMB']} ميجابايت • ${storageInfo['totalFiles']} ملف',
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState([String? message]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_done,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          AppText(
            message ?? 'لا توجد تحميلات',
            fontSize: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          AppText(
            'قم بتحميل التلاوات للاستماع بدون إنترنت',
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchesList(BuildContext context, List<DownloadBatch> batches) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: batches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final batch = batches[index];
        final key = _batchKey(batch);
        final selected = _selected.contains(key);
        return Dismissible(
          key: ValueKey('dismiss_${batch.reciterId}_${batch.moshafId}'),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.red),
          ),
          confirmDismiss: (_) => _confirmDelete(context, batch),
          onDismissed: (_) => _performDelete(context, batch),
          child: _buildBatchCard(context, batch, selected, () {
            setState(() {
              if (selected) {
                _selected.remove(key);
              } else {
                _selected.add(key);
              }
            });
          }),
        );
      },
    );
  }

  Widget _buildBatchCard(
    BuildContext context,
    DownloadBatch batch,
    bool selected,
    VoidCallback onToggleSelect,
  ) {
    return InkWell(
      onLongPress: onToggleSelect,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? AppColors.primaryColor : Colors.transparent,
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: (_) => onToggleSelect(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.person, color: Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          batch.reciterName,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              batch.moshafName,
                              fontSize: 13,
                              color: Colors.grey[600],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            _buildStatusChip(batch.overallStatus),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox.shrink(),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: batch.overallProgress.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          batch.overallStatus == DownloadStatus.completed
                              ? Colors.green
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppText(
                    '${batch.completedCount}/${batch.totalCount}',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'تم التحميل: ${batch.completedCount} سورة',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  Row(
                    children: [
                      _buildPrimaryAction(batch),
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'حذف',
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          icon: const Icon(Icons.delete_outline,
                              size: 20, color: Colors.red),
                          label: const AppText('حذف',
                              fontSize: 12, color: Colors.red),
                          onPressed: () => _deleteBatch(context, batch),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryAction(DownloadBatch batch) {
    final key = _batchKey(batch);
    final isPlayingThis =
        _playerState == PlaybackState.playing && _currentlyPlayingKey == key;
    final hasAnyCompleted = batch.completedCount > 0;
    final isDownloading = batch.overallStatus == DownloadStatus.downloading;

    final tooltip = isPlayingThis
        ? 'إيقاف'
        : hasAnyCompleted
            ? 'تشغيل الآن'
            : (isDownloading ? 'إيقاف مؤقت' : 'استئناف');

    final IconData icon = isPlayingThis
        ? Icons.stop
        : hasAnyCompleted
            ? Icons.play_arrow
            : (isDownloading ? Icons.pause : Icons.play_arrow);

    final String label = isPlayingThis
        ? 'إيقاف'
        : hasAnyCompleted
            ? 'تشغيل الآن'
            : (isDownloading ? 'إيقاف' : 'استئناف');

    return Tooltip(
      message: tooltip,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
        ),
        icon: Icon(icon, size: 20),
        label: AppText(
          label,
          fontSize: 12,
          color: AppColors.primaryColor,
        ),
        onPressed: () {
          if (isPlayingThis) {
            setState(() => _currentlyPlayingKey = null);
            AudioPlayerService().stop();
          } else if (hasAnyCompleted) {
            _showDownloadedSurahsPicker(context, batch);
          } else if (isDownloading) {
            _pauseBatch(context, batch);
          } else {
            _resumeBatch(context, batch);
          }
        },
      ),
    );
  }

  Widget _buildStatusChip(DownloadStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case DownloadStatus.completed:
        color = Colors.green;
        text = 'مكتمل';
        icon = Icons.check_circle;
        break;
      case DownloadStatus.downloading:
        color = AppColors.primaryColor;
        text = 'جاري التحميل';
        icon = Icons.downloading;
        break;
      case DownloadStatus.paused:
        color = Colors.orange;
        text = 'متوقف مؤقتاً';
        icon = Icons.pause_circle;
        break;
      case DownloadStatus.failed:
        color = Colors.red;
        text = 'فشل';
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        text = 'غير محمل';
        icon = Icons.download;
    }

    // Improve contrast in light mode
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgOpacity = isLight ? 0.12 : 0.18;
    final borderOpacity = isLight ? 0.28 : 0.35;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: bgOpacity),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: borderOpacity)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          AppText(
            text,
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  // Actions
  void _onPauseSelected() {
    if (_selected.isEmpty) return;
    final cubit = DownloadCubit.get(context);
    for (final key in _selected) {
      final parts = key.split('_');
      if (parts.length == 2) {
        cubit.cancelBatch(parts[0], parts[1]);
      }
    }
  }

  void _onResumeSelected() async {
    if (_selected.isEmpty) return;
    final recitersCubit = RecitersCubit.get(context);
    final model = recitersCubit.recitersModel;
    if (model == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('لا يمكن الاستئناف: معلومات المقرئين غير متاحة')),
      );
      return;
    }

    for (final key in _selected) {
      final parts = key.split('_');
      if (parts.length != 2) continue;
      final reciterId = parts[0];
      final moshafId = parts[1];

      Reciter? reciter;
      Moshaf? moshaf;

      for (final r in model.reciters) {
        if (r.id.toString() == reciterId) {
          reciter = r;
          moshaf = r.moshaf.firstWhere(
            (m) => m.id.toString() == moshafId,
            orElse: () => r.moshaf.isNotEmpty
                ? r.moshaf.first
                : Moshaf(
                    id: int.tryParse(moshafId) ?? 0,
                    name: '',
                    server: '',
                    surahTotal: 0,
                    moshafType: 0,
                    surahList: '',
                  ),
          );
          break;
        }
      }

      if (reciter != null && moshaf != null && moshaf.server.isNotEmpty) {
        DownloadCubit.get(context)
            .resumeBatch(reciter: reciter, moshaf: moshaf);
      }
    }
  }

  Future<bool> _confirmDelete(BuildContext context, DownloadBatch batch) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('حذف التحميلات'),
        content: AppText(
          'هل أنت متأكد من حذف جميع تحميلات ${batch.reciterName} - ${batch.moshafName}؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const AppText('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const AppText('حذف', color: Colors.red),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  void _performDelete(BuildContext context, DownloadBatch batch) {
    DownloadCubit.get(context).deleteBatch(batch.reciterId, batch.moshafId);
    final key = _batchKey(batch);
    if (_selected.contains(key)) {
      setState(() => _selected.remove(key));
    }
  }

  Future<void> _deleteBatch(BuildContext context, DownloadBatch batch) async {
    final confirmed = await _confirmDelete(context, batch);
    if (confirmed) {
      _performDelete(context, batch);
    }
  }

  Future<void> _playBatch(BuildContext context, DownloadBatch batch) async {
    final recitersCubit = RecitersCubit.get(context);
    final model = recitersCubit.recitersModel;
    if (model == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('لا يمكن التشغيل: معلومات المقرئين غير متاحة')),
      );
      return;
    }

    late Reciter reciter;
    try {
      reciter = model.reciters.firstWhere(
        (r) => r.id.toString() == batch.reciterId,
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('لا يمكن التشغيل: لم يتم العثور على المقرئ')),
      );
      return;
    }

    late Moshaf moshaf;
    try {
      moshaf = reciter.moshaf.firstWhere(
        (m) => m.id.toString() == batch.moshafId,
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('لا يمكن التشغيل: لم يتم العثور على المصحف')),
      );
      return;
    }

    final completed = batch.progressList
        .where((p) => p.status == DownloadStatus.completed)
        .map((p) => p.surahNumber)
        .toList();
    final int surahToPlay = completed.isNotEmpty
        ? completed.first
        : (batch.surahNumbers.isNotEmpty ? batch.surahNumbers.first : 1);

    setState(() => _currentlyPlayingKey = _batchKey(batch));
    await AudioPlayerService().playRecitation(
      reciter: reciter,
      moshaf: moshaf,
      surahNumber: surahToPlay,
    );
  }

  void _onDeleteSelected() async {
    if (_selected.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('حذف التحميلات المحددة'),
        content:
            AppText('سيتم حذف ${_selected.length} عنصر/عناصر. هل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const AppText('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const AppText('حذف', color: Colors.red),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final cubit = DownloadCubit.get(context);
    for (final key in _selected) {
      final parts = key.split('_');
      if (parts.length == 2) {
        cubit.deleteBatch(parts[0], parts[1]);
      }
    }
    setState(_selected.clear);
  }

  String _batchKey(DownloadBatch b) => '${b.reciterId}_${b.moshafId}';

  void _pauseBatch(BuildContext context, DownloadBatch batch) {
    DownloadCubit.get(context).cancelBatch(batch.reciterId, batch.moshafId);
  }

  void _resumeBatch(BuildContext context, DownloadBatch batch) {
    final recitersCubit = RecitersCubit.get(context);
    final model = recitersCubit.recitersModel;
    if (model == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تعذر استئناف التحميل: معلومات المقرئ غير متاحة')),
      );
      return;
    }

    Reciter? reciter;
    Moshaf? moshaf;

    for (final r in model.reciters) {
      if (r.id.toString() == batch.reciterId) {
        reciter = r;
        moshaf = r.moshaf.firstWhere(
          (m) => m.id.toString() == batch.moshafId,
          orElse: () => r.moshaf.isNotEmpty
              ? r.moshaf.first
              : Moshaf(
                  id: int.tryParse(batch.moshafId) ?? 0,
                  name: batch.moshafName,
                  server: '',
                  surahTotal: 0,
                  moshafType: 0,
                  surahList: '',
                ),
        );
        break;
      }
    }

    if (reciter != null && moshaf != null && moshaf.server.isNotEmpty) {
      DownloadCubit.get(context).resumeBatch(reciter: reciter, moshaf: moshaf);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تعذر استئناف التحميل: معلومات المقرئ غير متاحة')),
      );
    }
  }

  Future<void> _showDownloadedSurahsPicker(
    BuildContext context,
    DownloadBatch batch,
  ) async {
    // Gather completed surahs from this batch
    final completed = batch.progressList
        .where((p) => p.status == DownloadStatus.completed)
        .map((p) => p.surahNumber)
        .toList()
      ..sort();

    if (completed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد سور مكتملة لهذا التحميل')),
      );
      return;
    }

    // Resolve reciter and moshaf
    final recitersCubit = RecitersCubit.get(context);
    final model = recitersCubit.recitersModel;
    if (model == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('لا يمكن التشغيل: معلومات المقرئين غير متاحة')),
      );
      return;
    }

    Reciter? reciter;
    Moshaf? moshaf;
    try {
      reciter =
          model.reciters.firstWhere((r) => r.id.toString() == batch.reciterId);
      moshaf =
          reciter.moshaf.firstWhere((m) => m.id.toString() == batch.moshafId);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('لا يمكن التشغيل: التحقق من المقرئ/المصحف')),
      );
      return;
    }

    if (moshaf.server.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن التشغيل بدون مسار تنزيل صالح')),
      );
      return;
    }

    final key = _batchKey(batch);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        int? selectedSurah;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.library_music, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                'اختر سورة للتشغيل — ${batch.reciterName} • ${batch.moshafName}',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (selectedSurah != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: AppText(
                                    'يشغل الآن: ${_getSurahName(selectedSurah!)}',
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'إغلاق',
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                        if (selectedSurah != null)
                          TextButton.icon(
                            onPressed: () {
                              setState(() => _currentlyPlayingKey = null);
                              setModalState(() => selectedSurah = null);
                              AudioPlayerService().stop();
                            },
                            icon: const Icon(Icons.stop, size: 18),
                            label: const Text('إيقاف'),
                          ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: completed.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final surah = completed[i];
                        final isSelected = selectedSurah == surah;
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                AppColors.primaryColor.withOpacity(0.1),
                            child: Icon(
                              isSelected ? Icons.graphic_eq : Icons.play_arrow,
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.black54,
                            ),
                          ),
                          title: AppText(
                            _getSurahName(surah),
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          trailing: isSelected
                              ? Icon(Icons.equalizer,
                                  color: AppColors.primaryColor)
                              : null,
                          onTap: () async {
                            setState(() => _currentlyPlayingKey = key);
                            await AudioPlayerService().playRecitation(
                              reciter: reciter!,
                              moshaf: moshaf!,
                              surahNumber: surah,
                            );
                            setModalState(() => selectedSurah = surah);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getSurahName(int surahNumber) {
    final surahs = {
      1: 'الفاتحة',
      2: 'البقرة',
      3: 'آل عمران',
      4: 'النساء',
      5: 'المائدة',
      6: 'الأنعام',
      7: 'الأعراف',
      8: 'الأنفال',
      9: 'التوبة',
      10: 'يونس',
      11: 'هود',
      12: 'يوسف',
      13: 'الرعد',
      14: 'إبراهيم',
      15: 'الحجر',
      16: 'النحل',
      17: 'الإسراء',
      18: 'الكهف',
      19: 'مريم',
      20: 'طه',
      21: 'الأنبياء',
      22: 'الحج',
      23: 'المؤمنون',
      24: 'النور',
      25: 'الفرقان',
      26: 'الشعراء',
      27: 'النمل',
      28: 'القصص',
      29: 'العنكبوت',
      30: 'الروم',
      31: 'لقمان',
      32: 'السجدة',
      33: 'الأحزاب',
      34: 'سبأ',
      35: 'فاطر',
      36: 'يس',
      37: 'الصافات',
      38: 'ص',
      39: 'الزمر',
      40: 'غافر',
      41: 'فصلت',
      42: 'الشورى',
      43: 'الزخرف',
      44: 'الدخان',
      45: 'الجاثية',
      46: 'الأحقاف',
      47: 'محمد',
      48: 'الفتح',
      49: 'الحجرات',
      50: 'ق',
      51: 'الذاريات',
      52: 'الطور',
      53: 'النجم',
      54: 'القمر',
      55: 'الرحمن',
      56: 'الواقعة',
      57: 'الحديد',
      58: 'المجادلة',
      59: 'الحشر',
      60: 'الممتحنة',
      61: 'الصف',
      62: 'الجمعة',
      63: 'المنافقون',
      64: 'التغابن',
      65: 'الطلاق',
      66: 'التحريم',
      67: 'الملك',
      68: 'القلم',
      69: 'الحاقة',
      70: 'المعارج',
      71: 'نوح',
      72: 'الجن',
      73: 'المزمل',
      74: 'المدثر',
      75: 'القيامة',
      76: 'الإنسان',
      77: 'المرسلات',
      78: 'النبأ',
      79: 'النازعات',
      80: 'عبس',
      81: 'التكوير',
      82: 'الانفطار',
      83: 'المطففين',
      84: 'الانشقاق',
      85: 'البروج',
      86: 'الطارق',
      87: 'الأعلى',
      88: 'الغاشية',
      89: 'الفجر',
      90: 'البلد',
      91: 'الشمس',
      92: 'الليل',
      93: 'الضحى',
      94: 'الشرح',
      95: 'التين',
      96: 'العلق',
      97: 'القدر',
      98: 'البينة',
      99: 'الزلزلة',
      100: 'العاديات',
      101: 'القارعة',
      102: 'التكاثر',
      103: 'العصر',
      104: 'الهمزة',
      105: 'الفيل',
      106: 'قريش',
      107: 'الماعون',
      108: 'الكوثر',
      109: 'الكافرون',
      110: 'النصر',
      111: 'المسد',
      112: 'الإخلاص',
      113: 'الفلق',
      114: 'الناس',
    };
    return surahs[surahNumber] ?? 'سورة $surahNumber';
  }
}
