import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  var totalDocs = 0.obs;
  var totalWarranties = 0.obs;
  var totalSubscriptions = 0.obs;

  var monthlyTotalPrice = 0.0.obs;
  var totalAmountAllDocs = 0.0.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    listenDashboardData(auth.currentUser!.uid);
    super.onInit();
  }

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

            /// warranties count
            if (data["source"] == "Warrantie") {
              warranties++;
            }

            /// subscription count
            if (data["documentType"] == "Subscription") {
              subscriptions++;
            }

            /// safe amount parsing
            double price = double.tryParse(data["amount"].toString()) ?? 0;

            totalPrice += price;

            /// monthly calculation
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
}
