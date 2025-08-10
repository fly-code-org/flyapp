import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  final String text;

  const Separator({
    super.key,
    this.text = "Social tags", // Default text
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
            endIndent: 10,
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontFamily: 'Lexend',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Expanded(
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
