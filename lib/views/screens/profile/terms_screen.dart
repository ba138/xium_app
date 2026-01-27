import 'package:flutter/material.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const MyText(
          text: "Terms of Service",
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

            _SectionTitle("1. About Xium"),
            _BodyText(
              "Xium is a document classification and management application that helps users organize financial and non-financial documents. The app allows users to connect bank accounts using Plaid, forward invoices via email, upload documents, scan receipts, warranties, and store loyalty card information.",
            ),

            _SectionTitle("2. User Eligibility"),
            _BodyText(
              "You must be at least 18 years old to use Xium. By using the app, you confirm that you meet this requirement.",
            ),

            _SectionTitle("3. User Data & Permissions"),
            _BodyText(
              "Xium may request access to bank data via Plaid, emails you choose to share, and your device camera or gallery for document uploads. You are responsible for ensuring the data you share is accurate and lawful.",
            ),

            _SectionTitle("4. Bank Data & Plaid Integration"),
            _BodyText(
              "Xium uses Plaid to securely connect to your bank accounts. Xium does not store your banking credentials. All bank connections are governed by Plaid’s terms and privacy policies.",
            ),

            _SectionTitle("5. Email Forwarding"),
            _BodyText(
              "When emails are forwarded to Xium, only the email text is processed. Attachments such as PDFs or images may not be accessible due to third-party security restrictions. For best results, users should upload documents directly.",
            ),

            _SectionTitle("6. Document Classification"),
            _BodyText(
              "Xium uses automated and AI-based systems to classify documents. While we strive for accuracy, classification results may not always be correct. Users should verify critical information independently.",
            ),

            _SectionTitle("7. Loyalty Cards & Phone Numbers"),
            _BodyText(
              "If you choose to store loyalty card details or phone numbers, you confirm that the information belongs to you and is stored solely to provide app functionality.",
            ),

            _SectionTitle("8. Data Security"),
            _BodyText(
              "We take reasonable measures to protect your data. However, no system is completely secure, and Xium cannot guarantee absolute data security.",
            ),

            _SectionTitle("9. Prohibited Use"),
            _BodyText(
              "You agree not to misuse the app, upload unauthorized content, or attempt to reverse engineer or disrupt the service.",
            ),

            _SectionTitle("10. Disclaimer"),
            _BodyText(
              "Xium is provided on an “as-is” basis. Xium does not provide financial, legal, or tax advice.",
            ),

            _SectionTitle("11. Limitation of Liability"),
            _BodyText(
              "To the maximum extent permitted by law, Xium shall not be liable for any indirect or consequential damages arising from use of the app.",
            ),

            _SectionTitle("12. Changes to Terms"),
            _BodyText(
              "We may update these Terms from time to time. Continued use of the app indicates acceptance of the updated Terms.",
            ),

            _SectionTitle("13. Contact"),
            _BodyText(
              "If you have any questions about these Terms, please contact us at contact@xium.io",
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
