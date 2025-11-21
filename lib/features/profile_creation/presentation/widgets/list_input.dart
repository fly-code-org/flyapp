import 'package:flutter/material.dart';

class ListInputWidget extends StatefulWidget {
  final String title;
  final String hintText;
  final ValueChanged<List<String>>? onLanguagesChanged;

  const ListInputWidget({
    super.key,
    required this.title,
    required this.hintText,
    this.onLanguagesChanged,
  });

  @override
  State<ListInputWidget> createState() => _ListInputWidgetState();
}

class _ListInputWidgetState extends State<ListInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _languages = [];

  void _handleInput(String value) {
    if (value.endsWith(" ")) {
      String trimmed = value.trim();
      if (trimmed.isNotEmpty && !_languages.contains(trimmed)) {
        setState(() {
          _languages.add(trimmed);
        });
        widget.onLanguagesChanged?.call(_languages);
      }
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Dynamic Title
        Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Colors.black,
          ),
        ),

        /// Chips List
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _languages.map((lang) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(width: 2, color: Colors.transparent),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF9C27B0),
                    Color(0xFFE91E63),
                  ], // Purple → Pink
                ),
              ),
              child: Text(
                lang,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        /// Input Box
        Container(
          width: double.infinity,
          height: 57,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.5),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _controller,
              onChanged: _handleInput,
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
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
