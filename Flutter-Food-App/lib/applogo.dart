import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class CommonLogo extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          "assets/logo.png",
          width: 100,
        ),
        const SizedBox(height: 16),
        "To-Do App".text.xl2.bold.white.make(),
        "Make A List of your task".text.light.white.wider.lg.make(),
      ],
    );
  }
}