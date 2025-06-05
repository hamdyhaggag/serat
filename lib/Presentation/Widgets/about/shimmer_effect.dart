import 'package:flutter/material.dart';

class ShimmerEffect extends StatefulWidget {
  final bool isDarkMode;

  const ShimmerEffect({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.isDarkMode
                    ? const Color.fromRGBO(255, 255, 255, 0.0)
                    : const Color.fromRGBO(0, 0, 0, 0.0),
                widget.isDarkMode
                    ? const Color.fromRGBO(255, 255, 255, 0.05)
                    : const Color.fromRGBO(0, 0, 0, 0.05),
                widget.isDarkMode
                    ? const Color.fromRGBO(255, 255, 255, 0.0)
                    : const Color.fromRGBO(0, 0, 0, 0.0),
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: Container(
            color: Colors.transparent,
          ),
        );
      },
    );
  }
}
