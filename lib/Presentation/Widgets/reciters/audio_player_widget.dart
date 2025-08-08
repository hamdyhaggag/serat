import 'package:flutter/material.dart';
import 'package:serat/Business_Logic/Models/reciter_model.dart';
import 'package:serat/Data/services/audio_player_service.dart';
import 'package:serat/imports.dart';

class AudioPlayerWidget extends StatefulWidget {
  final Reciter reciter;
  final Moshaf moshaf;
  final int selectedSurah;
  final AudioPlayerService audioPlayerService;

  const AudioPlayerWidget({
    super.key,
    required this.reciter,
    required this.moshaf,
    required this.selectedSurah,
    required this.audioPlayerService,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool _autoPlayNextSura = false;

  @override
  void initState() {
    super.initState();
    widget.audioPlayerService.setAutoPlayNextSura(_autoPlayNextSura);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xff2F2F2F)
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlayerHeader(),
          const SizedBox(height: 24),
          _buildPlayerControls(),
          const SizedBox(height: 24),
          _buildProgressBar(),
          const SizedBox(height: 16),
          _buildAutoPlayToggle(),
        ],
      ),
    );
  }

  Widget _buildPlayerHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(0, 150, 136, 0.1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 150, 136, 0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: AppText(
              widget.reciter.letter,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                widget.reciter.name,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 4),
              AppText(
                '${widget.moshaf.name} - ${_getSurahName(widget.selectedSurah)}',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildPlayerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.replay_10,
          onPressed: () => widget.audioPlayerService.seekBackward(
            const Duration(seconds: 10),
          ),
        ),
        const SizedBox(width: 16),
        _buildPlayPauseButton(),
        const SizedBox(width: 16),
        _buildControlButton(
          icon: Icons.forward_10,
          onPressed: () => widget.audioPlayerService.seekForward(
            const Duration(seconds: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton() {
    return StreamBuilder<PlaybackState>(
      stream: widget.audioPlayerService.playbackStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? PlaybackState.stopped;
        final isPlaying = state == PlaybackState.playing;

        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 150, 136, 0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () {
              if (isPlaying) {
                widget.audioPlayerService.pause();
              } else {
                widget.audioPlayerService.resume();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return StreamBuilder<Duration>(
      stream: widget.audioPlayerService.positionStream,
      builder: (context, positionSnapshot) {
        final position = positionSnapshot.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: widget.audioPlayerService.durationStream,
          builder: (context, durationSnapshot) {
            final duration = durationSnapshot.data ?? Duration.zero;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (duration.inSeconds > 0) ...[
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: AppColors.primaryColor,
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: AppColors.primaryColor,
                      overlayColor: const Color.fromRGBO(0, 150, 136, 0.2),
                    ),
                    child: Slider(
                      value: position.inSeconds.toDouble().clamp(
                            0.0,
                            duration.inSeconds.toDouble(),
                          ),
                      max: duration.inSeconds.toDouble(),
                      onChanged: (value) => widget.audioPlayerService.seekTo(
                        Duration(seconds: value.toInt()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  StreamBuilder<PlaybackState>(
                    stream: widget.audioPlayerService.playbackStateStream,
                    builder: (context, stateSnapshot) {
                      final state = stateSnapshot.data;
                      if (state == PlaybackState.loading) {
                        return Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            AppText(
                              'جاري تحميل التلاوة...',
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAutoPlayToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.queue_music, color: Colors.teal),
            const SizedBox(width: 8),
            const AppText(
              'تشغيل السورة التالية تلقائياً',
              fontSize: 16,
            ),
          ],
        ),
        Switch(
          value: _autoPlayNextSura,
          onChanged: (value) {
            setState(() {
              _autoPlayNextSura = value;
            });
            widget.audioPlayerService.setAutoPlayNextSura(value);
          },
          activeColor: AppColors.primaryColor,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(0, 150, 136, 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primaryColor, size: 24),
        onPressed: onPressed,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
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
