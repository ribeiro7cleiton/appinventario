import 'package:flutter/material.dart';
import 'package:inventario/pages/login.page.dart';
import 'package:asuka/asuka.dart' as asuka;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inventário',
        theme: ThemeData(primarySwatch: Colors.green),
        builder: asuka.builder,
        navigatorObservers: [asuka.asukaHeroController],
        initialRoute: '/',
        routes: {'/': (_) => LoginPage()});
  }
}
