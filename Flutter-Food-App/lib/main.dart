import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginPage.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(token: prefs.getString('token'),));
}

class MyApp extends StatelessWidget {

  final token;
  const MyApp({
    @required this.token,
    Key? key,
}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primaryColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: (token != null && JwtDecoder.isExpired(token) == false )?Dashboard(token: token):SignInPage());
      home: Dashboard(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiJ0ZXN0X3VzZXJfaWQiLCJleHAiOjE4OTM0NTYwMDB9.c2lnbmF0dXJl")    );
  }
}