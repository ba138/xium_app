import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xium_app/model/document_model.dart';

class StoreDetailController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 All documents (original)
  final RxList<DocumentModel> allDocuments = <DocumentModel>[].obs;

  /// 🔹 Filtered documents (shown in UI)
  final RxList<DocumentModel> documents = <DocumentModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  StreamSubscription<QuerySnapshot>? _docSubscription;

  @override
  void onClose() {
    _docSubscription?.cancel();
    super.onClose();
  }

  /// 🔥 REALTIME: Listen documents by store name
  void listenStoreDocuments(String storeName) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      error.value = "User not logged in";
      return;
    }

    isLoading.value = true;
    error.value = '';

    _docSubscription?.cancel();

    _docSubscription = _db
        .collection("users")
        .doc(uid)
        .collection("documents")
        .where("storeName", isEqualTo: storeName)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final result = snapshot.docs
                .map((doc) => DocumentModel.fromFirestore(doc))
                .toList();

            /// 🔥 keep master + filtered in sync
            allDocuments.assignAll(result);
            documents.assignAll(result);

            isLoading.value = false;
          },
          onError: (e) {
            error.value = e.toString();
            isLoading.value = false;
          },
        );
  }

  /// 🔹 FILTER BY DOCUMENT TYPE
  /// invoice | warranty | receipt | all
  void filterByType(String type) {
    if (type.toLowerCase() == 'all') {
      documents.assignAll(allDocuments);
      return;
    }

    final filtered = allDocuments.where((doc) {
      return doc.documentType?.toLowerCase() == type.toLowerCase();
    }).toList();

    documents.assignAll(filtered);
  }

  /// 🔹 SORT DOCUMENTS
  void sortByOption(String option) {
    final List<DocumentModel> sortedList = List.from(documents);

    DateTime toDate(dynamic value) {
      if (value == null) return DateTime(1970);
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      return DateTime(1970);
    }

    switch (option) {
      case "Newest":
        sortedList.sort(
          (a, b) => toDate(b.createdAt).compareTo(toDate(a.createdAt)),
        );
        break;

      case "Oldest":
        sortedList.sort(
          (a, b) => toDate(a.createdAt).compareTo(toDate(b.createdAt)),
        );
        break;

      case "A–Z": // documentType
        sortedList.sort(
          (a, b) => (a.documentType ?? '').toLowerCase().compareTo(
            (b.documentType ?? '').toLowerCase(),
          ),
        );
        break;

      case "Z–A":
        sortedList.sort(
          (a, b) => (b.documentType ?? '').toLowerCase().compareTo(
            (a.documentType ?? '').toLowerCase(),
          ),
        );
        break;

      default:
        return;
    }

    documents.assignAll(sortedList);
  }

  /// ✅ ADD or UPDATE amount (Realtime-safe)
  Future<void> addOrUpdateAmount({
    required String documentId,
    required double amount,
    required String currency,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw "User not logged in";

      await _db
          .collection("users")
          .doc(uid)
          .collection("documents")
          .doc(documentId)
          .update({"amount": amount, "currency": currency});

      /// 🔥 NO manual list update needed
      /// Firestore listener will update UI automatically
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
