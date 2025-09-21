import 'package:flutter/material.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('기록'),
        centerTitle: false,
      ),
      body: const _RecordBackground(),
    );
  }
}

class _RecordBackground extends StatelessWidget {
  const _RecordBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF3F0FF),
            Color(0xFFE2DBFF),
            Color(0xFFD1C9FF),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          '기록 화면을 준비 중입니다.',
          style: TextStyle(color: Color(0xFF39322C), fontSize: 18),
        ),
      ),
    );
  }
}
