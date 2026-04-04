import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const kLegalBodyStyle = TextStyle(
  fontSize: 15,
  height: 1.5,
  color: Color(0xFF333333),
);

const kLegalCaptionStyle = TextStyle(
  fontSize: 13,
  height: 1.45,
  color: Color(0xFF666666),
);

Widget legalH1(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );

Widget legalH2(String text) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );

Widget legalP(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: kLegalBodyStyle),
    );

Widget legalBullets(List<String> lines) => Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  ', style: kLegalBodyStyle),
                Expanded(child: Text(e, style: kLegalBodyStyle)),
              ],
            ),
          );
        }).toList(),
      ),
    );

Future<bool> openExternalUrl(Uri uri) async {
  if (!await canLaunchUrl(uri)) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

Widget legalLinkParagraph(
  BuildContext context, {
  required String before,
  required String linkText,
  required String url,
  String after = '',
}) {
  final uri = Uri.tryParse(url);
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text.rich(
      TextSpan(
        style: kLegalBodyStyle,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: linkText,
            style: const TextStyle(
              color: Color(0xFF3B16A7),
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                if (uri == null) return;
                final ok = await openExternalUrl(uri);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open:\n$url')),
                  );
                }
              },
          ),
          TextSpan(text: after),
        ],
      ),
    ),
  );
}
