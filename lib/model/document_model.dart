import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  // 🔹 Common fields
  final String? id;
  final String? source; // email | bank
  final String? documentType;
  final Timestamp? createdAt;
  final String? storeId;
  final String? storeName;
  final String? storeLogo;

  // 🔹 Email-based document fields
  final String? from;
  final String? subject;
  final String? body;
  final double? confidence;
  final String? status;

  // 🔹 Bank / transaction-based fields
  final double? amount;
  final String? currency;
  final String? date;
  final bool? pending;
  final String? merchantEntityId;

  DocumentModel({
    this.id,
    this.source,
    this.documentType,
    this.createdAt,
    this.storeId,
    this.storeName,
    this.storeLogo,

    this.from,
    this.subject,
    this.body,
    this.confidence,
    this.status,

    this.amount,
    this.currency,
    this.date,
    this.pending,
    this.merchantEntityId,
  });

  /// 🔹 Firestore → Model
  factory DocumentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return DocumentModel(
      id: doc.id,
      source: data?['source'],
      documentType: data?['documentType'],
      createdAt: data?['createdAt'],
      storeId: data?['storeId'],
      storeName: data?['storeName'],
      storeLogo: data?['storeLogo'],

      from: data?['from'],
      subject: data?['subject'],
      body: data?['body'],
      confidence: (data?['confidence'] as num?)?.toDouble(),
      status: data?['status'],

      amount: (data?['amount'] as num?)?.toDouble(),
      currency: data?['currency'],
      date: data?['date'],
      pending: data?['pending'],
      merchantEntityId: data?['merchantEntityId'],
    );
  }

  /// 🔹 Model → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'source': source,
      'documentType': documentType,
      'createdAt': createdAt,
      'storeId': storeId,
      'storeName': storeName,
      'storeLogo': storeLogo,

      'from': from,
      'subject': subject,
      'body': body,
      'confidence': confidence,
      'status': status,

      'amount': amount,
      'currency': currency,
      'date': date,
      'pending': pending,
      'merchantEntityId': merchantEntityId,
    };
  }

  /// 🔹 Helpers (Very Useful for UI)
  bool get isEmailDocument => source == 'email';
  bool get isBankTransaction => source == 'bank';
}
