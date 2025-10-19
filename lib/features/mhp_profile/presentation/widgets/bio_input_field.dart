import 'package:flutter/material.dart';

class BioInputField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? hintText;

  const BioInputField({
    super.key,
    required this.onChanged,
    this.hintText,
  });

  @override
  State<BioInputField> createState() => _BioInputFieldState();
}

class _BioInputFieldState extends State<BioInputField> {
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
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: _isFocused ? const Color.fromARGB(255, 134, 78, 190) : Colors.grey,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        focusNode: _focusNode,
        maxLines: 5,
        minLines: 3,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(
          fontFamily: 'Lexend',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.15,
          color: Colors.black,
        ),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hintText ?? 'Write a short bio...',
          hintStyle: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
            letterSpacing: 0.15,
            color: Colors.grey.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
