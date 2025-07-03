import 'dart:async';

import 'package:flutter/material.dart';

class BlinkIconWidget extends StatefulWidget {
  final String onIconPath;
  final String offIconPath;
  final Duration blinkDuration;
  final double size;
  final bool isBlinking;
  final VoidCallback? onTap;

  const BlinkIconWidget({
    super.key,
    required this.onIconPath,
    required this.offIconPath,
    this.blinkDuration = const Duration(milliseconds: 2000),
    this.size = 64.0,
    required this.isBlinking,
    required this.onTap,
  });

  @override
  State<BlinkIconWidget> createState() => _BlinkIconWidgetState();
}

class _BlinkIconWidgetState extends State<BlinkIconWidget> {
  bool _isOn = true;
  Timer? _blinkTimer;

  @override
  void didUpdateWidget(covariant BlinkIconWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isBlinking != widget.isBlinking) {
      widget.isBlinking ? _startBlinking() : _stopBlinking();
    }
  }

  void _startBlinking() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(widget.blinkDuration, (_) {
      if (mounted) {
        setState(() {
          _isOn = !_isOn;
        });
      }
    });
  }

  void _stopBlinking() {
    _blinkTimer?.cancel();
    setState(() => _isOn = true); // default to ON icon when stopped
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Image.asset(
          _isOn ? widget.onIconPath : widget.offIconPath,
          key: ValueKey<bool>(_isOn),
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }
}
