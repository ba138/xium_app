import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class TinkController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var transactions = [].obs;

  /// 🔹 Updated backend URLs
  static const String _createSessionUrl =
      "https://us-central1-xium-app.cloudfunctions.net/getTinkLinkUrl";

  static const String _exchangeTokenUrl =
      "https://exchangetinktoken-cldvdnjjnq-uc.a.run.app";

  static const String _syncTransactionsUrl =
      "https://us-central1-xium-app.cloudfunctions.net/syncTinkTransactions";

  @override
  void onInit() {
    super.onInit();
    _autoSyncTransactions();
  }

  Future<void> _autoSyncTransactions() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final isConnected = await _isBankConnected();
      if (!isConnected) return;

      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500));
      // await openTinkLink();
    } catch (e) {
      debugPrint("Auto sync error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Create Tink session URL
  Future<String> createTinkSession() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final response = await http
        .post(
          Uri.parse(_createSessionUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"uid": uid}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to create Tink session: ${response.statusCode} ${response.body}",
      );
    }

    final data = jsonDecode(response.body);

    // Use tink_url instead of authorization_url
    final url = data["tink_url"];
    if (url == null || url.isEmpty) {
      throw Exception("Backend did not return a Tink URL: ${response.body}");
    }

    return url;
  }

  /// 🔹 Open Tink link flow
  Future<void> openTinkLink() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      isLoading.value = true;

      final authUrl = await createTinkSession();

      /// Launch Tink web auth
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: "yourapp", // must match backend redirect_uri
      );

      final uri = Uri.tryParse(result);
      if (uri == null) throw Exception("Invalid redirect URI");

      final code = uri.queryParameters['code'];
      if (code == null) throw Exception("No code returned from Tink flow");

      await exchangeToken(code);
    } catch (e) {
      Get.snackbar("Tink Error", e.toString());
      debugPrint("Tink error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Exchange code for user access token
  Future<void> exchangeToken(String code) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final response = await http
          .post(
            Uri.parse(_exchangeTokenUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"uid": uid, "code": code}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          "Failed to exchange Tink code: ${response.statusCode} ${response.body}",
        );
      }

      // Sync transactions after exchanging token
      await syncTransactions();
    } catch (e) {
      debugPrint("Exchange token error: $e");
      Get.snackbar("Tink Token Error", e.toString());
    }
  }

  /// 🔹 Sync transactions
  /// 🔹 Sync Transactions using UID and Firestore-stored token
  Future<void> syncTransactions({String? uid}) async {
    final userId = uid ?? _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      isLoading.value = true;

      // Get token from Firestore
      final tokenSnap = await FirebaseFirestore.instance
          .collection("tinkTokens")
          .doc(userId)
          .get();

      if (!tokenSnap.exists) {
        debugPrint("No Tink token found for user $userId");
        return;
      }

      final accessToken = tokenSnap.data()?['accessToken'];
      if (accessToken == null) {
        debugPrint("Access token is null for user $userId");
        return;
      }

      // Call your backend to sync transactions
      final response = await http
          .post(
            Uri.parse(_syncTransactionsUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"uid": userId, "accessToken": accessToken}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Synced transactions: ${data['synced']}");
      } else {
        debugPrint(
          "Failed to sync transactions: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("Sync transactions error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Check Firestore if bank is connected
  Future<bool> _isBankConnected() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final snap = await _firestore.collection("users").doc(uid).get();
    if (!snap.exists) return false;

    final source = snap.data()?['source'] as Map<String, dynamic>?;
    return source?['bank'] == "connected";
  }
}
