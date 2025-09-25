import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/record_history_controller.dart';
import '../domain/panic_record.dart';

class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({super.key});

  @override
  ConsumerState<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends ConsumerState<RecordPage> {
  final List<String> _emotionEmojis = const ['😀', '🙂', '😐', '🙁', '😢'];
  final TextEditingController _entryController = TextEditingController();
  final TextEditingController _panicContextController = TextEditingController();
  final TextEditingController _panicSymptomsController =
      TextEditingController();

  String? _selectedEmoji;
  String? _submittedEntry;
  bool? _panicAttackOccurred;

  bool _showEmojiPrompt = false;
  bool _showFollowupQuestion = false;
  bool _showJournalComposer = false;
  bool _showPanicQuestion = false;
  bool _showPanicOptions = false;
  bool _showPanicOccurrenceQuestion = false;
  bool _showPanicOccurrenceSelector = false;
  bool _showPanicContextQuestion = false;
  bool _showPanicContextSelector = false;
  bool _showPanicContextInput = false;
  bool _showPanicSymptomsQuestion = false;
  bool _showPanicSymptomsSelector = false;
  bool _showPanicSymptomsInput = false;
  bool _recordSaved = false;

  DateTime? _panicOccurrenceDate;
  TimeOfDay? _panicOccurrenceTime;
  DateTime? _panicOccurredAt;
  String? _panicContext;
  bool _panicContextIsCustom = false;
  final Set<String> _panicSymptomsSelections = <String>{};
  String? _panicSymptomsCustomValue;
  bool _panicSymptomsCustomActive = false;
  List<String>? _panicSymptomsAnswer;

  Timer? _emojiPromptTimer;
  Timer? _followupTimer;
  Timer? _composerTimer;
  Timer? _panicQuestionTimer;
  Timer? _panicOptionsTimer;
  Timer? _panicOccurrenceQuestionTimer;
  Timer? _panicOccurrenceSelectorTimer;
  Timer? _panicContextQuestionTimer;
  Timer? _panicContextSelectorTimer;
  Timer? _panicSymptomsQuestionTimer;
  Timer? _panicSymptomsSelectorTimer;

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

  @override
  void dispose() {
    _emojiPromptTimer?.cancel();
    _followupTimer?.cancel();
    _composerTimer?.cancel();
    _panicQuestionTimer?.cancel();
    _panicOptionsTimer?.cancel();
    _panicOccurrenceQuestionTimer?.cancel();
    _panicOccurrenceSelectorTimer?.cancel();
    _panicContextQuestionTimer?.cancel();
    _panicContextSelectorTimer?.cancel();
    _panicSymptomsQuestionTimer?.cancel();
    _panicSymptomsSelectorTimer?.cancel();
    _entryController.dispose();
    _panicContextController.dispose();
    _panicSymptomsController.dispose();
    super.dispose();
  }

  void _handleEmojiTap(String emoji) {
    _cancelPanicFlowTimers();

    setState(() {
      _selectedEmoji = emoji;
      _submittedEntry = null;
      _resetPanicFlowState();
    });

    _entryController.clear();
    _panicContextController.clear();
    _panicSymptomsController.clear();
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

    _cancelPanicFlowTimers();

    setState(() {
      _submittedEntry = entry;
      _resetPanicFlowState();
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

  Future<void> _handlePanicResponse(bool hadAttack) async {
    _panicOccurrenceQuestionTimer?.cancel();
    _panicOccurrenceSelectorTimer?.cancel();
    _panicContextQuestionTimer?.cancel();
    _panicContextSelectorTimer?.cancel();

    FocusScope.of(context).unfocus();

    if (!hadAttack) {
      setState(() {
        _panicAttackOccurred = false;
        _resetOccurrenceState();
        _resetContextState();
        _resetSymptomsState();
        _showPanicOptions = false;
        _showPanicOccurrenceQuestion = false;
        _showPanicOccurrenceSelector = false;
        _showPanicContextQuestion = false;
        _showPanicContextSelector = false;
        _showPanicContextInput = false;
        _showPanicSymptomsQuestion = false;
        _showPanicSymptomsSelector = false;
        _showPanicSymptomsInput = false;
        _recordSaved = false;
      });
      await _saveRecord(panicOccurred: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _recordSaved = true;
      });
      debugPrint('오늘 공황발작 있었어?: 아니오');
      return;
    }

    setState(() {
      _panicAttackOccurred = true;
      _resetOccurrenceState();
      _resetContextState();
      _resetSymptomsState();
      _recordSaved = false;
      _showPanicOptions = false;
      _showPanicOccurrenceQuestion = false;
      _showPanicOccurrenceSelector = false;
      _showPanicContextQuestion = false;
      _showPanicContextSelector = false;
      _showPanicContextInput = false;
      _showPanicSymptomsQuestion = false;
      _showPanicSymptomsSelector = false;
      _showPanicSymptomsInput = false;
    });
    debugPrint('오늘 공황발작 있었어?: 예');

    _panicOccurrenceQuestionTimer =
        Timer(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showPanicOccurrenceQuestion = true;
      });

      _panicOccurrenceSelectorTimer =
          Timer(const Duration(milliseconds: 380), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _showPanicOccurrenceSelector = true;
        });
      });
    });
  }

  Future<void> _pickPanicOccurrenceDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _panicOccurrenceDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
    );

    if (!mounted) {
      return;
    }

    if (selected != null) {
      setState(() {
        _panicOccurrenceDate = selected;
      });
    }
  }

  Future<void> _pickPanicOccurrenceTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime:
          _panicOccurrenceTime ?? TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (!mounted) {
      return;
    }

    if (selected != null) {
      setState(() {
        _panicOccurrenceTime = selected;
      });
    }
  }

  void _handlePanicOccurrenceSave() {
    if (_panicOccurrenceDate == null || _panicOccurrenceTime == null) {
      return;
    }

    final date = _panicOccurrenceDate!;
    final time = _panicOccurrenceTime!;
    final occurrence =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      _panicOccurredAt = occurrence;
      _recordSaved = false;
      _showPanicOccurrenceSelector = false;
      _showPanicContextQuestion = false;
      _showPanicContextSelector = false;
      _showPanicContextInput = false;
      _resetContextState();
      _resetSymptomsState();
    });

    debugPrint('공황 발생 시각 기록: $_panicOccurredAt');

    _panicContextQuestionTimer = Timer(const Duration(milliseconds: 480), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showPanicContextQuestion = true;
      });

      _panicContextSelectorTimer = Timer(const Duration(milliseconds: 360), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _showPanicContextSelector = true;
        });
      });
    });
  }

  void _handlePanicContextSelect(String selectedContext,
      {bool isCustom = false}) {
    FocusScope.of(context).unfocus();
    if (isCustom) {
      setState(() {
        _panicContextIsCustom = true;
        _showPanicContextSelector = true;
        _showPanicContextInput = true;
        _recordSaved = false;
        _resetSymptomsState();
      });
      _panicContextController.text = _panicContext ?? '';
      return;
    }

    setState(() {
      _panicContext = selectedContext;
      _panicContextIsCustom = false;
      _showPanicContextInput = false;
      _panicContextController.clear();
      _recordSaved = false;
    });
    debugPrint('공황 상황 선택: $selectedContext');
    _startPanicSymptomsFlow();
  }

  void _handleCustomContextSubmit() {
    final value = _panicContextController.text.trim();
    if (value.isEmpty) {
      return;
    }

    setState(() {
      _panicContext = value;
      _panicContextIsCustom = true;
      _showPanicContextInput = false;
      _recordSaved = false;
    });
    debugPrint('공황 상황 직접입력: $value');
    FocusScope.of(context).unfocus();
    _startPanicSymptomsFlow();
  }

  void _cancelPanicFlowTimers() {
    _followupTimer?.cancel();
    _composerTimer?.cancel();
    _panicQuestionTimer?.cancel();
    _panicOptionsTimer?.cancel();
    _panicOccurrenceQuestionTimer?.cancel();
    _panicOccurrenceSelectorTimer?.cancel();
    _panicContextQuestionTimer?.cancel();
    _panicContextSelectorTimer?.cancel();
    _panicSymptomsQuestionTimer?.cancel();
    _panicSymptomsSelectorTimer?.cancel();
  }

  void _resetPanicFlowState() {
    _panicAttackOccurred = null;
    _resetOccurrenceState();
    _resetContextState();
    _resetSymptomsState();
    _recordSaved = false;
    _showPanicQuestion = false;
    _showPanicOptions = false;
    _showPanicOccurrenceQuestion = false;
    _showPanicOccurrenceSelector = false;
    _showPanicContextQuestion = false;
    _showPanicContextSelector = false;
    _showPanicContextInput = false;
    _showPanicSymptomsQuestion = false;
    _showPanicSymptomsSelector = false;
    _showPanicSymptomsInput = false;
  }

  void _resetOccurrenceState() {
    _panicOccurrenceDate = null;
    _panicOccurrenceTime = null;
    _panicOccurredAt = null;
  }

  void _resetContextState() {
    _panicContext = null;
    _panicContextIsCustom = false;
    _panicContextController.clear();
  }

  void _resetSymptomsState() {
    _panicSymptomsSelections.clear();
    _panicSymptomsCustomValue = null;
    _panicSymptomsCustomActive = false;
    _panicSymptomsAnswer = null;
    _panicSymptomsController.clear();
    _showPanicSymptomsQuestion = false;
    _showPanicSymptomsSelector = false;
    _showPanicSymptomsInput = false;
  }

  void _startPanicSymptomsFlow() {
    _panicSymptomsQuestionTimer?.cancel();
    _panicSymptomsSelectorTimer?.cancel();

    setState(() {
      _showPanicSymptomsQuestion = false;
      _showPanicSymptomsSelector = false;
      _showPanicSymptomsInput = false;
      _panicSymptomsCustomActive = false;
      _panicSymptomsSelections.clear();
      _panicSymptomsCustomValue = null;
      _panicSymptomsAnswer = null;
      _panicSymptomsController.clear();
      _recordSaved = false;
    });

    _panicSymptomsQuestionTimer = Timer(const Duration(milliseconds: 460), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showPanicSymptomsQuestion = true;
      });

      _panicSymptomsSelectorTimer =
          Timer(const Duration(milliseconds: 340), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _showPanicSymptomsSelector = true;
        });
      });
    });
  }

  void _handleSymptomSelect(String symptom, {bool isCustom = false}) {
    if (isCustom) {
      setState(() {
        _panicSymptomsCustomActive = true;
        _showPanicSymptomsInput = true;
        _recordSaved = false;
        _panicSymptomsAnswer = null;
      });
      _panicSymptomsController.text = _panicSymptomsCustomValue ?? '';
      debugPrint('공황 증상 커스텀 입력 활성화');
      return;
    }

    setState(() {
      if (_panicSymptomsSelections.contains(symptom)) {
        _panicSymptomsSelections.remove(symptom);
      } else {
        _panicSymptomsSelections.add(symptom);
      }
      _recordSaved = false;
      _panicSymptomsAnswer = null;
    });
    debugPrint('공황 증상 선택 토글: $symptom');
  }

  void _handleCustomSymptomSubmit() {
    final value = _panicSymptomsController.text.trim();
    if (value.isEmpty) {
      return;
    }

    setState(() {
      if (_panicSymptomsCustomValue != null) {
        _panicSymptomsSelections.remove(_panicSymptomsCustomValue);
      }
      _panicSymptomsCustomValue = value;
      _panicSymptomsSelections.add(value);
      _panicSymptomsCustomActive = false;
      _showPanicSymptomsInput = false;
      _recordSaved = false;
      _panicSymptomsController.clear();
      _panicSymptomsAnswer = null;
    });
    debugPrint('공황 증상 직접입력: $value');
    FocusScope.of(context).unfocus();
  }

  Future<void> _handleSymptomsSave() async {
    if (_panicSymptomsSelections.isEmpty) {
      return;
    }

    final answers = _panicSymptomsSelections.toList()..sort();
    setState(() {
      _panicSymptomsAnswer = answers;
      _showPanicSymptomsSelector = false;
      _showPanicSymptomsInput = false;
      _panicSymptomsCustomActive = false;
      _recordSaved = false;
    });
    debugPrint('공황 증상 저장: $answers');
    await _saveRecord(panicOccurred: true, symptoms: answers);
    if (!mounted) {
      return;
    }
    setState(() {
      _recordSaved = true;
    });
  }

  Future<void> _saveRecord({
    required bool panicOccurred,
    List<String>? symptoms,
  }) async {
    final mood = _selectedEmoji;
    if (mood == null) {
      return;
    }

    final now = DateTime.now();
    final trimmedEntry = _submittedEntry?.trim();
    final normalizedEntry =
        (trimmedEntry != null && trimmedEntry.isEmpty) ? null : trimmedEntry;
    final record = PanicRecord(
      id: 'record-${now.microsecondsSinceEpoch}',
      createdAt: now,
      moodEmoji: mood,
      entry: normalizedEntry,
      panicOccurred: panicOccurred,
      panicOccurredAt: panicOccurred ? _panicOccurredAt : null,
      panicContext: panicOccurred ? _panicContext : null,
      panicSymptoms: panicOccurred
          ? List<String>.unmodifiable(
              symptoms ?? _panicSymptomsAnswer ?? const <String>[])
          : const <String>[],
    );

    await ref.read(recordHistoryControllerProvider.notifier).addRecord(record);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDateTime(DateTime dateTime) {
    final time = TimeOfDay.fromDateTime(dateTime);
    return '${_formatDate(dateTime)} ${_formatTimeOfDay(time)}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final hasSelectedEmoji = _selectedEmoji != null;
    final hasJournalEntry = _submittedEntry != null;
    final hasPanicResponse = _panicAttackOccurred != null;
    final panicAttackAffirmative = _panicAttackOccurred == true;
    final hasPanicOccurrenceSaved = _panicOccurredAt != null;
    final hasPanicContextAnswer = _panicContext != null;
    final hasPanicSymptomsAnswer = _panicSymptomsAnswer != null;

    final dateLabel = _panicOccurrenceDate != null
        ? _formatDate(_panicOccurrenceDate!)
        : '날짜 선택';
    final timeLabel = _panicOccurrenceTime != null
        ? _formatTimeOfDay(_panicOccurrenceTime!)
        : '시간 선택';
    final canSaveOccurrence =
        _panicOccurrenceDate != null && _panicOccurrenceTime != null;

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

    if (_showPanicOccurrenceQuestion && panicAttackAffirmative) {
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
            '언제 증상이 일어났어?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF2E2822),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ]);
    }

    if (_showPanicOccurrenceSelector &&
        panicAttackAffirmative &&
        !_showPanicContextQuestion) {
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
          child: _PanicOccurrenceSelector(
            dateLabel: dateLabel,
            timeLabel: timeLabel,
            canSave: canSaveOccurrence,
            onPickDate: _pickPanicOccurrenceDate,
            onPickTime: _pickPanicOccurrenceTime,
            onSave: _handlePanicOccurrenceSave,
          ),
        ),
      ]);
    }

    if (_panicOccurredAt != null) {
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
            '${_formatDateTime(_panicOccurredAt!)}에 증상이 있었어.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF2A2622),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ]);
    }

    if (_showPanicContextQuestion && panicAttackAffirmative) {
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
            '어떤 상황에서 일어났어?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF2E2822),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ]);
    }

    if (_showPanicContextSelector &&
        panicAttackAffirmative &&
        !hasPanicContextAnswer) {
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
          child: _PanicContextSelector(
            selectedContext: _panicContextIsCustom ? '기타(직접입력)' : _panicContext,
            onSelect: _handlePanicContextSelect,
          ),
        ),
      ]);
    }

    if (_showPanicContextInput && panicAttackAffirmative) {
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
          child: _CustomContextComposer(
            controller: _panicContextController,
            onSubmit: _handleCustomContextSubmit,
          ),
        ),
      ]);
    }

    if (hasPanicContextAnswer) {
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
            '${_panicContext!} 상황이었어.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF2A2622),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ]);
    }

    if (_showPanicSymptomsQuestion && panicAttackAffirmative) {
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
            '신체적 증상은 어땠어?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF2E2822),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ]);
    }

    if (_showPanicSymptomsSelector &&
        panicAttackAffirmative &&
        !hasPanicSymptomsAnswer) {
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
          child: _PanicSymptomsSelector(
            selectedSymptoms: _panicSymptomsSelections,
            customSelected:
                _panicSymptomsCustomActive || _panicSymptomsCustomValue != null,
            onSelect: _handleSymptomSelect,
            onSave: _handleSymptomsSave,
            canSave: _panicSymptomsSelections.isNotEmpty,
          ),
        ),
      ]);
    }

    if (_showPanicSymptomsInput && panicAttackAffirmative) {
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
          child: _CustomSymptomComposer(
            controller: _panicSymptomsController,
            onSubmit: _handleCustomSymptomSubmit,
          ),
        ),
      ]);
    }

    if (_panicSymptomsAnswer != null) {
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
            '${_panicSymptomsAnswer!.join(', ')} 증상이 있었어.',
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
    } else if (panicAttackAffirmative &&
        !_showPanicOccurrenceQuestion &&
        !_showPanicContextQuestion &&
        !_showPanicSymptomsQuestion) {
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
                  panicAttackAffirmative: panicAttackAffirmative,
                  isPanicOccurrenceQuestionVisible:
                      _showPanicOccurrenceQuestion,
                  isPanicOccurrenceSelectorVisible:
                      _showPanicOccurrenceSelector,
                  hasPanicOccurrenceSaved: hasPanicOccurrenceSaved,
                  isPanicContextQuestionVisible: _showPanicContextQuestion,
                  isPanicContextSelectorVisible: _showPanicContextSelector,
                  isPanicContextInputVisible: _showPanicContextInput,
                  hasPanicContextAnswer: hasPanicContextAnswer,
                  isPanicSymptomsQuestionVisible: _showPanicSymptomsQuestion,
                  isPanicSymptomsSelectorVisible: _showPanicSymptomsSelector,
                  isPanicSymptomsInputVisible: _showPanicSymptomsInput,
                  hasPanicSymptomsAnswer: hasPanicSymptomsAnswer,
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

class _PanicOccurrenceSelector extends StatelessWidget {
  const _PanicOccurrenceSelector({
    required this.dateLabel,
    required this.timeLabel,
    required this.canSave,
    required this.onPickDate,
    required this.onPickTime,
    required this.onSave,
  });

  final String dateLabel;
  final String timeLabel;
  final bool canSave;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '증상이 시작된 시점을 기록해줘',
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
                onPressed: onPickDate,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(dateLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onPickTime,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(timeLabel),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: canSave ? onSave : null,
          icon: const Icon(Icons.save_outlined),
          label: const Text('저장'),
        ),
      ],
    );
  }
}

class _PanicContextSelector extends StatelessWidget {
  const _PanicContextSelector({
    required this.selectedContext,
    required this.onSelect,
  });

  final String? selectedContext;
  final void Function(String context, {bool isCustom}) onSelect;

  static const _options = [
    '대중교통',
    '밀폐공간',
    '사람이 많은 공간',
    '이동 중',
    '고립된 상황',
    '기타(직접입력)',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '해당하는 상황을 선택해줘',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final option in _options)
              _PillOption(
                label: option,
                isSelected: option == selectedContext,
                onTap: () => onSelect(option, isCustom: option == '기타(직접입력)'),
              ),
          ],
        ),
      ],
    );
  }
}

class _PillOption extends StatelessWidget {
  const _PillOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color:
                isSelected ? color : theme.colorScheme.outline.withOpacity(0.5),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? color : const Color(0xFF2A2622),
          ),
        ),
      ),
    );
  }
}

class _CustomContextComposer extends StatelessWidget {
  const _CustomContextComposer({
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final isEnabled = value.text.trim().isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              minLines: 1,
              maxLines: 2,
              maxLength: 30,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: const InputDecoration(
                hintText: '상황을 직접 입력해줘',
                border: InputBorder.none,
                counterText: '',
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: isEnabled ? onSubmit : null,
              icon: const Icon(Icons.check_rounded),
              label: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

class _PanicSymptomsSelector extends StatelessWidget {
  const _PanicSymptomsSelector({
    required this.selectedSymptoms,
    required this.customSelected,
    required this.onSelect,
    required this.onSave,
    required this.canSave,
  });

  final Set<String> selectedSymptoms;
  final bool customSelected;
  final void Function(String symptom, {bool isCustom}) onSelect;
  final VoidCallback onSave;
  final bool canSave;

  static const _options = [
    '심장 두근거림',
    '숨 가쁨',
    '어지럼증',
    '손발 떨림',
    '식은땀',
    '기타(직접입력)',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '해당하는 증상을 선택해줘 (복수 선택 가능)',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final option in _options)
              _SymptomsPillOption(
                label: option,
                isSelected: option == '기타(직접입력)'
                    ? customSelected
                    : selectedSymptoms.contains(option),
                onTap: () => onSelect(option, isCustom: option == '기타(직접입력)'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: canSave ? onSave : null,
          icon: const Icon(Icons.save_alt_rounded),
          label: const Text('증상 저장'),
        ),
      ],
    );
  }
}

class _SymptomsPillOption extends StatelessWidget {
  const _SymptomsPillOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color:
                isSelected ? color : theme.colorScheme.outline.withOpacity(0.5),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? color : const Color(0xFF2A2622),
          ),
        ),
      ),
    );
  }
}

class _CustomSymptomComposer extends StatelessWidget {
  const _CustomSymptomComposer({
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final isEnabled = value.text.trim().isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              minLines: 1,
              maxLines: 2,
              maxLength: 30,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: const InputDecoration(
                hintText: '증상을 직접 입력해줘',
                border: InputBorder.none,
                counterText: '',
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: isEnabled ? onSubmit : null,
              icon: const Icon(Icons.check_rounded),
              label: const Text('확인'),
            ),
          ],
        );
      },
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
    required this.panicAttackAffirmative,
    required this.isPanicOccurrenceQuestionVisible,
    required this.isPanicOccurrenceSelectorVisible,
    required this.hasPanicOccurrenceSaved,
    required this.isPanicContextQuestionVisible,
    required this.isPanicContextSelectorVisible,
    required this.isPanicContextInputVisible,
    required this.hasPanicContextAnswer,
    required this.isPanicSymptomsQuestionVisible,
    required this.isPanicSymptomsSelectorVisible,
    required this.isPanicSymptomsInputVisible,
    required this.hasPanicSymptomsAnswer,
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
  final bool panicAttackAffirmative;
  final bool isPanicOccurrenceQuestionVisible;
  final bool isPanicOccurrenceSelectorVisible;
  final bool hasPanicOccurrenceSaved;
  final bool isPanicContextQuestionVisible;
  final bool isPanicContextSelectorVisible;
  final bool isPanicContextInputVisible;
  final bool hasPanicContextAnswer;
  final bool isPanicSymptomsQuestionVisible;
  final bool isPanicSymptomsSelectorVisible;
  final bool isPanicSymptomsInputVisible;
  final bool hasPanicSymptomsAnswer;
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
    } else if (panicAttackAffirmative && !hasPanicOccurrenceSaved) {
      subtitle = isPanicOccurrenceSelectorVisible
          ? '증상이 시작된 시점을 선택해 주세요'
          : isPanicOccurrenceQuestionVisible
              ? '마지막 질문을 생각하고 있어요...'
              : '마지막 질문을 준비하고 있어요';
    } else if (panicAttackAffirmative && !hasPanicContextAnswer) {
      subtitle = isPanicContextInputVisible
          ? '상황을 입력하고 확인을 눌러주세요'
          : isPanicContextSelectorVisible
              ? '해당하는 상황을 선택해 주세요'
              : isPanicContextQuestionVisible
                  ? '조금만 더 이야기해볼까요?'
                  : '정리 중이에요...';
    } else if (panicAttackAffirmative && !hasPanicSymptomsAnswer) {
      subtitle = isPanicSymptomsInputVisible
          ? '증상을 입력하고 확인을 눌러주세요'
          : isPanicSymptomsSelectorVisible
              ? '해당하는 증상을 선택해 주세요'
              : isPanicSymptomsQuestionVisible
                  ? '조금만 더 이야기할게요'
                  : '정리 중이에요...';
    } else {
      subtitle = recordSaved ? '답변을 저장했어요. 오늘도 수고했어요!' : '기록을 마무리하는 중이에요';
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
