import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnterOtpWidget extends StatefulWidget {
  final Function(String)? onOtpChanged;
  final int length;

  const EnterOtpWidget({
    super.key,
    this.onOtpChanged,
    this.length = 6,
  });

  @override
  State<EnterOtpWidget> createState() => _EnterOtpWidgetState();
}

class _EnterOtpWidgetState extends State<EnterOtpWidget> {
  late final List<FocusNode> _focusNodes;
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _controllers = List.generate(widget.length, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String get otp {
    return _controllers.map((controller) => controller.text).join();
  }

  void _notifyOtpChanged() {
    if (widget.onOtpChanged != null) {
      widget.onOtpChanged!(otp);
    }
  }

  void _handlePaste(String pastedText) {
    final digits = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
    for (int i = 0; i < widget.length && i < digits.length; i++) {
      _controllers[i].text = digits[i];
    }
    if (digits.length >= widget.length) {
      _focusNodes.last.requestFocus();
    } else if (digits.isNotEmpty) {
      _focusNodes[digits.length.clamp(0, widget.length - 1)].requestFocus();
    }
    _notifyOtpChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter OTP",
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.length, (index) {
            return SizedBox(
              width: 45,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                maxLength: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  counterText: "",
                  contentPadding: const EdgeInsets.all(12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF7A5AF8),
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.length > 1) {
                    _handlePaste(value);
                    return;
                  }
                  if (value.isNotEmpty && index < widget.length - 1) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                  _notifyOtpChanged();
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
