import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Totals
  var totalDocs = 0.obs;
  var totalWarranties = 0.obs;
  var totalSubscriptions = 0.obs;
  var monthlyTotalPrice = 0.0.obs;
  var totalAmountAllDocs = 0.0.obs;
  var topSpendingDate = "-".obs; // NEW: date of highest spending

  // Insight Data
  var topDocType = "".obs;
  var topDocTypeCount = 0.obs;

  var topStoreName = "".obs;
  var topStoreCount = 0.obs;

  var topSpendingAmount = 0.0.obs;
  var topSpendingDoc = "".obs;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    String uid = auth.currentUser!.uid;
    listenDashboardData(uid); // realtime totals
    insightData(uid); // top insights
    super.onInit();
  }

  /// Real-time listener for totals
  void listenDashboardData(String userId) {
    _firestore
        .collection("users")
        .doc(userId)
        .collection("documents")
        .snapshots()
        .listen((snapshot) {
          totalDocs.value = snapshot.docs.length;

          int warranties = 0;
          int subscriptions = 0;
          double monthPrice = 0;
          double totalPrice = 0;
          DateTime now = DateTime.now();

          for (var doc in snapshot.docs) {
            var data = doc.data();

            if (data["source"] == "Warrantie") warranties++;
            if (data["documentType"] == "Subscription") subscriptions++;

            double price = double.tryParse(data["amount"].toString()) ?? 0;
            totalPrice += price;

            if (data["createdAt"] != null) {
              DateTime docDate = (data["createdAt"] as Timestamp).toDate();
              if (docDate.month == now.month && docDate.year == now.year) {
                monthPrice += price;
              }
            }
          }

          totalWarranties.value = warranties;
          totalSubscriptions.value = subscriptions;
          monthlyTotalPrice.value = monthPrice;
          totalAmountAllDocs.value = totalPrice;
        });
  }

  /// Function to get top insights
  Future<void> insightData(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("users")
          .doc(userId)
          .collection("documents")
          .get();

      Map<String, int> docTypeCount = {};
      Map<String, int> storeCount = {};

      double highestPrice = 0;
      String highestDocName = "";
      DateTime? highestDocDate; // NEW: store date of highest spending

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        String docType = data["documentType"] ?? "";
        String storeName = data["storeName"] ?? "";
        double price = double.tryParse(data["amount"].toString()) ?? 0;

        // Count document types
        docTypeCount[docType] = (docTypeCount[docType] ?? 0) + 1;

        // Count store transactions
        storeCount[storeName] = (storeCount[storeName] ?? 0) + 1;

        // Highest spending
        if (price > highestPrice) {
          highestPrice = price;
          highestDocName = docType;

          // Save date if available
          if (data["createdAt"] != null) {
            highestDocDate = (data["createdAt"] as Timestamp).toDate();
          }
        }
      }

      // Top document type
      if (docTypeCount.isNotEmpty) {
        var sortedDocTypes = docTypeCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        topDocType.value = sortedDocTypes.first.key;
        topDocTypeCount.value = sortedDocTypes.first.value;
      }

      // Top store
      if (storeCount.isNotEmpty) {
        var sortedStores = storeCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        topStoreName.value = sortedStores.first.key;
        topStoreCount.value = sortedStores.first.value;
      }

      // Top spending
      topSpendingAmount.value = highestPrice;
      topSpendingDoc.value = highestDocName;

      // NEW: store formatted date
      if (highestDocDate != null) {
        topSpendingDate.value =
            "${highestDocDate.day.toString().padLeft(2, '0')}-${highestDocDate.month.toString().padLeft(2, '0')}-${highestDocDate.year}";
      } else {
        topSpendingDate.value = "-";
      }
    } catch (e) {
      print("Insight Data Error: $e");
    }
  }

  /// Optional: Get top 3 newest documents
  Stream<QuerySnapshot> getTopNewestDocs() {
    return _firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("documents")
        .orderBy("createdAt", descending: true)
        .limit(3)
        .snapshots();
  }
}
