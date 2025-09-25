import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../record/controllers/record_history_controller.dart';
import '../../record/domain/panic_record.dart';

class AnalysisPage extends ConsumerWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('기록 분석'),
      ),
      body: recordsAsync.when(
        data: (records) => _RecordsView(records: records),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            _ErrorView(error: error, stackTrace: stackTrace),
      ),
    );
  }
}

class _RecordsView extends ConsumerWidget {
  const _RecordsView({required this.records});

  final List<PanicRecord> records;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (records.isEmpty) {
      return const _EmptyRecordsView();
    }

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await ref.read(recordHistoryControllerProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return _RecordCard(record: record);
        },
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final PanicRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final occurrenceText = record.panicOccurred
        ? (record.panicOccurredAt != null
            ? _formatDateTime(record.panicOccurredAt!)
            : '시간 미등록')
        : '발생하지 않음';
    final contextText =
        record.panicOccurred ? (record.panicContext ?? '상황 미등록') : '해당 없음';
    final symptoms =
        record.panicOccurred ? record.panicSymptoms : const <String>[];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.moodEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDateTime(record.createdAt),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.entry ?? '기록된 메모가 없어요.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: '공황 여부',
              value: record.panicOccurred ? '예' : '아니오',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: '발생 시점',
              value: occurrenceText,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: '상황',
              value: contextText,
            ),
            if (symptoms.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final symptom in symptoms)
                    Chip(
                      label: Text(symptom),
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.12),
                      shape: const StadiumBorder(),
                      labelStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _EmptyRecordsView extends StatelessWidget {
  const _EmptyRecordsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '아직 저장된 기록이 없어요.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '기록 탭에서 오늘의 기분을 남겨보세요.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.error, required this.stackTrace});

  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '기록을 불러오지 못했어요.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                ref.read(recordHistoryControllerProvider.notifier).refresh();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final date =
      '${local.year.toString().padLeft(4, '0')}.${local.month.toString().padLeft(2, '0')}.${local.day.toString().padLeft(2, '0')}';
  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  return '$date $time';
}
