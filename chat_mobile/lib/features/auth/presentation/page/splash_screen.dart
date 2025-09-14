// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:google_fonts/google_fonts.dart';

// import 'login_page.txt';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   @override
// void initState() {
//   super.initState();

//   // Hide system UI
//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

//   // Schedule after build is complete
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     Future.delayed(const Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         PageRouteBuilder(
//           transitionDuration: const Duration(milliseconds: 300),
//           pageBuilder: (_, __, ___) => const LoginPage(),
//         ),
//       );
//     });
//   });
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
      
//       body: Stack(
//         children: [
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('images/splash.png'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,

//                 colors: [
//                   Color.fromRGBO(63, 81, 243, 0.5),
//                   Color.fromRGBO(63, 81, 243, 1),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             top: 279,
//             left: 63,
            
//             child: Container(
//               height: 121,
//               width: 264,
//               alignment: const Alignment(0, -0.3),
//               // padding: const EdgeInsets.only(bottom: 10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(31.03),
//               ),

//               ),
//             ),
//           Positioned(
//             top: 255,
//             left: 74,
            
//             child:Text(
//                   'ECOM',
//                   style: GoogleFonts.caveatBrush(
                    
//                     fontSize: 110,
//                     fontWeight: FontWeight.w400,
//                     letterSpacing: 0.02 * 110,
//                     color: const Color.fromRGBO(63, 81, 243, 1),
//                   ),

//               ),
//             ),

//           const Positioned(
//             top: 426,
//             left: 39,
            
//             child: Text(
//               'ECOMMERCE APP',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 35,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
