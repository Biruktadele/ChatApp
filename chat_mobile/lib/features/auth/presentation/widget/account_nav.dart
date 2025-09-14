import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AccountNav extends StatelessWidget {
  const AccountNav({super.key, required this.nav, required this.text, required this.page});
  final String nav;
  final String text;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color.fromRGBO(136, 136, 136, 1),

            // letterSpacing: 0.02 * 16,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => page));
          },
          child: Text(
            nav,
            style: const TextStyle(color: Color.fromRGBO(63, 81, 243, 1)),
          ),
        ),
      ],
    );
  }
}
