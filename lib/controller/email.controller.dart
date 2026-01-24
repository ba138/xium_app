import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class MailController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  var forwardingEmail = ''.obs;
  var isLoading = false.obs;

  /// 🔹 Load forwarding email
  Future<void> loadForwardingEmail() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _db.collection("users").doc(uid).get();
    if (!doc.exists) return;

    forwardingEmail.value = doc.data()?['forwardingEmail'] ?? '';
  }

  /// 🔹 Create forwarding email if missing
  Future<void> createForwardingEmailIfNeeded() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    if (forwardingEmail.value.isNotEmpty) return;

    final email = "$uid@mg.xium.io";

    await _db.collection("users").doc(uid).update({"forwardingEmail": email});

    forwardingEmail.value = email;
  }

  /// 🔹 Main entry from UI
  Future<void> handleEmailSetup(BuildContext context) async {
    isLoading.value = true;
    await loadForwardingEmail();
    await createForwardingEmailIfNeeded();
    isLoading.value = false;

    _showForwardingDialog(context);
  }

  /// 🔹 Dialog UI
  void _showForwardingDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff0A0D2E), // dark card over #040615
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// TITLE
                MyText(
                  text: "Email Scanning",
                  size: 18,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),

                const SizedBox(height: 10),

                /// DESCRIPTION
                MyText(
                  text:
                      "To automatically classify your documents, forward your emails to this address:",
                  size: 13,
                  color: Colors.white70,
                ),

                const SizedBox(height: 14),

                /// FORWARDING EMAIL BOX
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff040615), // app background
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          forwardingEmail.value,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          size: 18,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: forwardingEmail.value),
                          );
                          Get.snackbar(
                            "Copied",
                            "Forwarding email copied",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                MyText(
                  text:
                      "Note: When signing up with Apple, a private relay email may be used. To avoid missing emails, please check your email in Settings and update it to your Gmail address if a private email is selected.",
                  size: 14,
                  weight: FontWeight.w600,
                  color: Colors.red,
                ),

                /// HOW IT WORKS
                MyText(
                  text: "How it works",
                  size: 14,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),

                const SizedBox(height: 8),

                MyText(
                  text:
                      "1. Open any receipt or invoice email\n"
                      "2. Tap Forward\n"
                      "3. Paste the XIUM email above\n"
                      "4. Send the email",
                  size: 13,
                  color: Colors.white70,
                ),

                const SizedBox(height: 14),

                MyText(
                  text:
                      "XIUM will automatically detect and organize:\n"
                      "• Receipts\n"
                      "• Invoices\n"
                      "• Warranties\n\n"
                      "No setup or verification required.",
                  size: 13,
                  color: Colors.white60,
                ),

                const SizedBox(height: 20),

                /// DONE BUTTON
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Done",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
