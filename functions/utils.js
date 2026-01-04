const admin = require("firebase-admin");

function getDB() {
  if (!admin.apps.length) {
    admin.initializeApp();
  }
  return admin.firestore();
}

async function ensureStoreExists(store) {
  const db = getDB();
  const ref = db.collection("stores").doc(store.storeId);
  const snap = await ref.get();

  if (!snap.exists) {
    await ref.set({
      storeId: store.storeId,
      name: store.storeName,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
}

module.exports = { ensureStoreExists };
