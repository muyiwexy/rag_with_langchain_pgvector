import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedSvgWidget extends StatefulWidget {
  const AnimatedSvgWidget({Key? key}) : super(key: key);
  @override
  _AnimatedSvgWidgetState createState() => _AnimatedSvgWidgetState();
}

class _AnimatedSvgWidgetState extends State<AnimatedSvgWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
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
        return Transform.rotate(
          angle: _controller.value * 2 * 3.1415, // Rotate 360 degrees
          child: child,
        );
      },
      child: SvgPicture.asset(
        "assets/file_upload_icon.svg",
        height: 35,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}
