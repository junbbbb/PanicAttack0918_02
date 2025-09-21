import 'dart:async';

import 'package:flutter/material.dart';

class BreathingPage extends StatelessWidget {
  const BreathingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('호흡법'),
        centerTitle: false,
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: const [
          _GradientBackground(),
          _HillBackground(),
          _ForegroundDecoration(),
          _BreathingTimerPanel(),
        ],
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE9F4FF),
            Color(0xFFB1D8FA),
            Color(0xFFB1D8FA),
          ],
        ),
      ),
    );
  }
}

class _HillBackground extends StatelessWidget {
  const _HillBackground();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _HillPainter(),
      ),
    );
  }
}

class _HillPainter extends CustomPainter {
  const _HillPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final hillPaint = Paint()
      ..color = const Color(0xFFEBE2DA)
      ..style = PaintingStyle.fill;

    final baseY = size.height * 0.46;
    final hillPath = Path()
      ..moveTo(0, baseY)
      ..quadraticBezierTo(
        size.width * 0.5,
        baseY - size.height * 0.09,
        size.width,
        baseY,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(hillPath, hillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ForegroundDecoration extends StatelessWidget {
  const _ForegroundDecoration();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;

    // Align the midline of the image with the hill ridge by offsetting upward.
    final offset = height * 0.18;

    return Positioned(
      top: offset,
      left: 0,
      right: 0,
      child: Image.asset(
        'assets/images/backgrounds/breath_bg.png',
        width: width,
        fit: BoxFit.fitWidth,
        alignment: const Alignment(0, -0.2),
      ),
    );
  }
}

class _BreathingTimerPanel extends StatefulWidget {
  const _BreathingTimerPanel();

  @override
  State<_BreathingTimerPanel> createState() => _BreathingTimerPanelState();
}

class _BreathingTimerPanelState extends State<_BreathingTimerPanel> {
  static const List<_BreathingPhase> _phases = [
    _BreathingPhase(label: '숨을 들이마시세요', seconds: 4),
    _BreathingPhase(label: '숨을 멈추세요', seconds: 7),
    _BreathingPhase(label: '숨을 내쉬세요', seconds: 8),
  ];

  Timer? _timer;
  int _phaseIndex = 0;
  int _remaining = _phases.first.seconds;
  int _cycleCount = 1;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _pause() {
    if (!_isRunning) return;
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _phaseIndex = 0;
      _remaining = _phases.first.seconds;
      _cycleCount = 1;
    });
  }

  void _tick() {
    setState(() {
      if (_remaining > 1) {
        _remaining--;
        return;
      }

      if (_phaseIndex < _phases.length - 1) {
        _phaseIndex++;
      } else {
        _phaseIndex = 0;
        _cycleCount++;
      }
      _remaining = _phases[_phaseIndex].seconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final phase = _phases[_phaseIndex];
    final theme = Theme.of(context);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '4-7-8 호흡법 · $_cycleCount번째 사이클',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF39322C),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  phase.label,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF39322C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_remaining.toString().padLeft(2, '0')} 초 남음',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF727883),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isRunning ? _pause : _start,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF39322C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(_isRunning ? '일시정지' : '시작'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF39322C),
                        side: const BorderSide(color: Color(0xFF39322C)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('재설정'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BreathingPhase {
  const _BreathingPhase({required this.label, required this.seconds});

  final String label;
  final int seconds;
}
