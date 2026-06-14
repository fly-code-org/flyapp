import 'package:flutter/material.dart';
import 'package:fly/core/utils/safe_navigation.dart';

const _purple = Color(0xFF6C4EE4);

class MhpContactUsScreen extends StatelessWidget {
  const MhpContactUsScreen({super.key});

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
          title: const Text('Contact Us',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('We\'re here to help',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              const Text(
                'Reach out to us through any of the channels below and our team will get back to you within 24 hours.',
                style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              _contactCard(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'support@flymentalhealth.com',
                detail: 'Available Mon – Fri, 9AM – 6PM IST',
              ),
              const SizedBox(height: 16),
              _contactCard(
                icon: Icons.chat_bubble_outline,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                detail: 'Response time: under 2 hours',
              ),
              const SizedBox(height: 16),
              _contactCard(
                icon: Icons.phone_outlined,
                title: 'Phone Support',
                subtitle: '+91 98765 43210',
                detail: 'Available Mon – Fri, 10AM – 5PM IST',
              ),
              const SizedBox(height: 32),
              const Text('Frequently Asked Questions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _faqItem('How do I update my availability?',
                  'Go to Settings → Profile & Credentials → Availability Schedule.'),
              _faqItem('When will I receive my payout?',
                  'Payouts are processed within 3–5 business days after each session.'),
              _faqItem('How do I change my session fees?',
                  'Go to Settings → Payments & Billing → Set Consultation Fees.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _purple, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: _purple, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(detail,
                    style: const TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(answer,
              style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}
