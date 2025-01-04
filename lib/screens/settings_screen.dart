import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isPasswordEnabled = false;
  String? _currentPassword;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPasswordSettings();
  }

  Future<void> _loadPasswordSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPasswordEnabled = prefs.getBool('password_enabled') ?? false;
      _currentPassword = prefs.getString('password');
    });
  }

  Future<void> _togglePassword(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      // 비밀번호 설정 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('비밀번호 설정'),
          content: TextField(
            controller: _passwordController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(
              hintText: '4자리 숫자를 입력하세요',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isPasswordEnabled = false;
                });
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                if (_passwordController.text.length == 4) {
                  await prefs.setString('password', _passwordController.text);
                  await prefs.setBool('password_enabled', true);
                  setState(() {
                    _isPasswordEnabled = true;
                    _currentPassword = _passwordController.text;
                  });
                  _passwordController.clear();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('비밀번호가 설정되었습니다')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('4자리 숫자를 입력해주세요')),
                  );
                }
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      // 비밀번호 해제
      await prefs.setBool('password_enabled', false);
      await prefs.remove('password');
      setState(() {
        _isPasswordEnabled = false;
        _currentPassword = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 해제되었습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: SafeArea(
          top: true,
          minimum: const EdgeInsets.only(top: 20),
          child: AppBar(
            toolbarHeight: 120,
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                '설정',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                SwitchListTile(
                  title: const Text('비밀번호 설정'),
                  subtitle: Text(_isPasswordEnabled ? '비밀번호: $_currentPassword' : '비밀번호 없음'),
                  value: _isPasswordEnabled,
                  onChanged: _togglePassword,
                ),
                const Divider(),
                const ListTile(
                  title: Text('버전 정보'),
                  subtitle: Text('1.0.0'),
                ),
                const ListTile(
                  title: Text('개발자 정보'),
                  subtitle: Text('서현이일기'),
                ),
              ],
            ),
          ),
          // 푸터 위젯
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              border: const Border(
                top: BorderSide(
                  color: Colors.blue,
                  width: 0.5,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: const [
                  Text(
                    '서현아! 할아버지가 만들어준 일기장이란다.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2024 서현이일기. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
} 