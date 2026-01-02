import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plaid_flutter/plaid_flutter.dart';

class PlaidController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Loading state
  var isLoading = false.obs;

  /// Transactions
  var transactions = [].obs;

  /// Plaid configuration
  LinkTokenConfiguration? _configuration;

  /// Stream subscriptions
  StreamSubscription<LinkSuccess>? _successSub;
  StreamSubscription<LinkExit>? _exitSub;
  StreamSubscription<LinkEvent>? _eventSub;

  /// 🔹 Cloud Function URLs
  static const String _createLinkTokenUrl =
      "https://us-central1-xium-app.cloudfunctions.net/createPlaidLinkToken";

  static const String _exchangeTokenUrl =
      "https://us-central1-xium-app.cloudfunctions.net/exchangePlaidToken";

  static const String _syncTransactionsUrl =
      "https://us-central1-xium-app.cloudfunctions.net/syncTransactions";

  @override
  void onInit() {
    super.onInit();

    _successSub = PlaidLink.onSuccess.listen(_onSuccess);
    _exitSub = PlaidLink.onExit.listen(_onExit);
    _eventSub = PlaidLink.onEvent.listen(_onEvent);
  }

  @override
  void onClose() {
    _successSub?.cancel();
    _exitSub?.cancel();
    _eventSub?.cancel();
    super.onClose();
  }

  /// 🔹 Create Link Token from backend
  Future<String> createLinkToken() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final response = await http.post(
      Uri.parse(_createLinkTokenUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"uid": uid}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create link token");
    }

    final data = jsonDecode(response.body);
    return data["link_token"];
  }

  /// 🔹 Create configuration + open Plaid
  Future<void> openPlaidLink() async {
    try {
      isLoading.value = true;

      final isConnected = await _isBankConnected();

      if (isConnected) {
        isLoading.value = false;
        Get.snackbar(
          "Bank Already Connected",
          "Your bank account is already linked.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final linkToken = await createLinkToken();
      final configuration = LinkTokenConfiguration(token: linkToken);

      await PlaidLink.create(configuration: configuration);
      await PlaidLink.open();
    } catch (e) {
      Get.snackbar("Plaid Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 On Success
  Future<void> _onSuccess(LinkSuccess success) async {
    final publicToken = success.publicToken;
    await exchangePublicToken(publicToken);
  }

  /// 🔹 On Exit
  void _onExit(LinkExit event) {
    isLoading.value = false;
  }

  /// 🔹 On Event (optional logging)
  void _onEvent(LinkEvent event) {
    print("Plaid Event: ${event.name}");
  }

  /// 🔹 Exchange Public Token
  Future<void> exchangePublicToken(String publicToken) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await http.post(
      Uri.parse(_exchangeTokenUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"uid": uid, "publicToken": publicToken}),
    );

    await syncTransactions();
  }

  /// 🔹 Sync Transactions
  Future<void> syncTransactions() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final response = await http.post(
      Uri.parse(_syncTransactionsUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"uid": uid}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Synced transactions: ${data['synced']}");
    }

    isLoading.value = false;
  }

  Future<bool> _isBankConnected() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final snap = await _firestore.collection("users").doc(uid).get();

    if (!snap.exists) return false;

    final source = snap.data()?['source'] as Map<String, dynamic>?;

    return source?['bank'] == "connected";
  }
}
