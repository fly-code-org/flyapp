import 'package:flutter/material.dart';

class PhoneNumberInputField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneNumberInputField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 377,
      height: 57,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 35 / 18,
            letterSpacing: 0.15,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter Phone Number',
            hintStyle: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 20.5 / 18,
              letterSpacing: 0.15,
              color: Colors.grey.withOpacity(0.6),
            ),
            prefixIcon: const Icon(Icons.phone, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
