import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      AlertDialog(
        title: const Text("Email Scanning"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "To automatically classify your documents, forward your emails to this address:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              /// Forwarding Email Box
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        forwardingEmail.value,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
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

              const SizedBox(height: 16),
              const Text(
                "How it works",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              const Text(
                "1. Open any receipt or invoice email\n"
                "2. Tap Forward\n"
                "3. Paste the XIUM email above\n"
                "4. Send the email\n",
                style: TextStyle(fontSize: 13),
              ),

              const SizedBox(height: 12),
              const Text(
                "XIUM will automatically detect and organize:\n"
                "• Receipts\n"
                "• Invoices\n"
                "• Warranties\n"
                "\nNo setup or verification required.",
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Done")),
        ],
      ),
    );
  }
}
