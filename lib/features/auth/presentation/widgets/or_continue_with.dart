import 'package:flutter/material.dart';

class OrContinueWith extends StatelessWidget {
  const OrContinueWith({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
            endIndent: 10,
          ),
        ),
        Text(
          "or continue with",
          style: TextStyle(
            color: Colors.grey,
            fontFamily: 'Lexend',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 10,
          ),
        ),
      ],
    );
  }
}
