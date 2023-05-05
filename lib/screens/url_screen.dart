import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ki_devices_flutter_manual_url/screens/code_screen.dart';

import 'iframe_screen.dart';

class UrlScreen extends StatefulWidget {
  static const routeName = '/url';
  const UrlScreen({Key? key}) : super(key: key);

  @override
  State<UrlScreen> createState() => _UrlScreenState();
}

class _UrlScreenState extends State<UrlScreen> {
  final _storage = const FlutterSecureStorage();
  String _url = '';
  final _form = GlobalKey<FormState>();

  Future<void> _setUrl () async {
    print('here');
    bool isValid = _form.currentState!.validate();
    if (!isValid) return;
    FocusScope.of(context).unfocus();
    _form.currentState!.save();
    await _storage.write(key: "base_url", value: _url);
    if (await _storage.read(key: 'user') != null && await _storage.read(key: 'pw') != null && await _storage.read(key: 'dashboard_name') != null) {
      Navigator.of(context).pushNamed(IframeScreen.routeName);
    }
    Navigator.of(context).pushNamed(CodeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    maxLines: 1,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'URL',
                      fillColor: Colors.white,
                      labelStyle: TextStyle(
                          color: Colors.grey
                      ),
                    ),
                    onSaved: (value) {
                      _url = value as String;
                    },
                    validator: (value) {
                      if (value!.isEmpty) return 'Mandatory';
                      return null;
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 25),
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(vertical: 15)),
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor),
                            foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(15)))),
                        child: const Text(
                          'Next',
                        ),
                        onPressed: () {
                          _setUrl();
                        },
                    )
                  ),
                ],
              ),
            ),
          )],
        ),
      ),
    );
  }
}
