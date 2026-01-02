// const admin = require("firebase-admin");
// const db = admin.firestore();

// async function ensureStoreExists(store) {
//   const ref = db.collection("stores").doc(store.storeId);
//   const snap = await ref.get();

//   if (!snap.exists) {
//     await ref.set({
//       storeId: store.storeId,
//       name: store.storeName,
//       createdAt: admin.firestore.FieldValue.serverTimestamp()
//     });
//   }
// }

// module.exports = { ensureStoreExists };
