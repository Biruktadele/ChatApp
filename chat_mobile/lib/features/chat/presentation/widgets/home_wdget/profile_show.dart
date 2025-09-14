import 'package:flutter/material.dart';
import 'package:chat_mobile/core/constant/color_const.dart';

class ProfileShow extends StatefulWidget {
  const ProfileShow({super.key});

  @override
  State<ProfileShow> createState() => _ProfileShowState();
}

class _ProfileShowState extends State<ProfileShow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 32, top: 50),
      color: bg,
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: plusButton,
            child: ClipOval(
              child: Image(
                image: AssetImage('assets/images/man2.jpeg'),
                fit: BoxFit.cover,
                width: 50,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Martina Wolna',
            style: TextStyle(color: white,
             fontSize: 27 , 
           
             fontFamily: 'Roboto',
             letterSpacing: 1
             ),
          ),
        ],
      ),
    );
  }
}