import 'package:flutter/material.dart';
import 'package:serat/imports.dart';
import 'package:serat/features/radio/domain/radio_model.dart';

class RadioPlayerSheet extends StatelessWidget {
  final RadioStation station;
  final bool isPlaying;
  final double volume;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final Function(double) onVolumeChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onClose;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;

  const RadioPlayerSheet({
    super.key,
    required this.station,
    required this.isPlaying,
    required this.volume,
    required this.onPlayPause,
    required this.onStop,
    required this.onVolumeChanged,
    required this.onNext,
    required this.onPrevious,
    required this.onClose,
    required this.isBookmarked,
    required this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? const Color(0xff4CAF93) : AppColors.primaryColor;
    final backgroundColor = isDarkMode ? const Color(0xff121212) : Colors.white;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          // Header Indicator
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Top Section with Rounded Background (Icon area)
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xff1A2B25)
                  : primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Radio Animated Effect if playing
                if (isPlaying)
                  _AnimatedRipple(color: primaryColor),
                
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: isDarkMode ? 0.05 : 0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.radio_rounded,
                    size: 80,
                    color: primaryColor,
                  ),
                ),
                
                // Close Button
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    onPressed: onClose,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, size: 32, color: isDarkMode ? Colors.white : Colors.black87),
                  ),
                ),
                
                // Bookmark Button
                Positioned(
                  top: 20,
                  left: 20,
                  child: IconButton(
                    onPressed: onToggleBookmark,
                    icon: Icon(
                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                      size: 28,
                      color: isBookmarked ? primaryColor : (isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Station Info
                  AppText(
                    station.name,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    'بث مباشر',
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  
                  const Spacer(),

                  // Volume Slider (Matching the theme)
                  Row(
                    children: [
                      Icon(Icons.volume_mute_rounded, color: Colors.grey[400], size: 20),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: primaryColor,
                            inactiveTrackColor: primaryColor.withValues(alpha: 0.1),
                            thumbColor: primaryColor,
                            overlayColor: primaryColor.withValues(alpha: 0.1),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: volume,
                            onChanged: onVolumeChanged,
                          ),
                        ),
                      ),
                      Icon(Icons.volume_up_rounded, color: Colors.grey[400], size: 20),
                    ],
                  ),
                  
                  const SizedBox(height: 40),

                  // Main Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous Station
                      _ControlCircleButton(
                        icon: Icons.skip_previous_rounded,
                        onPressed: onPrevious,
                        size: 50,
                        iconSize: 30,
                        color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                        iconColor: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      const SizedBox(width: 30),
                      
                      // Play/Pause
                      GestureDetector(
                        onTap: onPlayPause,
                        child: Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 30),
                      
                      // Next Station
                      _ControlCircleButton(
                        icon: Icons.skip_next_rounded,
                        onPressed: onNext,
                        size: 50,
                        iconSize: 30,
                        color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                        iconColor: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Stop Button
                  TextButton.icon(
                    onPressed: onStop,
                    icon: const Icon(Icons.stop_circle_rounded, color: Colors.red),
                    label: const AppText('إيقاف البث', color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final Color color;
  final Color iconColor;

  const _ControlCircleButton({
    required this.icon,
    required this.onPressed,
    required this.size,
    required this.iconSize,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}

class _AnimatedRipple extends StatefulWidget {
  final Color color;
  const _AnimatedRipple({required this.color});

  @override
  State<_AnimatedRipple> createState() => _AnimatedRippleState();
}

class _AnimatedRippleState extends State<_AnimatedRipple> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildCircle(1.0 + _controller.value * 0.5, 1.0 - _controller.value),
            _buildCircle(1.5 + _controller.value * 0.5, 0.5 - _controller.value * 0.5),
          ],
        );
      },
    );
  }

  Widget _buildCircle(double scale, double opacity) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withValues(alpha: opacity.clamp(0.0, 1.0)),
            width: 2,
          ),
        ),
      ),
    );
  }
}
