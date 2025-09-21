import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '사용자 정보, 감정 기록 등 개인화 화면을 여기에 구현해 보세요.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
