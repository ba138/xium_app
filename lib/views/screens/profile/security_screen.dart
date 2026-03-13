import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: MyText(text: "security".tr, size: 18, weight: FontWeight.w600),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle("your_data_security".tr),
            _BodyText("your_data_security_desc".tr),

            _SectionTitle("bank_level_security".tr),
            _BodyText("bank_level_security_desc".tr),

            _SectionTitle("encryption".tr),
            _BodyText("encryption_desc".tr),

            _SectionTitle("email_document_protection".tr),
            _BodyText("email_document_protection_desc".tr),

            _SectionTitle("ai_processing".tr),
            _BodyText("ai_processing_desc".tr),

            _SectionTitle("access_controls".tr),
            _BodyText("access_controls_desc".tr),

            _SectionTitle("user_responsibility".tr),
            _BodyText("user_responsibility_desc".tr),

            _SectionTitle("third_party_services".tr),
            _BodyText("third_party_services_desc".tr),

            _SectionTitle("security_updates".tr),
            _BodyText("security_updates_desc".tr),

            _SectionTitle("contact_security".tr),
            _BodyText("contact_security_desc".tr, paddingBottom: 24),
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
