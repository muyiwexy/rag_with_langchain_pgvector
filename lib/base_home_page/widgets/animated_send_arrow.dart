import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedArrow extends StatefulWidget {
  const AnimatedArrow({super.key});

  @override
  _AnimatedArrowState createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _positionAnimation;
  int _cycleCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _cycleCount++;
          if (_cycleCount < 3) {
            _controller.reset();
            _positionAnimation =
                Tween<double>(begin: -50, end: 50).animate(_controller);
            _controller.forward();
          } else if (_cycleCount == 3) {
            _controller.reset();
            _controller.duration =
                const Duration(seconds: 2); // slow down the animation
            _positionAnimation =
                Tween<double>(begin: -50, end: 8).animate(_controller);
            _controller.forward();
          }
        }
      });
    _positionAnimation = Tween<double>(begin: 0, end: 50).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: _positionAnimation.value,
      child: SvgPicture.asset(
        "assets/send_icon.svg",
        height: 35,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}
