import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:serat/Business_Logic/Models/reciter_model.dart';
import 'package:serat/imports.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/download_cubit.dart';
import 'package:serat/Business_Logic/Models/download_model.dart';
import 'dart:io';

class QuranAudioPlayerWidget extends StatelessWidget {
  final Reciter reciter;
  final Moshaf moshaf;
  final int surahNumber;
  final String surahName;
  final bool autoPlayNext;
  final ValueChanged<bool> onAutoPlayChanged;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSeekForward;
  final VoidCallback onSeekBackward;
  final Function(int) onSeek;
  final ValueNotifier<Duration> positionNotifier;
  final ValueNotifier<Duration> durationNotifier;
  final ValueNotifier<PlayerState> playerStateNotifier;
  final VoidCallback onDownload;
  final VoidCallback? onDelete;
  final VoidCallback onClose;

  const QuranAudioPlayerWidget({
    super.key,
    required this.reciter,
    required this.moshaf,
    required this.surahNumber,
    required this.surahName,
    required this.autoPlayNext,
    required this.onAutoPlayChanged,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onSeekForward,
    required this.onSeekBackward,
    required this.onSeek,
    required this.positionNotifier,
    required this.durationNotifier,
    required this.playerStateNotifier,
    required this.onDownload,
    required this.onClose,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? const Color(0xff4CAF93) : const Color(0xff137058);
    final backgroundColor = isDarkMode ? const Color(0xff121212) : Colors.white;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          // Top Section with Rounded Background
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xff1A2B25)
                  : const Color(0xffF0F7F4),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(200)),
            ),
            child: Stack(
              children: [
                // Quran Illustration
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Builder(
                        builder: (context) {
                          final file = File(
                              'C:/Users/MF/.gemini/antigravity/brain/e495ed93-08c0-42d4-8f31-980e102884e7/quran_rehal_illustration_1779386089671.png');
                          if (file.existsSync()) {
                            return Image.file(
                              file,
                              height: 160,
                              fit: BoxFit.contain,
                            );
                          }
                          return Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 100,
                              color: primaryColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Surah Info
                  AppText(
                    surahName,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    'سورة $surahNumber',
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontFamily: 'Cairo',
                  ),
                  AppText(
                    reciter.name,
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo',
                  ),
                  const SizedBox(height: 40),

                  // Waveform Progress Bar
                  ValueListenableBuilder<Duration>(
                    valueListenable: positionNotifier,
                    builder: (context, position, _) {
                      return ValueListenableBuilder<Duration>(
                        valueListenable: durationNotifier,
                        builder: (context, duration, _) {
                          final durationInSec = duration.inSeconds;
                          final positionInSec = position.inSeconds;
                          final progress = durationInSec > 0
                              ? positionInSec / durationInSec
                              : 0.0;

                          return Column(
                            children: [
                              WaveformWidget(
                                progress: progress,
                                color: primaryColor,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AppText(
                                    _formatDuration(position),
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  AppText(
                                    _formatDuration(duration),
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                              // Invisible Slider on top of waveform for seeking
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 0,
                                  thumbShape: SliderComponentShape.noThumb,
                                  overlayShape: SliderComponentShape.noOverlay,
                                  activeTrackColor: Colors.transparent,
                                  inactiveTrackColor: Colors.transparent,
                                ),
                                child: Slider(
                                  value: positionInSec
                                      .toDouble()
                                      .clamp(0, durationInSec.toDouble()),
                                  max: durationInSec.toDouble() > 0
                                      ? durationInSec.toDouble()
                                      : 1.0,
                                  onChanged: (val) => onSeek(val.toInt()),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Main Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BlocBuilder<DownloadCubit, DownloadState>(
                        builder: (context, state) {
                          bool isDownloading = false;
                          bool isCompleted = false;
                          double progressValue = 0;

                          if (state is DownloadProgressUpdated) {
                            final progress = state.progress;
                            if (progress.surahNumber == surahNumber &&
                                progress.reciterId == reciter.id.toString()) {
                              if (progress.status ==
                                  DownloadStatus.downloading) {
                                isDownloading = true;
                                progressValue = progress.progress;
                              } else if (progress.status ==
                                  DownloadStatus.completed) {
                                isCompleted = true;
                              }
                            }
                          } else {
                            // Check if already downloaded from cubit service
                            isCompleted =
                                context.read<DownloadCubit>().isSurahDownloaded(
                                      reciter.id.toString(),
                                      moshaf.id.toString(),
                                      surahNumber,
                                    );
                          }

                          if (isCompleted) {
                            return _ControlIconButton(
                              icon: Icons.check_circle_rounded,
                              onPressed: () {}, // Already downloaded
                              color: Colors.green,
                            );
                          }

                          if (isDownloading) {
                            return SizedBox(
                              width: 45,
                              height: 45,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: progressValue,
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        primaryColor),
                                  ),
                                  Icon(Icons.cloud_download_rounded,
                                      color: primaryColor, size: 20),
                                ],
                              ),
                            );
                          }

                          return _ControlIconButton(
                            icon: Icons.cloud_download_outlined,
                            onPressed: onDownload,
                            color: primaryColor,
                          );
                        },
                      ),
                      Row(
                        children: [
                          _ControlIconButton(
                            icon: Icons.skip_previous_rounded,
                            onPressed: onPrevious,
                            size: 36,
                          ),
                          const SizedBox(width: 20),
                          _PlayPauseButton(
                            onPressed: onPlayPause,
                            playerStateNotifier: playerStateNotifier,
                            primaryColor: primaryColor,
                          ),
                          const SizedBox(width: 20),
                          _ControlIconButton(
                            icon: Icons.skip_next_rounded,
                            onPressed: onNext,
                            size: 36,
                          ),
                        ],
                      ),
                      _ControlIconButton(
                        icon: Icons.shuffle_rounded,
                        onPressed: () {},
                        color: Colors.grey,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.queue_music_rounded,
                              color: Colors.grey, size: 20),
                          SizedBox(width: 8),
                          AppText(
                            'تشغيل تلقائي',
                            fontSize: 14,
                            fontFamily: 'Cairo',
                          ),
                        ],
                      ),
                      Switch(
                        value: autoPlayNext,
                        onChanged: onAutoPlayChanged,
                        activeColor: primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class _ControlIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color? color;

  const _ControlIconButton({
    required this.icon,
    required this.onPressed,
    this.size = 28,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color ?? Colors.black87, size: size),
      onPressed: onPressed,
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ValueNotifier<PlayerState> playerStateNotifier;
  final Color primaryColor;

  const _PlayPauseButton({
    required this.onPressed,
    required this.playerStateNotifier,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlayerState>(
      valueListenable: playerStateNotifier,
      builder: (context, state, _) {
        final isPlaying = state == PlayerState.playing;
        return Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 40,
            ),
            onPressed: onPressed,
          ),
        );
      },
    );
  }
}

class WaveformWidget extends StatelessWidget {
  final double progress;
  final Color color;

  const WaveformWidget({
    super.key,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(40, (index) {
          final barProgress = index / 40;
          final isHighlighted = barProgress <= progress;

          // Deterministic random height based on index
          final height = 10.0 +
              (math.sin(index * 0.5) * 15.0).abs() +
              (math.cos(index * 0.8) * 10.0).abs();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 4,
            height: height,
            decoration: BoxDecoration(
              color: isHighlighted ? color : color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
