import 'package:flutter/material.dart';

class InputTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextInputType inputType;
  final bool obscureText;
  final TextEditingController controller;

  const InputTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.inputType,
    this.obscureText = false,
    required this.controller,
  });

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
  }

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
          controller: widget.controller,
          keyboardType: widget.inputType,
          obscureText: _isObscure,
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
            hintText: widget.label,
            hintStyle: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 20.5 / 18,
              letterSpacing: 0.15,
              color: Colors.grey.withOpacity(0.6),
            ),
            prefixIcon: Icon(widget.icon, color: Colors.grey),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
