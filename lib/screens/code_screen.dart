import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ki_devices_flutter_manual_url/screens/iframe_screen.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usb_serial/usb_serial.dart';

class CodeScreen extends StatefulWidget {
  static const routeName = '/code';
  const CodeScreen({Key? key}) : super(key: key);

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  final _storage = const FlutterSecureStorage();
  final dio = Dio();
  late int code;
  late Timer codeTimer;
  late Timer requestTimer;

  @override
  void initState () {
    // _checkSerial();
    _generateCode();
    super.initState();
  }

  @override
  void dispose () {
    codeTimer.cancel();
    requestTimer.cancel();
    super.dispose();
  }

  void _generateCode () {
    Random random = Random();
    setState(() {
      code = random.nextInt(9000) + 1000;
    });
    codeTimer = Timer(const Duration(minutes: 5), _generateCode);
    _sendCodeRequest();
  }

  void _sendCodeRequest () async {
    String? baseUrl = await _storage.read(key: 'base_url');
    // String? baseUrl = '192.168.43.67';
    if (baseUrl != null) {
      String url = '$baseUrl/start';
      Map<String, Map<String, int>> data = { 'params': { 'code': code } };
      var response = await dio.post(url, data: data);
      requestTimer = Timer(const Duration(seconds: 20), _sendCodeRequest);
      print('response.data');
      print(response.data);
      if (response.data['result']['errors'] == null) {
        requestTimer.cancel();
        codeTimer.cancel();
        _writLoginCredentials(response.data['result']);
      }

    }
  }

  void _writLoginCredentials (data) async {
    await _storage.write(key: 'user', value: data['username']);
    await _storage.write(key: 'pw', value: data['pw']);
    await _storage.write(key: 'dashboard_name', value: data['name']);
    Navigator.of(context).pushNamed(IframeScreen.routeName);
  }

  void _checkSerial () async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    List<UsbDevice> devices = await UsbSerial.listDevices();
    print(devices);
    UsbPort? port;
    port = await devices[0].create();
    if (port != null) {
      bool openResult = await port.open();
      if ( !openResult ) {
        print("Failed to open");
        return;
      }

      await port.setDTR(true);
      await port.setRTS(true);

      port.setPortParameters(115200, UsbPort.DATABITS_8,
          UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

      // print first result and close port.
      port.inputStream?.listen((Uint8List event) {
        print(event);
      });
    }
  }

  List<Widget> _getCodeUi () {
    List<Widget> list = [];
    code.toString().characters.forEach((character) {
      list.add(Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Text(
            character,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 50
            ),
          ),
        ),
      ));
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Image.network()
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(
                    Icons.ac_unit_sharp,
                    color: Colors.white,
                    size: 70,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      'Kioda',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25
                      ),
                    ),
                    Text(
                      'Dashboards & Kiosks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25
                      ),
                    ),
                  ],
                )
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _getCodeUi()
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[
                      Text(
                        'KIODA - INDUSTRY EVERWHERE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10
                        ),
                      ),
                      Text(
                        'For help, please send email to support@kioda.com',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10
                        ),
                      ),
                    ],
                  ),
                ),
                // const Icon(
                //   Icons.qr_code,
                //   color: Colors.white,
                //   size: 70,
                // )
              ],
            )
          ],
        ),
      ),
    );
  }
}
