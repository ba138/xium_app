import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xium_app/model/document_model.dart';
import 'package:xium_app/model/store_model.dart';

class HomeController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final RxList<DocumentModel> documents = <DocumentModel>[].obs;
  final RxList<StoreModel> stores = <StoreModel>[].obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    try {
      isLoading.value = true;

      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('documents')
          .orderBy('createdAt', descending: true)
          .get();

      documents.value = snap.docs
          .map((d) => DocumentModel.fromFirestore(d))
          .toList();

      _buildStores();
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 GROUP BY storeName (NOT storeId)
  void _buildStores() {
    final Map<String, List<DocumentModel>> grouped = {};

    for (final doc in documents) {
      final name = (doc.storeName ?? '').trim();
      if (name.isEmpty || name.toLowerCase() == 'unknown') continue;

      final key = name.toLowerCase(); // 🔑 normalize

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(doc);
    }

    stores.value = grouped.entries.map((entry) {
      final docs = entry.value;
      final first = docs.first;

      return StoreModel(
        storeName: first.storeName!,
        storeLogo: first.storeLogo,
        documentCount: docs.length,
      );
    }).toList();
  }

  /// 🔹 Get documents for a store
  List<DocumentModel> documentsByStoreName(String storeName) {
    return documents
        .where((d) => d.storeName?.toLowerCase() == storeName.toLowerCase())
        .toList();
  }
}
