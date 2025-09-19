
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DoorOpen extends StatelessWidget {
  final bool open;
  final double height;
  const DoorOpen({super.key, required this.open, this.height = 160});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: 400.ms, curve: Curves.easeInOut,
            width: open ? 0 : 140, height: height,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors:[Color(0xFF0EA5E9), Color(0xFF7C3AED)]),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Positioned(
            left: 0,
            child: AnimatedContainer(
              duration: 400.ms, curve: Curves.easeInOut,
              width: open ? 0 : 70, height: height,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: AnimatedContainer(
              duration: 400.ms, curve: Curves.easeInOut,
              width: open ? 0 : 70, height: height,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
