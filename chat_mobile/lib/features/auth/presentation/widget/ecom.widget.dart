import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EcomWidget extends StatelessWidget {
  final int hight;
  final int width;
  final int size;

  const EcomWidget({super.key, required this.hight, required this.width, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.toDouble(),
      height: hight.toDouble(),
      alignment: Alignment.center,

      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color.fromRGBO(63, 81, 243, 1),
          width: 2,
        ),
      ),
      // child: Center(
      child: Transform.translate(
        offset: const Offset(0, -5), // 👈 Move text 4 pixels up
        child: Text(
          'ECOM',
          style: GoogleFonts.caveatBrush(
            fontSize: size.toDouble(),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.96,
            color: const Color.fromRGBO(63, 81, 243, 1),
          ),
        ),
      ),
    );
  }
}
