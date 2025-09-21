import 'dart:math' as math;

import 'package:flutter/material.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  static const _backgroundAsset =
      'assets/images/backgrounds/firefly_20250920215741_1_1x.webp';
  static const _characterAsset = 'assets/images/characters/bare.png';

  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }

    // TODO: wire up message submission when backend is ready.
    debugPrint('기록 입력: $message');
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('기록'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _backgroundAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          const _RecordCharacterOverlay(
            characterAsset: _characterAsset,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _messageController,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '오늘 일을 기록해요',
                          ),
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _handleSend,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text('보내기'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordCharacterOverlay extends StatelessWidget {
  const _RecordCharacterOverlay({required this.characterAsset});

  final String characterAsset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final targetSize = (availableWidth * 0.32).clamp(150.0, 260.0);
        final bubbleWidth = targetSize + 36;

        return Align(
          alignment: const Alignment(0, 0.18),
          child: SizedBox(
            width: bubbleWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SpeechBubble(width: bubbleWidth),
                SizedBox(height: targetSize * 0.12),
                SizedBox(
                  width: targetSize,
                  height: targetSize,
                  child: Image.asset(
                    characterAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = Colors.white.withOpacity(0.92);
    final borderColor = Colors.black.withOpacity(0.12);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            '오늘 있었던 일을 기록해볼까요?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF39322C),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(height: 4),
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: bubbleColor,
              border: Border(
                right: BorderSide(color: borderColor),
                bottom: BorderSide(color: borderColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
