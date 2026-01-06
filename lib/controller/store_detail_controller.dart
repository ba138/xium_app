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

  /// 🔹 Fetch documents by store name
  Future<void> getStoreDocuments(String storeName) async {
    try {
      isLoading.value = true;
      error.value = '';
      allDocuments.clear();
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

      /// 🔥 store all docs
      allDocuments.assignAll(result);

      /// 🔥 default = ALL
      documents.assignAll(result);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
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

  /// 🔹 Sort documents based on option string

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
        sortedList.sort((a, b) {
          final aDate = toDate(a.createdAt);
          final bDate = toDate(b.createdAt);
          return bDate.compareTo(aDate);
        });
        break;

      case "Oldest":
        sortedList.sort((a, b) {
          final aDate = toDate(a.createdAt);
          final bDate = toDate(b.createdAt);
          return aDate.compareTo(bDate);
        });
        break;

      case "A–Z": // ✅ documentType A–Z
        sortedList.sort((a, b) {
          final aType = (a.documentType ?? '').toLowerCase();
          final bType = (b.documentType ?? '').toLowerCase();
          return aType.compareTo(bType);
        });
        break;

      case "Z–A": // ✅ documentType Z–A
        sortedList.sort((a, b) {
          final aType = (a.documentType ?? '').toLowerCase();
          final bType = (b.documentType ?? '').toLowerCase();
          return bType.compareTo(aType);
        });
        break;

      default:
        return;
    }

    documents.assignAll(sortedList);
  }
}
