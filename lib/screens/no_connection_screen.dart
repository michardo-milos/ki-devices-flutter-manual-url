import 'package:flutter/material.dart';

class NoConnectionScreen extends StatefulWidget {
  static const routeName = '/no_connection';
  const NoConnectionScreen({Key? key}) : super(key: key);

  @override
  State<NoConnectionScreen> createState() => _NoConnectionScreenState();
}

class _NoConnectionScreenState extends State<NoConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const <Widget>[
            Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 150,
            ),
            Text(
              'Sem conexão á Internet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 150
              ),
            )
          ],
        ),
      ),
    );
  }
}
