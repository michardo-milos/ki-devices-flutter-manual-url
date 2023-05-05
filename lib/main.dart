import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ki_devices_flutter_manual_url/screens/code_screen.dart';
import 'package:ki_devices_flutter_manual_url/screens/iframe_screen.dart';
import 'package:ki_devices_flutter_manual_url/screens/no_connection_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ki_devices_flutter_manual_url/screens/url_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) => {
    runApp(const MyApp())
  });
  /*SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]).then((value) => {
    runApp(const MyApp())
  });*/
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      // home: const CodeScreen(),
      home: const DecideHomePage(),
      routes: {
        NoConnectionScreen.routeName: (ctx) => const NoConnectionScreen(),
        CodeScreen.routeName: (ctx) => const CodeScreen(),
        IframeScreen.routeName: (ctx) => const IframeScreen(),
        UrlScreen.routeName: (ctx) => const UrlScreen(),
      },
    );
  }
}

class DecideHomePage extends StatefulWidget {
  const DecideHomePage({Key? key}) : super(key: key);

  @override
  State<DecideHomePage> createState() => _DecideHomePageState();
}

class _DecideHomePageState extends State<DecideHomePage> {
  final _storage = const FlutterSecureStorage();
  late StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      print('subscription');
      print(result);
      if (result == ConnectivityResult.none) {
        Navigator.of(context).pushNamedAndRemoveUntil(NoConnectionScreen.routeName, ModalRoute.withName('/'));
      } else if (result == ConnectivityResult.wifi) {
        if (await _storage.read(key: 'base_url') == null) {
          Navigator.of(context).pushNamedAndRemoveUntil(UrlScreen.routeName, ModalRoute.withName('/'));
        } else if (await _storage.read(key: 'user') != null && await _storage.read(key: 'pw') != null && await _storage.read(key: 'dashboard_name') != null) {
          Navigator.of(context).pushNamedAndRemoveUntil(IframeScreen.routeName, ModalRoute.withName('/'));
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(CodeScreen.routeName, ModalRoute.withName('/'));
        }
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<Widget> _decideHomePage(BuildContext context) async {
    final Connectivity connectivity = Connectivity();
    ConnectivityResult result = await connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      return const NoConnectionScreen();
    }
    if (await _storage.read(key: 'base_url') == null) {
      return const UrlScreen();
    }
    if (await _storage.read(key: 'base_url') != null && await _storage.read(key: 'user') != null && await _storage.read(key: 'pw') != null && await _storage.read(key: 'dashboard_name') != null) {
      return const IframeScreen();
    }
    return const CodeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _decideHomePage(context),
        builder: (ctx, snapshot) {
          if (snapshot.data == null) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width / 2,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 80,
                    ),
                  )
              ),
            );
          }
          return snapshot.data as Widget;
        }
    );
  }
}

