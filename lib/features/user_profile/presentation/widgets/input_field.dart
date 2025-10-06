import 'package:flutter/material.dart';

class GeneralCustomInputField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;

  const GeneralCustomInputField({
    super.key,
    required this.onChanged,
    this.hintText, // optional
    this.keyboardType, // optional
  });

  @override
  State<GeneralCustomInputField> createState() =>
      _GeneralCustomInputFieldState();
}

class _GeneralCustomInputFieldState extends State<GeneralCustomInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 377,
      height: 57,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: _isFocused
              ? const Color.fromARGB(255, 134, 78, 190)
              : Colors.grey,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          focusNode: _focusNode,
          keyboardType: widget.keyboardType ?? TextInputType.name,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 35 / 18,
            letterSpacing: 0.15,
            color: Colors.black,
          ),
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hintText ?? 'Enter text',
            hintStyle: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 20.5 / 18,
              letterSpacing: 0.15,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }
}
