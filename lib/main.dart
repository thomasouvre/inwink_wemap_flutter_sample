import 'package:flutter/material.dart';

import 'map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldKey,
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
      home: MyHomePage(
          title: 'Flutter Demo Home Page', scaffoldKey: _scaffoldKey),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  final mapKey = GlobalKey();
  MyHomePage({super.key, required this.title, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(title: Text(title)),
        body: Container(
            constraints: const BoxConstraints.expand(),
            child: MapView(
              key: mapKey,
              scaffoldMessengerKey: scaffoldKey,
            )));
  }
}
