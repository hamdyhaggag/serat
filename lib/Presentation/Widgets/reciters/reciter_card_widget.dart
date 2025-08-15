import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/download_cubit.dart';
import 'package:serat/Business_Logic/Models/reciter_model.dart';
import 'package:serat/Business_Logic/Models/download_model.dart';
import 'package:serat/imports.dart';

class ReciterCardWidget extends StatelessWidget {
  final Reciter reciter;
  final bool isDarkMode;
  final VoidCallback onTap;
  final void Function(Moshaf moshaf)? onDownloadMoshaf;

  const ReciterCardWidget({
    super.key,
    required this.reciter,
    required this.isDarkMode,
    required this.onTap,
    this.onDownloadMoshaf,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDarkMode ? const Color(0xff2F2F2F) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (reciter.moshaf.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                ...reciter.moshaf.map((moshaf) => _buildMoshafItem(moshaf)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                reciter.name,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.primaryColor,
              ),
              if (reciter.moshaf.isNotEmpty) ...[
                const SizedBox(height: 6),
                AppText(
                  'عدد المصاحف: ${reciter.moshaf.length}',
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ],
          ),
        ),
        _buildDownloadStatus(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[800]
            : AppColors.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: AppText(
          reciter.letter,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildDownloadStatus() {
    return BlocBuilder<DownloadCubit, DownloadState>(
      builder: (context, state) {
        int totalDownloaded = 0;
        int totalSurahs = 0;

        for (final moshaf in reciter.moshaf) {
          final batch = DownloadCubit.get(context).getBatch(
            reciter.id.toString(),
            moshaf.id.toString(),
          );
          if (batch != null) {
            totalDownloaded += batch.completedCount;
            totalSurahs += batch.totalCount;
          }
        }

        if (totalSurahs == 0) {
          return const SizedBox.shrink();
        }

        final progress = totalDownloaded / totalSurahs;

        return Column(
          children: [
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            AppText(
              '$totalDownloaded/$totalSurahs',
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoshafItem(Moshaf moshaf) {
    return BlocBuilder<DownloadCubit, DownloadState>(
      builder: (context, state) {
        final batch = DownloadCubit.get(context).getBatch(
          reciter.id.toString(),
          moshaf.id.toString(),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey[800]
                      : AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.book,
                  size: 18,
                  color: isDarkMode ? Colors.grey[400] : AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      moshaf.name,
                      fontSize: 15,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                    if (batch != null) ...[
                      const SizedBox(height: 4),
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
                          const SizedBox(width: 8),
                          AppText(
                            '${batch.completedCount}/${batch.totalCount}',
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (onDownloadMoshaf != null)
                IconButton(
                  tooltip: 'تنزيل',
                  icon: Icon(
                    batch?.overallStatus == DownloadStatus.completed
                        ? Icons.download_done
                        : Icons.download_for_offline,
                    color: batch?.overallStatus == DownloadStatus.completed
                        ? Colors.green
                        : (isDarkMode ? Colors.white : AppColors.primaryColor),
                    size: 20,
                  ),
                  onPressed: () => onDownloadMoshaf!(moshaf),
                ),
              if (batch != null) _buildStatusIcon(batch.overallStatus),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(DownloadStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case DownloadStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case DownloadStatus.downloading:
        icon = Icons.downloading;
        color = AppColors.primaryColor;
        break;
      case DownloadStatus.paused:
        icon = Icons.pause_circle;
        color = Colors.orange;
        break;
      case DownloadStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      default:
        icon = Icons.download;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 20);
  }
}
