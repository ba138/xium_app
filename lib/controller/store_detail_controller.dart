import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xium_app/model/document_model.dart';

class StoreDetailController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 State
  final RxList<DocumentModel> documents = <DocumentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  /// 🔹 Fetch documents by store name
  Future<void> getStoreDocuments(String storeName) async {
    try {
      isLoading.value = true;
      error.value = '';
      documents.clear();

      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        error.value = "User not logged in";
        return;
      }

      final snapshot = await _db
          .collection("users")
          .doc(uid)
          .collection("documents")
          .where("storeName", isEqualTo: storeName)
          .orderBy("createdAt", descending: true)
          .get();

      final result = snapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc))
          .toList();

      documents.assignAll(result);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
