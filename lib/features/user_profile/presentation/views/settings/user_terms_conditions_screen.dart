import 'package:flutter/material.dart';
import 'package:fly/core/utils/safe_navigation.dart';

const _purple = Color(0xFF6C4EE4);

const _sections = [
  'Who we are?',
  'Your anonymous identity',
  'Community guidelines',
  'Payments & refunds',
  'Content & intellectual property',
  'Privacy & data protection',
  'Termination of account',
];

const _flyDescription =
    'Fly is a pseudo-social media platform designed to connect users with curated mental health content and verified Mental Health Professionals — all within a fully anonymous environment.';

class UserTermsConditionsScreen extends StatefulWidget {
  const UserTermsConditionsScreen({super.key});

  @override
  State<UserTermsConditionsScreen> createState() =>
      _UserTermsConditionsScreenState();
}

class _UserTermsConditionsScreenState
    extends State<UserTermsConditionsScreen> {
  int? _expanded;

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
          title: const Text('Terms and Conditions',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ..._sections.asMap().entries.map((e) => _accordionItem(e.key, e.value)),
                    const SizedBox(height: 16),
                    ..._sections.map((s) => _contentBlock(s, _flyDescription)),
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
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    side: const BorderSide(color: _purple),
                  ),
                  child: const Text('I understand and agree',
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

  Widget _accordionItem(int index, String title) {
    final isOpen = _expanded == index;
    return GestureDetector(
      onTap: () => setState(() => _expanded = isOpen ? null : index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 15, color: Colors.black87)),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _contentBlock(String title, String content) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87)),
            const SizedBox(height: 6),
            Text(content,
                style: const TextStyle(
                    color: Colors.black54, fontSize: 13, height: 1.5)),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
          ],
        ),
      );
}
