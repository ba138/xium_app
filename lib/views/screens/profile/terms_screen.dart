import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: MyText(
          text: "terms_of_service".tr,
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
              text: "effective_date".tr,
              size: 13,
              color: Colors.grey,
              paddingBottom: 12,
            ),

            _SectionTitle("about_xium_title".tr),
            _BodyText("about_xium_body".tr),

            _SectionTitle("user_eligibility_title".tr),
            _BodyText("user_eligibility_body".tr),

            _SectionTitle("user_data_title".tr),
            _BodyText("user_data_body".tr),

            _SectionTitle("bank_data_title".tr),
            _BodyText("bank_data_body".tr),

            _SectionTitle("email_forwarding_title".tr),
            _BodyText("email_forwarding_body".tr),

            _SectionTitle("classification_title".tr),
            _BodyText("classification_body".tr),

            _SectionTitle("loyalty_title".tr),
            _BodyText("loyalty_body".tr),

            _SectionTitle("data_security_title".tr),
            _BodyText("data_security_body".tr),

            _SectionTitle("prohibited_use_title".tr),
            _BodyText("prohibited_use_body".tr),

            _SectionTitle("disclaimer_title".tr),
            _BodyText("disclaimer_body".tr),

            _SectionTitle("liability_title".tr),
            _BodyText("liability_body".tr),

            _SectionTitle("changes_title".tr),
            _BodyText("changes_body".tr),

            _SectionTitle("contact_title".tr),
            _BodyText("contact_body".tr, paddingBottom: 24),
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
