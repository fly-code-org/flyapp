import 'package:flutter/material.dart';

class NotRecievedOTP extends StatelessWidget {
  final VoidCallback? onTap;

  const NotRecievedOTP({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 377,
      child: GestureDetector(
        onTap: onTap,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Didn't recieve OTP?",
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              WidgetSpan(
                child: SizedBox(width: 5),
              ),
              TextSpan(
                text: "Resend",
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
