import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xium_app/model/document_model.dart';
import 'package:xium_app/model/store_model.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 All documents
  final RxList<DocumentModel> documents = <DocumentModel>[].obs;

  /// 🔹 All stores (grouped)
  final RxList<StoreModel> stores = <StoreModel>[].obs;

  /// 🔍 Stores shown in UI (search result)
  final RxList<StoreModel> filteredStores = <StoreModel>[].obs;

  final RxBool isLoading = false.obs;

  StreamSubscription<QuerySnapshot>? _docSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenDocuments();
  }

  @override
  void onClose() {
    _docSubscription?.cancel();
    super.onClose();
  }

  /// 🔥 REALTIME LISTENER
  void _listenDocuments() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    isLoading.value = true;

    _docSubscription?.cancel();

    _docSubscription = _db
        .collection('users')
        .doc(uid)
        .collection('documents')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            documents.assignAll(
              snapshot.docs.map((d) => DocumentModel.fromFirestore(d)).toList(),
            );

            _buildStores();
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
            Get.snackbar("Error", e.toString());
          },
        );
  }

  /// 🔥 GROUP BY storeName (NOT storeId)
  void _buildStores() {
    final Map<String, List<DocumentModel>> grouped = {};

    for (final doc in documents) {
      final name = (doc.storeName ?? '').trim();
      if (name.isEmpty || name.toLowerCase() == 'unknown') continue;

      final key = name.toLowerCase();

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(doc);
    }

    final result = grouped.entries.map((entry) {
      final docs = entry.value;
      final first = docs.first;

      return StoreModel(
        storeName: first.storeName!,
        storeLogo: first.storeLogo,
        documentCount: docs.length,
      );
    }).toList();

    stores.assignAll(result);
    filteredStores.assignAll(result); // 🔑 reset search
  }

  /// 🔍 SEARCH — STARTS WITH
  void searchStores(String query) {
    if (query.isEmpty) {
      filteredStores.assignAll(stores);
      return;
    }

    final q = query.toLowerCase();

    filteredStores.assignAll(
      stores.where((store) => store.storeName.toLowerCase().startsWith(q)),
    );
  }

  /// 📂 Documents for a store (helper)
  List<DocumentModel> documentsByStoreName(String storeName) {
    return documents
        .where((d) => d.storeName?.toLowerCase() == storeName.toLowerCase())
        .toList();
  }
}
