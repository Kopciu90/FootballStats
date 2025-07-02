import 'package:flutter/material.dart';

class LoadingBall extends StatefulWidget {
  const LoadingBall({super.key});

  @override
  State<LoadingBall> createState() => _LoadingBallState();
}

class _LoadingBallState extends State<LoadingBall>
    with SingleTickerProviderStateMixin {
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
    return RotationTransition(
      turns: _controller,
      child: Image.asset(
        'assets/ball.png',
        height: 60,
      ),
    );
  }
}