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

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    fetchUserPointsAndLevel();
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
      userLevelName.value = "Beginner";

      minLevelPoints = 0;
      nextLevelTarget = 3500;
    } else if (points <= 7000) {
      userLevelName.value = "Intermediate";

      minLevelPoints = 3500;
      nextLevelTarget = 7000;
    } else {
      userLevelName.value = "Expert";

      minLevelPoints = 7000;
      nextLevelTarget = 10000; // optional cap
    }

    // progress inside current level
    levelProgress.value =
        ((points - minLevelPoints) / (nextLevelTarget - minLevelPoints)).clamp(
          0.0,
          1.0,
        );

    // points needed for next level
    pointsToNextLevel.value = (nextLevelTarget - points).clamp(0, 100000);

    // if expert already
    if (points > 7000) {
      pointsToNextLevel.value = 0;
    }
  }
}
