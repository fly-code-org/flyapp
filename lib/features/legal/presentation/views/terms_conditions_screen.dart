import 'package:flutter/material.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/legal/legal_constants.dart';
import 'package:fly/features/legal/presentation/widgets/legal_document_widgets.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
            'Terms & Conditions',
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
              legalP('TERMS & CONDITIONS'),
              legalP('Effective date: 29 March 2026'),
              legalP('Company: first love yourself (“Company”, “We”, “Us”).'),
              legalP(
                'These Terms & Conditions (“Terms”) govern your access to and use of the fly mobile application and related services (the “Platform”). The Privacy Policy and Community Guidelines are incorporated by reference.',
              ),
              legalLinkParagraph(
                context,
                before: 'Community Guidelines: ',
                linkText: 'open document',
                url: kFlyCommunityGuidelinesUrl,
              ),
              legalH2('1. ACCEPTANCE'),
              legalP(
                'By creating an account or using the Platform, you agree to these Terms. If you do not agree, do not use the Platform.',
              ),
              legalH2('2. ELIGIBILITY & ACCOUNTS'),
              legalBullets(const [
                'You must provide accurate registration information.',
                'MHP-related services require users to be 18+ where stated in product flows or policy.',
                'You are responsible for safeguarding your credentials and for activity under your account.',
              ]),
              legalH2('3. NATURE OF SERVICES'),
              legalP(
                'The Platform provides informational tools, community features, AI-assisted chat for general wellness information, and optional connections with independent Mental Health Professionals (MHPs). The Platform does not provide emergency services.',
              ),
              legalH2('4. NOT MEDICAL ADVICE'),
              legalP(
                'Nothing on the Platform is a substitute for professional medical advice, diagnosis, or treatment. AI output is probabilistic and may be wrong or incomplete. Always seek qualified professionals for clinical decisions.',
              ),
              legalH2('5. MHP RELATIONSHIP'),
              legalP(
                'MHPs using the Platform are independent professionals. Your therapeutic or professional relationship is between you and the MHP. We do not control clinical judgement, fees beyond our payment flows, or outcomes of sessions.',
              ),
              legalH2('6. ACCEPTABLE USE'),
              legalP(
                'You will comply with applicable Indian law and our Privacy Policy and Community Guidelines. You must not harass others, share illegal content, misuse payments, scrape or attack the Platform, or circumvent safety features.',
              ),
              legalH2('7. PAYMENTS'),
              legalP(
                'Payments are processed by third-party gateways. You authorise us and our providers to charge amounts you confirm in-app. Refunds, if any, follow gateway and Platform rules displayed at checkout.',
              ),
              legalH2('8. INTELLECTUAL PROPERTY'),
              legalP(
                'The Platform, branding, and software are owned by the Company or its licensors. You receive a limited, revocable licence to use the app for personal, non-commercial use in line with these Terms.',
              ),
              legalH2('9. USER CONTENT & LICENCE'),
              legalP(
                'You retain rights in content you submit. You grant the Company a worldwide, non-exclusive licence to host, process, display, and moderate such content to operate and protect the Platform.',
              ),
              legalH2('10. SUSPENSION & TERMINATION'),
              legalP(
                'We may suspend or terminate access for breach of Terms, risk of harm, legal requirement, or operational reasons. You may stop using the Platform or request account deletion as described in the Privacy Policy.',
              ),
              legalH2('11. DISCLAIMERS'),
              legalP(
                'The Platform is provided on an “as is” and “as available” basis to the fullest extent permitted by law. We disclaim warranties not expressly stated here.',
              ),
              legalH2('12. LIMITATION OF LIABILITY'),
              legalP(
                'To the maximum extent permitted by law, we are not liable for indirect or consequential losses, or for losses from reliance on AI or user-generated content. Where liability cannot be excluded, our aggregate liability is limited to the fees you paid to us in the six months before the claim (if any).',
              ),
              legalH2('13. INDEMNITY'),
              legalP(
                'You will indemnify and hold harmless the Company against claims arising from your content, your breach of these Terms, or your misuse of the Platform, except where prohibited by law.',
              ),
              legalH2('14. GOVERNING LAW & DISPUTES'),
              legalP(
                'These Terms are governed by the laws of India. Courts at [City, State], India shall have jurisdiction — [to be completed].',
              ),
              legalH2('15. CONTACT'),
              legalP('Support: support@flyapp.in'),
              legalP('Grievance officer: grievance@flyapp.in'),
              legalP(
                'For the full Privacy Policy as referenced above, open from Settings or below.',
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.privacyPolicy),
                  child: const Text('View Privacy Policy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
