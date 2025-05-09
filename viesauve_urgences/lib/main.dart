import 'dart:async';
import 'package:flutter/material.dart';
import 'admins/admin.dart';
import 'agents/agents.dart';
import 'logins/loginpage.dart';
import 'myfirstpage.dart';
import 'superadmin/super.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyLogin(),
      routes: {
        '/home': (context) => FirstPage(),
        '/superadmin':
            (context) =>
                SuperAdminPage(isDarkMode: _themeMode == ThemeMode.dark),
        '/admin':
            (context) => AdminPage(isDarkMode: _themeMode == ThemeMode.dark),
        '/agent': (context) => AgentsPages(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
