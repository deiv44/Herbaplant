import 'package:flutter/material.dart';
import 'frontend/user/Screen/Homeuser.dart';
import 'frontend/Auth/UserSignin.dart';
import 'frontend/user/Screen/main_navigation.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Herbal App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: UserSignin(),
    );
  }
}
