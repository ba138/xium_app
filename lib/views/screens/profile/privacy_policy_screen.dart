import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: MyText(
          text: "privacy_policy".tr,
          size: 18,
          weight: FontWeight.w600,
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(Icons.arrow_back_ios, color: AppColors.onPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              text: "privacy_effective_date".tr,
              size: 13,
              color: Colors.grey,
              paddingBottom: 12,
            ),

            _SectionTitle("privacy_intro_title".tr),
            _BodyText("privacy_intro_body".tr),

            _SectionTitle("privacy_collect_title".tr),
            _BodyText("privacy_collect_body".tr),

            _SectionTitle("privacy_bank_title".tr),
            _BodyText("privacy_bank_body".tr),

            _SectionTitle("privacy_use_title".tr),
            _BodyText("privacy_use_body".tr),

            _SectionTitle("privacy_email_title".tr),
            _BodyText("privacy_email_body".tr),

            _SectionTitle("privacy_security_title".tr),
            _BodyText("privacy_security_body".tr),

            _SectionTitle("privacy_sharing_title".tr),
            _BodyText("privacy_sharing_body".tr),

            _SectionTitle("privacy_retention_title".tr),
            _BodyText("privacy_retention_body".tr),

            _SectionTitle("privacy_rights_title".tr),
            _BodyText("privacy_rights_body".tr),

            _SectionTitle("privacy_children_title".tr),
            _BodyText("privacy_children_body".tr),

            _SectionTitle("privacy_changes_title".tr),
            _BodyText("privacy_changes_body".tr),

            _SectionTitle("privacy_contact_title".tr),
            _BodyText("privacy_contact_body".tr, paddingBottom: 24),
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
