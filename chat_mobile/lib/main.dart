import 'package:chat_mobile/core/constant/color_const.dart';
import 'package:chat_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_mobile/features/auth/presentation/page/login_page.dart';
import 'package:chat_mobile/features/auth/presentation/page/sign_up_page.dart';
import 'package:chat_mobile/features/chat/presentation/screens/Home_page.dart';
import 'package:chat_mobile/features/chat/presentation/screens/chat_page.dart';
import 'package:chat_mobile/features/chat/presentation/widgets/home_wdget/profile_show.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;

void main() {
  di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => di.sl<AuthBloc>(),
     child: MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: bg,
      ),
      debugShowCheckedModeBanner: false,
      
      home: const SignUpPage(),
     ),
    );
  }
}

