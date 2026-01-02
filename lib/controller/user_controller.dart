import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xium_app/model/user_model.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reactive user model
  final Rxn<UserModel> user = Rxn<UserModel>();

  /// Loading state
  final isLoading = false.obs;

  StreamSubscription<DocumentSnapshot>? _userSub;

  @override
  void onInit() {
    super.onInit();
    _listenToUser();
  }

  @override
  void onClose() {
    _userSub?.cancel();
    super.onClose();
  }

  /// 🔹 Listen to current user document
  void _listenToUser() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    isLoading.value = true;

    _userSub = _firestore.collection("users").doc(uid).snapshots().listen((
      doc,
    ) {
      if (!doc.exists) {
        user.value = null;
        isLoading.value = false;
        return;
      }

      final data = doc.data()!;
      user.value = UserModel.fromJson({
        ...data,
        'uid': uid, // ensure uid is always set
      });

      isLoading.value = false;
    });
  }

  /// 🔹 Quick helpers for UI
  bool get isBankConnected => user.value?.source['bank'] == 'connected';

  bool get isEmailConnected => user.value?.source['email'] == 'connected';

  bool get isSmsConnected => user.value?.source['sms'] == 'connected';

  bool get isOcrConnected => user.value?.source['osr'] == 'connected';
}
