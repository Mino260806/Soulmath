import 'package:flutter/material.dart';

Route createGameRoute(WidgetBuilder pageBuilder) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => pageBuilder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = 0.0;
      const end = 1.0;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return FadeTransition(
        opacity: animation.drive(tween),
        child: child,
      );
    },
  );
}
