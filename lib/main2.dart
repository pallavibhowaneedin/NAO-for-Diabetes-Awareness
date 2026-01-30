import 'package:flutter/material.dart';
import 'data/user_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UserList(), // Set LogIn as the initial route
      routes: {
        '/list': (context) => const UserList(),
        //'/signup': (context) => const SignUp(),
      },
    );
  }
}
