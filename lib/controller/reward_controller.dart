import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class RewardController extends GetxController {
  var userPoints = 0.obs;

  // Level name
  var userLevelName = "".obs;

  // progress bar value
  var levelProgress = 0.0.obs;

  // points needed for next level
  var pointsToNextLevel = 0.obs;

  /// Mission progress
  var scanProgress = 0.0.obs;
  var emailProgress = 0.0.obs;
  var bankProgress = 0.0.obs;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    fetchUserPointsAndLevel();
    listenTodayDocuments();
    super.onInit();
  }

  void fetchUserPointsAndLevel() {
    String uid = auth.currentUser!.uid;

    _firestore.collection("users").doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data()!;

        int points = data["points"] ?? 0;

        userPoints.value = points;

        calculateLevel(points);
      }
    });
  }

  void calculateLevel(int points) {
    int nextLevelTarget = 0;
    int minLevelPoints = 0;

    if (points <= 3500) {
      userLevelName.value = "Beginner".tr;
      minLevelPoints = 0;
      nextLevelTarget = 3500;
    } else if (points <= 7000) {
      userLevelName.value = "Intermediate".tr;
      minLevelPoints = 3500;
      nextLevelTarget = 7000;
    } else {
      userLevelName.value = "Expert".tr;
      minLevelPoints = 7000;
      nextLevelTarget = 10000;
    }

    levelProgress.value =
        ((points - minLevelPoints) / (nextLevelTarget - minLevelPoints)).clamp(
          0.0,
          1.0,
        );

    pointsToNextLevel.value = (nextLevelTarget - points).clamp(0, 100000);

    if (points > 7000) {
      pointsToNextLevel.value = 0;
    }
  }

  /// NEW FUNCTION
  /// Check if user added document today from each source
  void listenTodayDocuments() {
    try {
      String uid = auth.currentUser!.uid;

      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);

      _firestore
          .collection("users")
          .doc(uid)
          .collection("documents")
          .snapshots()
          .listen((snapshot) {
            double scan = 0;
            double email = 0;
            double bank = 0;

            for (var doc in snapshot.docs) {
              var data = doc.data();

              String source = data["source"] ?? "";
              Timestamp? createdAt = data["createdAt"];

              if (createdAt == null) continue;

              DateTime date = createdAt.toDate();

              if (date.isAfter(startOfDay)) {
                if (source == "ocr") {
                  scan = 1;
                } else if (source == "email") {
                  email = 1;
                } else if (source == "bank") {
                  bank = 1;
                }
              }
            }

            scanProgress.value = scan;
            emailProgress.value = email;
            bankProgress.value = bank;
          });
    } catch (e) {
      print(e);
    }
  }
}
