import 'package:flutter/material.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/user_profile/data/services/user_settings_remote_data_source.dart';

const _purple = Color(0xFF6C4EE4);

class UserContactUsScreen extends StatefulWidget {
  const UserContactUsScreen({super.key});

  @override
  State<UserContactUsScreen> createState() => _UserContactUsScreenState();
}

class _UserContactUsScreenState extends State<UserContactUsScreen> {
  final _ds = UserSettingsRemoteDataSource();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final subject = _subjectCtrl.text.trim();
    final message = _messageCtrl.text.trim();
    if (subject.isEmpty) {
      _snack('Please enter a subject');
      return;
    }
    if (message.isEmpty) {
      _snack('Please enter a message');
      return;
    }
    setState(() => _sending = true);
    try {
      await _ds.sendContactMessage(subject, message);
      if (mounted) {
        _snack('Message sent! We\'ll get back to you within 24 hours.');
        _subjectCtrl.clear();
        _messageCtrl.clear();
      }
    } catch (e) {
      _snack(e.toString());
    }
    if (mounted) setState(() => _sending = false);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: InkWell(
              onTap: () => popOrGoHome(context),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFF2F2F2)),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
            ),
          ),
          title: const Text('Contact us',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.email_outlined,
                                color: Colors.black54, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email support',
                                  style: TextStyle(
                                      color: Colors.black45, fontSize: 12)),
                              Text('support@flyapp.in',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Subject',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _subjectCtrl,
                      decoration: InputDecoration(
                        hintText: 'Brief summary of your issue',
                        hintStyle: const TextStyle(
                            color: Colors.black38, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _purple),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Message',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _messageCtrl,
                      maxLines: 5,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText:
                            'Tell us what\'s going on. We are here to help',
                        hintStyle: const TextStyle(
                            color: Colors.black38, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _purple),
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _sending ? null : _send,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    side: const BorderSide(color: _purple),
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: _purple, strokeWidth: 2))
                      : const Text('Send message',
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
