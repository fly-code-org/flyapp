import 'package:flutter/material.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/legal/legal_constants.dart';
import 'package:fly/features/legal/presentation/widgets/legal_document_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: InkWell(
              onTap: () => popOrGoHome(context),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF2F2F2),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
            ),
          ),
          title: const Text(
            'Privacy Policy',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              legalH1('fly — First Love Yourself'),
              legalP('PRIVACY POLICY'),
              legalP('Effective date: 29 March 2026'),
              legalP('Company name: first love yourself'),
              legalP(
                'Registered address: [To be completed — correspondence: support@flyapp.in]',
              ),
              legalP('Support email: support@flyapp.in'),
              legalP(
                'Community Guidelines form an integral part of this Privacy Policy and are enforceable as platform rules.',
              ),
              legalLinkParagraph(
                context,
                before: '',
                linkText: 'Open Community Guidelines (full document)',
                url: kFlyCommunityGuidelinesUrl,
              ),
              legalH2('1. INTRODUCTION'),
              legalP(
                '[fly] (“Platform”, “We”, “Us”) is committed to protecting your privacy and personal data. This Privacy Policy is published in compliance with:',
              ),
              legalBullets(const [
                'Digital Personal Data Protection Act, 2023 (India)',
                'Information Technology Act, 2000',
                'IT (Intermediary Guidelines & Digital Media Ethics Code) Rules, 2021',
                'Mental Healthcare Act, 2017',
              ]),
              legalP(
                'By using our services, you consent to this Privacy Policy.',
              ),
              legalH2('2. MENTAL HEALTH AND CRISIS DISCLAIMER'),
              legalP(
                'The Platform is not a suicide prevention service or emergency response system. If you are experiencing thoughts of self-harm, suicide, or immediate danger, please contact local emergency services.',
              ),
              legalP(
                'Suicide & crisis helplines (India) — examples (verify locally):',
              ),
              legalBullets(const [
                'Vandrevala Foundation: 1860-2662-345 / 9999666555',
                'iCall (TISS): 9152987821 (Mon–Sat, 8am–10pm)',
                'NIMHANS: 080-46110007',
                'Sneha Foundation (Chennai): 044-24640050',
              ]),
              legalP(
                'Crisis support resources and helpline information may be made available within the Platform for users in distress. We do not guarantee real-time monitoring or emergency intervention.',
              ),
              legalH2('3. INFORMATION WE COLLECT'),
              legalP('A. Personal information'),
              legalP('We collect:'),
              legalBullets(const [
                'Email address (for login and communication)',
                'Age confirmation (18+ for MHP services)',
                'Payment transaction IDs (not full card or UPI details)',
              ]),
              legalP('We do NOT collect:'),
              legalBullets(const [
                'Aadhaar number',
                'PAN',
                'Phone number (unless introduced later)',
                'Biometric data',
              ]),
              legalP('B. Mental health & sensitive data'),
              legalP(
                'We may temporarily process: chat messages; AI chatbot conversations; MHP consultation discussions. These chats are NOT permanently stored. Temporary caching may occur only for platform functionality, safety moderation, and abuse and risk detection.',
              ),
              legalP('C. Automated data'),
              legalP('We may collect:'),
              legalBullets(const [
                'IP address',
                'Device information',
                'App usage data',
                'Crash and error diagnostics',
              ]),
              legalH2('4. EXPLICIT CONSENT FOR SENSITIVE PERSONAL DATA'),
              legalP(
                'By creating an account and using the Platform, you provide explicit, informed consent for the collection, processing, and temporary storage of sensitive personal data related to mental health, including chat messages, AI chatbot conversations, and Mental Health Professional consultations, solely for the purposes described in this Privacy Policy.',
              ),
              legalP(
                'You may withdraw your consent at any time by deleting your account or contacting us at support@flyapp.in. Withdrawal of consent may result in limited or discontinued access to certain services.',
              ),
              legalH2('5. PURPOSE OF DATA COLLECTION'),
              legalP('Your data is used strictly for:'),
              legalBullets(const [
                'Account creation and authentication',
                'AI chatbot functionality',
                'Community moderation',
                'Connecting you with Mental Health Professionals (MHPs)',
                'Payment processing',
                'Abuse prevention',
                'Legal compliance',
                'Crisis risk monitoring',
              ]),
              legalH2('6. LEGAL AND ACCEPTABLE USE'),
              legalP(
                'Users agree to use the Platform only for lawful purposes and in accordance with applicable Indian laws. Users must not:',
              ),
              legalBullets(const [
                'Post or transmit content that is abusive, threatening, hateful, or unlawful',
                'Encourage self-harm, suicide, violence, or illegal activities',
                'Misrepresent identity or impersonate another person',
                'Use AI responses as a substitute for professional medical advice',
                'Attempt to reverse engineer or misuse AI systems',
              ]),
              legalP(
                'Violation may result in suspension or termination of access.',
              ),
              legalH2('7. AI & AUTOMATED PROCESSING DISCLOSURE'),
              legalP(
                'AI processes user input to generate general mental health information. The AI chatbot is NOT a doctor, psychiatrist, or therapist. It does NOT provide medical diagnosis or prescriptions. AI responses may be inaccurate or incomplete. Users interact with AI at their own discretion and risk. AI outputs are generated using probabilistic models and may vary between users. We do not guarantee accuracy, completeness, or suitability for any individual condition. Users must independently evaluate AI-generated information.',
              ),
              legalP('7a. Crisis detection & intervention transparency'),
              legalP(
                'The Platform may use automated systems to detect potential self-harm or abuse signals. Such systems are not foolproof and may miss genuine crises or flag non-risk content. We do not guarantee intervention, emergency response, or outreach in all cases.',
              ),
              legalH2('8. PAYMENT & FINANCIAL DATA'),
              legalP(
                'All payments are processed through RBI-compliant third-party payment gateways. We do NOT store card numbers, CVV, net banking details, or UPI PIN. We only retain transaction ID, time and date, and payment status.',
              ),
              legalH2('9. DATA SHARING & DISCLOSURE'),
              legalP('We may share limited data with:'),
              legalBullets(const [
                'Government authorities when legally required',
                'Payment gateway providers',
                'Law enforcement agencies (in cases of self-harm risk, cybercrime, or abuse)',
                'Hosting and analytics providers compliant with Indian data laws',
              ]),
              legalP('We NEVER sell your personal data.'),
              legalH2('10. ANONYMITY & TRACEABILITY'),
              legalP(
                'Users remain anonymous to other users on the platform. However, email address, IP address, and device data may be disclosed to Indian government authorities under lawful orders.',
              ),
              legalH2('11. DATA RETENTION POLICY'),
              legalBullets(const [
                'Email address: stored until account deletion',
                'Payment records: retained as per RBI and taxation laws',
                'Chat messages: not permanently stored',
                'Abuse or safety reports: retained up to 180 days',
              ]),
              legalH2('12. USER RIGHTS (DPDP ACT, 2023)'),
              legalP('You have the right to:'),
              legalBullets(const [
                'Access your personal data',
                'Correct inaccurate data',
                'Delete your account',
                'Withdraw consent',
                'File a grievance',
              ]),
              legalP('Requests can be sent to: support@flyapp.in'),
              legalH2('13. CHILD & MINOR PROTECTION'),
              legalP(
                'Users below 18 years cannot access Mental Health Professional services. We do not knowingly collect personal data from children without parental consent.',
              ),
              legalH2('14. CYBER SECURITY PRACTICES'),
              legalP('We follow industry-standard security measures including:'),
              legalBullets(const [
                'Encrypted data storage',
                'Secure servers',
                'Role-based access controls',
                'Regular system audits',
              ]),
              legalP('However, no digital system is completely secure.'),
              legalH2('15. DATA BREACH NOTIFICATION'),
              legalP(
                'In the event of a data breach: users will be notified within the legally prescribed period; authorities such as the Data Protection Board of India will be informed where required.',
              ),
              legalH2('16. THIRD-PARTY LINKS'),
              legalP(
                'The platform may contain links to crisis helplines, payment gateways, and external information sources. We are not responsible for their privacy practices or content.',
              ),
              legalH2('17. TERMINATION, SUSPENSION & ACCOUNT DELETION'),
              legalP(
                'We reserve the right to suspend or terminate accounts without prior notice if there is violation of platform rules, credible risk of harm, or where required by law or court order.',
              ),
              legalP(
                'Users may delete their account at any time through app settings or by email request to support@flyapp.in. Upon deletion: email data will be erased within legally mandated timelines; financial transaction records will be retained only as required by law.',
              ),
              legalH2('18. UPDATES TO THIS POLICY'),
              legalP(
                'We may update this Privacy Policy periodically. Continued use of the platform after updates implies acceptance of the revised policy.',
              ),
              legalH2('19. PROHIBITED BEHAVIORS'),
              legalP(
                'Prohibited behaviours include, without limitation, those described in Section 6, Section 20, and the Community Guidelines linked above.',
              ),
              legalH2('20. USER GENERATED CONTENT'),
              legalP(
                'Users retain ownership of content they submit. By submitting content, users grant the Platform a limited, non-exclusive licence to use, process, and display such content for platform functionality, safety moderation, and legal compliance. We reserve the right to remove content that violates this Policy or applicable laws.',
              ),
              legalH2('21. LIMITATION OF LIABILITY'),
              legalP(
                'To the maximum extent permitted by law, the Platform shall not be liable for: emotional distress arising from AI interactions; decisions taken based on platform content; losses due to reliance on non-professional advice; service interruptions or technical failures. Our total liability shall not exceed the amount paid by the user (if any) in the preceding 6 months.',
              ),
              legalH2('22. INDEMNIFICATION'),
              legalP(
                'Users agree to indemnify and hold harmless the Company from any claims, damages, or legal actions arising from: user content; violation of this Policy; or misuse of the Platform.',
              ),
              legalH2('23. INTELLECTUAL PROPERTY RIGHTS'),
              legalP(
                'All platform content, branding, design, and AI systems are the intellectual property of the Company. Unauthorized copying, redistribution, or commercial use is prohibited.',
              ),
              legalH2('24. GRIEVANCE OFFICER (MANDATORY UNDER IT RULES 2021)'),
              legalP('Name: [Grievance Officer — to be updated]'),
              legalP('Email: grievance@flyapp.in'),
              legalP(
                'Address: [Full registered Indian address — to be updated]',
              ),
              legalP('Response time: 24–72 working hours.'),
              legalP(
                'If grievances are not resolved, users may escalate to the Data Protection Board of India in accordance with DPDP Act procedures.',
              ),
              legalH2('25. GOVERNING LAW'),
              legalP(
                'This Privacy Policy is governed by the laws of India. Jurisdiction: courts of [City, State], India — [to be completed].',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
