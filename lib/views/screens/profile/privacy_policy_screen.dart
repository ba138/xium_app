import 'package:flutter/material.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const MyText(
          text: "Privacy Policy",
          size: 18,
          weight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            MyText(
              text: "Effective Date: 01 January 2026",
              size: 13,
              color: Colors.grey,
              paddingBottom: 12,
            ),

            _SectionTitle("1. Introduction"),
            _BodyText(
              "Xium values your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use the Xium mobile application.",
            ),

            _SectionTitle("2. Information We Collect"),
            _BodyText(
              "Xium may collect the following types of information:\n"
              "• Bank-related data via Plaid (with your consent)\n"
              "• Emails and document content you choose to share\n"
              "• Uploaded images, PDFs, invoices, receipts, and warranties\n"
              "• Loyalty card details and phone numbers\n"
              "• Basic app usage and diagnostic data",
            ),

            _SectionTitle("3. Bank Data & Plaid"),
            _BodyText(
              "Xium uses Plaid to securely connect to your bank accounts. We do not store your banking login credentials. All bank data access is handled according to Plaid’s security standards and privacy policies.",
            ),

            _SectionTitle("4. How We Use Your Information"),
            _BodyText(
              "Your information is used solely to:\n"
              "• Classify and organize documents\n"
              "• Display transactions and records\n"
              "• Improve app functionality and reliability\n"
              "• Provide customer support",
            ),

            _SectionTitle("5. Email Forwarding & Attachments"),
            _BodyText(
              "When you forward emails to Xium, only the content you share is processed. Attachments may not always be accessible due to third-party security restrictions. For best results, documents should be uploaded directly using the camera or file picker.",
            ),

            _SectionTitle("6. Data Storage & Security"),
            _BodyText(
              "We apply reasonable technical and organizational measures to protect your data. However, no digital system can be guaranteed to be completely secure.",
            ),

            _SectionTitle("7. Data Sharing"),
            _BodyText(
              "Xium does not sell or rent your personal data. Your data is shared only with trusted services (such as Plaid) when required to provide app functionality or comply with legal obligations.",
            ),

            _SectionTitle("8. Data Retention"),
            _BodyText(
              "We retain your data for as long as your account is active or as needed to provide the Service. You may request deletion of your data by contacting support.",
            ),

            _SectionTitle("9. Your Rights"),
            _BodyText(
              "You have the right to access, update, or delete your personal data. You may manage most of your data directly within the app settings.",
            ),

            _SectionTitle("10. Children’s Privacy"),
            _BodyText(
              "Xium is not intended for users under the age of 18. We do not knowingly collect data from children.",
            ),

            _SectionTitle("11. Changes to This Policy"),
            _BodyText(
              "We may update this Privacy Policy from time to time. Continued use of the app indicates acceptance of the updated policy.",
            ),

            _SectionTitle("12. Contact Us"),
            _BodyText(
              "If you have questions or concerns about this Privacy Policy, please contact us at contact@xium.io",
              paddingBottom: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return MyText(
      text: text,
      size: 16,
      weight: FontWeight.w600,
      paddingTop: 16,
      paddingBottom: 6,
      color: AppColors.primary,
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  final double paddingBottom;

  const _BodyText(this.text, {this.paddingBottom = 12});

  @override
  Widget build(BuildContext context) {
    return MyText(
      text: text,
      size: 14,
      lineHeight: 1.5,
      color: AppColors.onPrimary,
      paddingBottom: paddingBottom,
    );
  }
}
