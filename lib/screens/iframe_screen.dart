import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ki_devices_flutter_manual_url/screens/code_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/io.dart';
import 'package:restart_app/restart_app.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IframeScreen extends StatefulWidget {
  static const routeName = '/iframe';

  const IframeScreen({Key? key}) : super(key: key);

  @override
  State<IframeScreen> createState() => _IframeScreenState();
}

class _IframeScreenState extends State<IframeScreen> {
  final _storage = const FlutterSecureStorage();
  final dio = Dio();
  String dashboardUrl = '';
  late IOWebSocketChannel _channel;

  @override
  void initState() {
    _connectToWebSockets();
    _login();
    super.initState();
  }

  void _login() async {
    String? baseUrl = await _storage.read(key: 'base_url');
    // String? baseUrl = '192.168.43.67';
    if (baseUrl != null) {
      String url = '$baseUrl/login';
      String? user = await _storage.read(key: 'user');
      String? pw = await _storage.read(key: 'pw');
      if (user != null && pw != null) {
        Map<String, Map<String, String>> data = {
          'params': {'username': user, 'password': pw}
        };
        var response = await dio.post(url, data: data);
        print('ressponse');
        print(response);
        print("response.data['result']['token']");
        print(response.data['result']['token']);
        if (response.data['result']['token'] != null) {
          String sessionId = response.data['result']['token'];
          setState(() {
            dashboardUrl = 'http://$baseUrl:8069/dashboard/$sessionId';
          });
        } else {
          _removeCredentials();
        }
      } else {
        _removeCredentials();
      }
    }
  }

  void _removeCredentials () async {
    await _storage.delete(key: 'user');
    await _storage.delete(key: 'pw');
    await _storage.delete(key: 'dashboard_name');
    Navigator.of(context).pushReplacementNamed(CodeScreen.routeName);
  }

  void _connectToWebSockets () async {
    String? baseUrl = await _storage.read(key: 'base_url');
    // String? baseUrl = '192.168.43.67';
    if (baseUrl != null) {
      List urlWithoutMethod = baseUrl.split('http://');
      if (urlWithoutMethod.length == 1) {
        urlWithoutMethod = baseUrl.split('https://');
      }
      WebSocket.connect('ws://$urlWithoutMethod/websocket').then((ws) {
        var channel = IOWebSocketChannel(ws);

        channel.sink.add(jsonEncode({
          'event_name': 'subscribe',
          'data': {
            'channels': ['broadcast', 'restart'],
            'last': 0
          }
        }));

        channel.stream.listen((message) {
          var messageJson = jsonDecode(message);
          for (var singleMessage in messageJson) {
            switch (singleMessage['message']['type']) {
              case 'reboot':
                rebootDevice();
                break;
              case 'restart':
                restartApp();
                break;
              default:
                print('default');
            }
          }
        });
      });
    }
  }

  void restartApp () {
    Restart.restartApp();
  }

  void rebootDevice () async {
    /*Process.run('ls', []).then((ProcessResult results) {

      print("stdout:" + results.stdout);
      print("stderr:" + results.stderr);
    });*/
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: dashboardUrl.isNotEmpty
            ? WebView(
                initialUrl: dashboardUrl,
                javascriptMode: JavascriptMode.unrestricted,
              )
            : Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width / 3,
                  child: const CircularProgressIndicator(
                    color: Colors.blue,
                    strokeWidth: 20,
                  ),
                ),
              ),
      ),
    );
  }
}
