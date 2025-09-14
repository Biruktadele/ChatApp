import 'dart:ui';

import 'package:flutter/material.dart';

class BlurPageRoute<T> extends PageRouteBuilder<T> {
  BlurPageRoute({
    required WidgetBuilder builder,
    Duration duration = const Duration(milliseconds: 400),
    RouteSettings? settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionDuration: duration,
         reverseTransitionDuration: const Duration(milliseconds: 300),
         opaque: false,
         barrierColor: Colors.transparent,
         settings: settings,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final curved = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOutCubic,
             reverseCurve: Curves.easeInCubic,
           );
           final blur = Tween<double>(begin: 0, end: 14).animate(curved);
           return AnimatedBuilder(
             animation: blur,
             builder: (context, _) {
               return BackdropFilter(
                 filter: ImageFilter.blur(
                   sigmaX: blur.value,
                   sigmaY: blur.value,
                 ),
                 child: FadeTransition(opacity: curved, child: child),
               );
             },
           );
         },
       );
}
