import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Animation<double>? animation;

  const AnimatedAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation ?? kAlwaysDismissedAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: animation?.value ?? 1.0,
          child: Transform.translate(
            offset: Offset(0, (1 - (animation?.value ?? 1.0)) * -30),
            child: AppBar(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: leading,
              actions: actions,
              backgroundColor: Colors.white.withOpacity(0.85),
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  // Glassmorphism effect
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.7),
                      Colors.blue.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              systemOverlayStyle:
                  Theme.of(context).brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
