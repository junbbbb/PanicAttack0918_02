import 'dart:async';

import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final List<String> _emotionEmojis = const ['😀', '🙂', '😐', '🙁', '😢'];
  final TextEditingController _entryController = TextEditingController();

  String? _selectedEmoji;
  String? _submittedEntry;
  bool? _panicAttackOccurred;

  bool _showEmojiPrompt = false;
  bool _showFollowupQuestion = false;
  bool _showJournalComposer = false;
  bool _showPanicQuestion = false;
  bool _showPanicOptions = false;
  bool _recordSaved = false;

  Timer? _emojiPromptTimer;
  Timer? _followupTimer;
  Timer? _composerTimer;
  Timer? _panicQuestionTimer;
  Timer? _panicOptionsTimer;

  @override
  void initState() {
    super.initState();
    _emojiPromptTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showEmojiPrompt = true;
      });
    });
  }

  void _handleEmojiTap(String emoji) {
    _followupTimer?.cancel();
    _composerTimer?.cancel();
    _panicQuestionTimer?.cancel();
    _panicOptionsTimer?.cancel();

    setState(() {
      _selectedEmoji = emoji;
      _submittedEntry = null;
      _panicAttackOccurred = null;
      _recordSaved = false;
      _showFollowupQuestion = false;
      _showJournalComposer = false;
      _showPanicQuestion = false;
      _showPanicOptions = false;
    });

    _entryController.clear();
    FocusScope.of(context).unfocus();
    debugPrint('오늘 기분 선택: $emoji');

    _followupTimer = Timer(const Duration(milliseconds: 520), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showFollowupQuestion = true;
      });

      _composerTimer = Timer(const Duration(milliseconds: 420), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _showJournalComposer = true;
        });
      });
    });
  }

  void _handleSubmitEntry() {
    final entry = _entryController.text.trim();
    if (entry.isEmpty) {
      return;
    }

    _panicQuestionTimer?.cancel();
    _panicOptionsTimer?.cancel();

    setState(() {
      _submittedEntry = entry;
      _panicAttackOccurred = null;
      _recordSaved = false;
      _showJournalComposer = false;
      _showPanicQuestion = false;
      _showPanicOptions = false;
    });
    debugPrint('오늘 있었던 일 기록: $entry');

    _entryController.clear();
    FocusScope.of(context).unfocus();

    _panicQuestionTimer = Timer(const Duration(milliseconds: 520), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showPanicQuestion = true;
      });

      _panicOptionsTimer = Timer(const Duration(milliseconds: 380), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _showPanicOptions = true;
        });
      });
    });
  }

  void _handlePanicResponse(bool hadAttack) {
    setState(() {
      _panicAttackOccurred = hadAttack;
      _showPanicOptions = false;
      _recordSaved = !hadAttack;
    });

    debugPrint('오늘 공황발작 있었어?: ${hadAttack ? '예' : '아니오'}');
  }

  @override
  void dispose() {
    _emojiPromptTimer?.cancel();
    _followupTimer?.cancel();
    _composerTimer?.cancel();
    _panicQuestionTimer?.cancel();
    _panicOptionsTimer?.cancel();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final hasSelectedEmoji = _selectedEmoji != null;
    final hasJournalEntry = _submittedEntry != null;
    final hasPanicResponse = _panicAttackOccurred != null;

    final chatItems = <Widget>[
      _ChatBubble(
        alignment: Alignment.centerLeft,
        backgroundColor: Colors.white.withOpacity(0.92),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Text(
          '오늘 기분은 어때?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF2E2822),
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    ];

    if (_showEmojiPrompt) {
      chatItems.addAll([
        const SizedBox(height: 16),
        _ChatBubble(
          alignment: Alignment.centerRight,
          backgroundColor: Colors.white.withOpacity(0.85),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          child: _EmojiSelector(
            emojis: _emotionEmojis,
            selectedEmoji: _selectedEmoji,
            onEmojiTap: _handleEmojiTap,
          ),
        ),
      ]);
    }

    if (hasSelectedEmoji) {
      chatItems.addAll([
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '선택한 기분: ${_selectedEmoji!}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ]);
    }

    if (_showFollowupQuestion) {
      chatItems.addAll([
        const SizedBox(height: 24),
        _ChatBubble(
          alignment: Alignment.centerLeft,
          backgroundColor: Colors.white.withOpacity(0.92),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: Text(
            '오늘은 어떤 일이 있었어?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF2E2822),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ]);
    }

    if (_showJournalComposer && !hasJournalEntry) {
      chatItems.addAll([
        const SizedBox(height: 16),
        _ChatBubble(
          alignment: Alignment.centerRight,
          backgroundColor: Colors.white.withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          child: _JournalComposer(
            controller: _entryController,
            charLimit: 700,
            onSubmit: _handleSubmitEntry,
          ),
        ),
      ]);
    }

    if (hasJournalEntry) {
      chatItems.addAll([
        const SizedBox(height: 16),
        _ChatBubble(
          alignment: Alignment.centerRight,
          backgroundColor: Colors.white.withOpacity(0.94),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          child: Text(
            _submittedEntry!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: const Color(0xFF2A2622),
                ),
          ),
        ),
      ]);
    }

    if (_showPanicQuestion) {
      chatItems.addAll([
        const SizedBox(height: 24),
        _ChatBubble(
          alignment: Alignment.centerLeft,
          backgroundColor: Colors.white.withOpacity(0.92),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: Text(
            '오늘 공황발작 있었어?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF2E2822),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ]);
    }

    if (_showPanicOptions && !hasPanicResponse) {
      chatItems.addAll([
        const SizedBox(height: 16),
        _ChatBubble(
          alignment: Alignment.centerRight,
          backgroundColor: Colors.white.withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          child: _BinaryChoiceSelector(
            positiveLabel: '예',
            negativeLabel: '아니오',
            onPositive: () => _handlePanicResponse(true),
            onNegative: () => _handlePanicResponse(false),
          ),
        ),
      ]);
    }

    if (hasPanicResponse) {
      chatItems.addAll([
        const SizedBox(height: 16),
        _ChatBubble(
          alignment: Alignment.centerRight,
          backgroundColor: Colors.white.withOpacity(0.94),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          child: Text(
            _panicAttackOccurred! ? '예였어.' : '아니오였어.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF2A2622),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ]);
    }

    if (_recordSaved) {
      chatItems.addAll([
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '기록을 저장했어요. 내일도 함께 이야기해요!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ]);
    } else if (_panicAttackOccurred == true) {
      chatItems.addAll([
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '곧 이어서 도와줄게. 조금만 기다려줘.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ]);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('기록'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1015), Color(0xFF121723), Color(0xFF171C2A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(bottom: 24),
                    children: chatItems,
                  ),
                ),
                _ChatFooter(
                  hasShownEmojiPrompt: _showEmojiPrompt,
                  hasSelectedEmoji: hasSelectedEmoji,
                  isFollowupVisible: _showFollowupQuestion,
                  isComposerVisible: _showJournalComposer,
                  hasJournalEntry: hasJournalEntry,
                  isPanicQuestionVisible: _showPanicQuestion,
                  isPanicOptionsVisible: _showPanicOptions,
                  hasPanicResponse: hasPanicResponse,
                  recordSaved: _recordSaved,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.child,
    required this.alignment,
    required this.backgroundColor,
    required this.borderRadius,
  });

  final Widget child;
  final Alignment alignment;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _EmojiSelector extends StatelessWidget {
  const _EmojiSelector({
    required this.emojis,
    required this.selectedEmoji,
    required this.onEmojiTap,
  });

  final List<String> emojis;
  final String? selectedEmoji;
  final ValueChanged<String> onEmojiTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '이모티콘을 탭해서 답변해 주세요',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final emoji in emojis)
              _EmojiOption(
                emoji: emoji,
                isSelected: emoji == selectedEmoji,
                onTap: () => onEmojiTap(emoji),
              ),
          ],
        ),
      ],
    );
  }
}

class _EmojiOption extends StatelessWidget {
  const _EmojiOption({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? highlightColor.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? highlightColor
                : theme.colorScheme.outline.withOpacity(0.5),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: highlightColor.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}

class _JournalComposer extends StatelessWidget {
  const _JournalComposer({
    required this.controller,
    required this.charLimit,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final int charLimit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final currentLength = value.text.characters.length;
        final isSubmitEnabled = value.text.trim().isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: 6,
              maxLength: charLimit,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: const InputDecoration(
                hintText: '오늘 있었던 일을 자유롭게 들려줘',
                border: InputBorder.none,
                counterText: '',
              ),
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$currentLength/$charLimit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: isSubmitEnabled ? onSubmit : null,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('보내기'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _BinaryChoiceSelector extends StatelessWidget {
  const _BinaryChoiceSelector({
    required this.positiveLabel,
    required this.negativeLabel,
    required this.onPositive,
    required this.onNegative,
  });

  final String positiveLabel;
  final String negativeLabel;
  final VoidCallback onPositive;
  final VoidCallback onNegative;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlight = theme.colorScheme.primary;

    ButtonStyle baseStyle(Color background, Color border, Color foreground) {
      return OutlinedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '오늘을 돌아보며 선택해 줘',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onNegative,
                style: baseStyle(
                  Colors.white,
                  theme.colorScheme.outline.withOpacity(0.6),
                  const Color(0xFF2A2622),
                ),
                child: Text(negativeLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onPositive,
                style: baseStyle(
                  highlight.withOpacity(0.12),
                  highlight,
                  highlight,
                ),
                child: Text(positiveLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChatFooter extends StatelessWidget {
  const _ChatFooter({
    required this.hasShownEmojiPrompt,
    required this.hasSelectedEmoji,
    required this.isFollowupVisible,
    required this.isComposerVisible,
    required this.hasJournalEntry,
    required this.isPanicQuestionVisible,
    required this.isPanicOptionsVisible,
    required this.hasPanicResponse,
    required this.recordSaved,
  });

  final bool hasShownEmojiPrompt;
  final bool hasSelectedEmoji;
  final bool isFollowupVisible;
  final bool isComposerVisible;
  final bool hasJournalEntry;
  final bool isPanicQuestionVisible;
  final bool isPanicOptionsVisible;
  final bool hasPanicResponse;
  final bool recordSaved;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.white.withOpacity(0.9);

    String subtitle;
    if (!hasShownEmojiPrompt) {
      subtitle = '기록 챗봇이 질문을 준비하고 있어요';
    } else if (!hasSelectedEmoji) {
      subtitle = '이모티콘을 탭해서 첫 번째 질문에 답해주세요';
    } else if (!isFollowupVisible) {
      subtitle = '답변을 확인하고 있어요...';
    } else if (!hasJournalEntry) {
      subtitle =
          isComposerVisible ? '두 번째 질문에 답변을 작성해 주세요' : '곧 두 번째 질문에 답할 수 있어요';
    } else if (!isPanicQuestionVisible) {
      subtitle = '답변을 정리하는 중이에요...';
    } else if (!hasPanicResponse) {
      subtitle = isPanicOptionsVisible ? '오늘 공황 상태를 알려주세요' : '질문을 전달하고 있어요...';
    } else {
      subtitle = recordSaved ? '답변을 저장했어요. 오늘도 수고했어요!' : '추가 질문을 준비하고 있어요';
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded,
                color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '기록 챗봇',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E2822),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF5C534B),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
