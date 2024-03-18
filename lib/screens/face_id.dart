import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class FaceIdScreen extends StatefulWidget {
  const FaceIdScreen({super.key});

  @override
  State<FaceIdScreen> createState() => _FaceIdScreenState();
}

class _FaceIdScreenState extends State<FaceIdScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  _SupportState _supportState = _SupportState.unknown;

  String _authorized = '인증되지 않음';

  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();

    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;

    try {
      setState(() {
        _isAuthenticating = true;

        _authorized = '인증 진행 중...';
      });

      authenticated = await auth.authenticate(
        localizedReason: '가능한 생체 인식으로 인증해주세요.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      setState(() {
        _isAuthenticating = false;
        _authorized = '인증 진행 중...';
      });
    } on PlatformException catch (e) {
      print(e);

      setState(() {
        _isAuthenticating = false;
        _authorized = '오류 발생';
      });

      return;
    }

    if (!mounted) {
      return;
    }

    final String message = authenticated ? '인증 완료' : '인증 실패';

    setState(() {
      _authorized = message;
    });
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();

    setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Face ID 인증'),
        ),
        body: ListView(
          padding: const EdgeInsets.only(top: 30),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_supportState == _SupportState.unknown)
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                  )
                else if (_supportState == _SupportState.supported)
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Text("이 기기는 생체인식이 지원됩니다."),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Text("이 기기는 생체인식이 지원되지 않습니다."),
                  ),
                const Divider(height: 100),
                Text('현재 인증 상태: $_authorized\n'),
                if (_isAuthenticating)
                  ElevatedButton(
                    onPressed: _cancelAuthentication,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Text('인증 취소'),
                        Icon(Icons.cancel),
                      ],
                    ),
                  )
                else
                  Column(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _authenticateWithBiometrics,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(_isAuthenticating ? '취소하기' : 'Face ID로 인증하기'),
                            const Icon(Icons.face_outlined),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// enum _SupportState {
//   unknown,
//   supported,
//   unsupported,
// }
