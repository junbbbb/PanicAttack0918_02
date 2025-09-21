import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          ListTile(
            leading: Icon(Icons.dark_mode_outlined),
            title: Text('다크 모드'),
            subtitle: Text('추후 테마 전환 옵션을 연결하세요.'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('알림 설정'),
            subtitle: Text('푸시 알림 및 소리 설정을 구성할 수 있습니다.'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('앱 정보'),
            subtitle: Text('버전, 약관, 개인정보 처리 방침 등을 연결하세요.'),
          ),
        ],
      ),
    );
  }
}
