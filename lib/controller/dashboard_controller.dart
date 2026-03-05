import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Totals
  var totalDocs = 0.obs;
  var totalWarranties = 0.obs;
  var totalSubscriptions = 0.obs;
  var monthlyTotalPrice = 0.0.obs;
  var totalAmountAllDocs = 0.0.obs;
  var topSpendingDate = "-".obs; // NEW: date of highest spending
  var userPoints = 0.obs; // Points from user collection
  var userLevel = 0.obs;
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
    fetchUserPointsAndLevel(); // user points and level
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

  Future<void> fetchUserPointsAndLevel() async {
    try {
      String uid = auth.currentUser!.uid;

      DocumentSnapshot userDoc = await _firestore
          .collection("users")
          .doc(uid)
          .get();

      int points = 0;

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        points = (data["points"] ?? 0) as int;
      }

      userPoints.value = points;
      userLevel.value = calculateLevel(points);
      updateLevelProgress(); // Update progress for the level
    } catch (e) {
      userPoints.value = 0;
      userLevel.value = 0;
    }
  }

  /// Calculate level based on points (each 2000 points per level, max 10)
  int calculateLevel(int points) {
    int level = 1;
    for (int i = 1; i <= 10; i++) {
      if (points <= i * 2000) {
        level = i;
        break;
      }
    }
    return level;
  }

  /// Progress for LinearProgressIndicator relative to total levels (0.1 per level)
  void updateLevelProgress() {
    int currentLevel = userLevel.value;

    // base progress for completed levels (each level = 0.1)
    double baseProgress = (currentLevel - 1) * 0.1;

    // progress within the current level (fraction of 2000 points)
    double minPointsForLevel = (currentLevel - 1) * 2000.0;
    double maxPointsForLevel = currentLevel * 2000.0;

    double levelFraction = 0.0;
    if (userPoints.value > minPointsForLevel) {
      levelFraction = (userPoints.value - minPointsForLevel) / 2000.0 * 0.1;
    }

    // total progress = base + fraction within level
    levelProgress.value = (baseProgress + levelFraction).clamp(0.0, 1.0);

    debugPrint(
      "Points: ${userPoints.value}, Level: $currentLevel, Progress: ${levelProgress.value}",
    );
  }

  /// Optional: progress value for LinearProgressIndicator
  var levelProgress = 0.0.obs;
}
