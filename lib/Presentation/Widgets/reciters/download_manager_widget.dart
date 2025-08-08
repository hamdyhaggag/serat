import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/download_cubit.dart';
import 'package:serat/Business_Logic/Models/download_model.dart';
import 'package:serat/imports.dart';

class DownloadManagerWidget extends StatelessWidget {
  const DownloadManagerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<DownloadCubit, DownloadState>(
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.download, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const AppText(
            'مدير التحميلات',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, DownloadStorageInfoLoaded state) {
    return Column(
      children: [
        _buildStorageInfo(state.storageInfo),
        const Divider(),
        Expanded(
          child: state.batches.isEmpty
              ? _buildEmptyState()
              : _buildBatchesList(context, state.batches),
        ),
      ],
    );
  }

  Widget _buildStorageInfo(Map<String, dynamic> storageInfo) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
           Icon(Icons.storage, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'المساحة المستخدمة',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                AppText(
                  '${storageInfo['totalSizeMB']} ميجابايت',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          AppText(
            '${storageInfo['totalFiles']} ملف',
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'لا توجد تحميلات',
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: batches.length,
      itemBuilder: (context, index) {
        final batch = batches[index];
        return _buildBatchCard(context, batch);
      },
    );
  }

  Widget _buildBatchCard(BuildContext context, DownloadBatch batch) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        batch.reciterName,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      AppText(
                        batch.moshafName,
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(batch.overallStatus),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: batch.overallProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      batch.overallStatus == DownloadStatus.completed
                          ? Colors.green
                          : AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AppText(
                  '${batch.completedCount}/${batch.totalCount}',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                    if (batch.overallStatus == DownloadStatus.downloading)
                      IconButton(
                        icon: const Icon(Icons.pause, size: 20),
                        onPressed: () => _pauseBatch(context, batch),
                      ),
                    if (batch.overallStatus == DownloadStatus.paused)
                      IconButton(
                        icon: const Icon(Icons.play_arrow, size: 20),
                        onPressed: () => _resumeBatch(context, batch),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _deleteBatch(context, batch),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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

  void _pauseBatch(BuildContext context, DownloadBatch batch) {
    DownloadCubit.get(context).cancelBatch(batch.reciterId, batch.moshafId);
  }

  void _resumeBatch(BuildContext context, DownloadBatch batch) {
    // Implementation for resuming batch downloads
  }

  void _deleteBatch(BuildContext context, DownloadBatch batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('حذف التحميلات'),
        content: AppText(
          'هل أنت متأكد من حذف جميع تحميلات ${batch.reciterName} - ${batch.moshafName}؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              DownloadCubit.get(context)
                  .deleteBatch(batch.reciterId, batch.moshafId);
              Navigator.pop(context);
            },
            child: const AppText('حذف', color: Colors.red),
          ),
        ],
      ),
    );
  }
}
