import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/constant/color_const.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/page/Profile_screen.dart';
import 'features/auth/presentation/page/login_page.dart';
import 'features/auth/presentation/page/sign_up_page.dart';
import 'features/chat/presentation/bloc/bloc/chat_bloc.dart';
import 'features/chat/presentation/screens/Home_page.dart';
// import 'features/chat/presentation/screens/profile_page.dart';
import 'features/chat/presentation/screens/temptry/home_chat_screen.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  Future<List<String>> _getToken() async {
    final secureStorage = di.sl<FlutterSecureStorage>();
    String token = await secureStorage.read(key: 'auth_token') ?? '';
    String username = await secureStorage.read(key: 'username') ?? '';
    String userId = await secureStorage.read(key: 'user_id') ?? '';
    debugPrint('Retrieved token: $token');
    debugPrint('Retrieved username: $username');
    debugPrint('Retrieved userId: $userId');
    return [token, username, userId];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getToken(),
      builder: (context, snapshot) {
        final token = snapshot.data?[0] ?? '';
        final username = snapshot.data?[1] ?? '';
        // debugPrint('Auth token: $token');
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => di.sl<AuthBloc>()),
            BlocProvider(create: (_) => di.sl<ChatBloc>()),
          ],
          child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              scaffoldBackgroundColor: bg,
            ),
            debugShowCheckedModeBanner: false,

            home: token.isNotEmpty ? HomePage(username: username , token: token ) : const LoginPage(),
            // home: ProfileScreen(onBack: (){}),
          ),
        );
      },
    );
  }
}
