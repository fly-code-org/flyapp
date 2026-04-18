import 'package:flutter/material.dart';
import 'package:fly/core/utils/app_logout.dart';
import 'package:fly/features/legal/legal_url_launcher.dart';
import 'package:fly/features/legal/legal_urls.dart';

/// Handles taps on shared Settings list items (user + MHP).
void handleSettingsOptionTap(BuildContext context, String option) {
  switch (option) {
    case 'Logout':
      confirmAndLogout(context);
      return;
    case 'Community Guidelines':
      launchLegalUrl(context, LegalUrls.communityGuidelines);
      return;
    case 'Privacy Policy':
      launchLegalUrl(context, LegalUrls.privacyPolicy);
      return;
    case 'Terms & Conditions':
      launchLegalUrl(context, LegalUrls.termsAndConditions);
      return;
    default:
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Coming soon: $option')),
        );
      }
  }
}
