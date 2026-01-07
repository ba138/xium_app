import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';

import 'package:xium_app/model/document_model.dart';
import 'package:xium_app/views/screens/home/widgets/add_expanses_screen.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class DocViewScreen extends StatelessWidget {
  final DocumentModel document;
  final String? storeName;
  final String? storeLogo;
  final int? documentCount;
  const DocViewScreen({
    super.key,
    required this.document,
    this.storeName,
    this.storeLogo,
    this.documentCount,
  });

  @override
  Widget build(BuildContext context) {
    final isBank = document.source == "bank";
    String formatDate(DateTime? date) {
      if (date == null) return "N/A";
      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}";
    }

    String formatAmount(double? amount, String? currency) {
      if (amount == null) return "N/A";
      return "${currency ?? ''} ${amount.toStringAsFixed(2)}";
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔙 HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: Get.back,
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MyText(
                          text: "${document.documentType ?? "Document"} ",
                          size: 16,
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                    document.amount != null
                        ? const SizedBox.shrink()
                        : MyText(
                            text: "+ More",
                            size: 14,
                            onTap: () => Get.to(
                              () => AddExpenseScreen(
                                docId: document.id!,
                                storeName: storeName,
                                storeLogo: storeLogo,
                                documentCount: documentCount,
                              ),
                            ),
                          ),
                  ],
                ),

                const SizedBox(height: 24),

                /// 🖼️ STORE LOGO / IMAGE
                Center(
                  child: CommonImageView(
                    url:
                        document.storeLogo ??
                        "https://c8.alamy.com/comp/P2D424/store-vector-icon-isolated-on-transparent-background-store-logo-concept-P2D424.jpg",
                    height: 80,
                  ),
                ),

                const SizedBox(height: 30),

                /// 📧 EMAIL DOCUMENT
                if (!isBank) ...[
                  docTile(
                    title: "Document Type",
                    subTitle: document.documentType ?? "N/A",
                  ),
                  docTile(
                    title: "Store",
                    subTitle: document.storeName ?? "N/A",
                  ),
                  docTile(
                    title: "Amount",
                    subTitle: formatAmount(document.amount, document.currency),
                  ),
                  docTile(
                    title: "Date",
                    subTitle: formatDate(document.createdAt?.toDate()),
                  ),
                  docTile(title: "Source", subTitle: "Email"),
                  docTile(
                    title: "Subject",
                    subTitle: document.subject ?? "N/A",
                  ),
                ],

                /// 🏦 BANK DOCUMENT
                if (isBank) ...[
                  docTile(
                    title: "Merchant",
                    subTitle: document.storeName ?? "N/A",
                  ),
                  docTile(
                    title: "Amount",
                    subTitle: formatAmount(document.amount, document.currency),
                  ),
                  docTile(
                    title: "Category",
                    subTitle: document.documentType ?? "N/A",
                  ),
                  docTile(title: "Date", subTitle: document.date ?? "N/A"),
                  docTile(title: "Source", subTitle: "Bank"),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 BEAUTIFUL TILE
  Widget docTile({required String title, required String subTitle}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(text: title, size: 12, color: Colors.grey),
                  const SizedBox(height: 4),
                  MyText(
                    text: subTitle,
                    size: 16,
                    weight: FontWeight.w600,
                    textOverflow: TextOverflow.visible,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(thickness: 0.6),
        const SizedBox(height: 6),
      ],
    );
  }
}
