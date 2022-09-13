import 'package:flutter/material.dart';
import 'dart:async';

import 'package:easemob_apns/easemob_apns.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    EasemobApns.setHandler(
      onToken: (deviceToken, error) {
        debugPrint("deviceToken: $deviceToken, error: $error");
      },
      onLaunch: (map) {
        debugPrint("onLaunch: ${map?.keys.first}");
      },
      onMessage: (map) {
        debugPrint("onMessage: ${map.keys.first}");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: [
            TextButton(
              onPressed: registerToken,
              child: const Text("registerToken"),
            ),
            TextButton(
              onPressed: unregisterToken,
              child: const Text("unregisterToken"),
            ),
            TextButton(
              onPressed: pushOptions,
              child: const Text("pushOptions"),
            ),
          ],
        ),
      ),
    );
  }

  void pushOptions() async {
    EasemobApns.requestAuthorization(
      options: {
        AuthorizationOptions.alert,
        AuthorizationOptions.badge,
        AuthorizationOptions.sound
      },
    );
  }

  void registerToken() async {
    EasemobApns.registerDeviceToken();
  }

  void unregisterToken() async {
    EasemobApns.unregisterDeviceToken();
  }
}
