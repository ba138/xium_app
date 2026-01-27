import 'package:flutter/material.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const MyText(
          text: "Security",
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
            _SectionTitle("Your Data Security"),
            _BodyText(
              "At Xium, security is a top priority. We use industry-standard practices to protect your data and ensure your information is handled securely.",
            ),

            _SectionTitle("Bank-Level Security"),
            _BodyText(
              "Xium uses Plaid to connect to your bank accounts. Your banking credentials are never stored or visible to Xium. All connections are encrypted and handled directly by Plaid.",
            ),

            _SectionTitle("Encryption"),
            _BodyText(
              "Data transmitted between your device and our servers is encrypted using secure communication protocols. Stored data is protected using appropriate encryption and access controls.",
            ),

            _SectionTitle("Email & Document Protection"),
            _BodyText(
              "Only the content you explicitly share with Xium is processed. Email attachments may be restricted by third-party providers. Uploaded documents and images are processed securely and stored safely.",
            ),

            _SectionTitle("AI & Automated Processing"),
            _BodyText(
              "Xium uses automated systems to classify documents. These systems operate in secure environments and are designed to minimize access to sensitive information.",
            ),

            _SectionTitle("Access Controls"),
            _BodyText(
              "Access to user data is restricted to authorized systems and personnel only, following the principle of least privilege.",
            ),

            _SectionTitle("User Responsibility"),
            _BodyText(
              "You are responsible for maintaining the security of your account, including protecting your device and login credentials.",
            ),

            _SectionTitle("Third-Party Services"),
            _BodyText(
              "Xium works with trusted third-party services such as Plaid and email providers. Each service follows its own security and compliance standards.",
            ),

            _SectionTitle("Security Updates"),
            _BodyText(
              "We continuously review and improve our security measures to address new threats and vulnerabilities.",
            ),

            _SectionTitle("Contact"),
            _BodyText(
              "If you believe your account has been compromised or have security concerns, please contact us immediately at contact@xium.io",
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
