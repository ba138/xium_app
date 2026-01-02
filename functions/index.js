const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });
const { defineSecret } = require("firebase-functions/params");

// Helpers
// const { detectStore, detectDocumentType } = require("./classification");
// const { ensureStoreExists } = require("./utils");
// const { runOCR } = require("./ocr");

// Initialize Firebase ONCE
admin.initializeApp();

const db = admin.firestore();
const bucket = admin.storage().bucket();

// 🔐 Secrets
const PLAID_CLIENT_ID = defineSecret("PLAID_CLIENT_ID");
const PLAID_SECRET = defineSecret("PLAID_SECRET");
const PLAID_ENV = defineSecret("PLAID_ENV");

const { Configuration, PlaidApi, PlaidEnvironments } = require("plaid");

// 🔹 Plaid Client (lazy)
function getPlaidClient() {
  const config = new Configuration({
    basePath: PlaidEnvironments[PLAID_ENV.value()],
    baseOptions: {
      headers: {
        "PLAID-CLIENT-ID": PLAID_CLIENT_ID.value(),
        "PLAID-SECRET": PLAID_SECRET.value(),
      },
    },
  });
  return new PlaidApi(config);
}

/* ============================================================
   ✅ CREATE PLAID LINK TOKEN
============================================================ */
exports.createPlaidLinkToken = onRequest(
  {
    region: "us-central1",
    secrets: [PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV],
    memory: "512MiB",
    timeoutSeconds: 60,
  },
  (req, res) =>
    cors(req, res, async () => {
      try {
        const { uid } = req.body;
        if (!uid) {
          return res.status(400).json({ error: "uid is required" });
        }

        const plaidClient = getPlaidClient();

        const response = await plaidClient.linkTokenCreate({
          user: { client_user_id: uid },
          client_name: "Xium App",
          products: ["transactions"],
          country_codes: ["US"],
          language: "en",
        });

        res.json(response.data);
      } catch (e) {
        console.error("createPlaidLinkToken error:", e);
        res.status(500).json({ error: e.message });
      }
    })
);

/* ============================================================
   ✅ EXCHANGE PUBLIC TOKEN
============================================================ */
exports.exchangePlaidToken = onRequest(
  {
    secrets: [PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV],
  },
  (req, res) =>
    cors(req, res, async () => {
      try {
        const { publicToken, uid } = req.body;

        const plaidClient = getPlaidClient();
        const response = await plaidClient.itemPublicTokenExchange({
          public_token: publicToken,
        });

        await db.collection("plaidTokens").doc(uid).set({
          accessToken: response.data.access_token,
          itemId: response.data.item_id,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        res.json({ success: true });
      } catch (e) {
        console.error("exchangePlaidToken error:", e);
        res.status(500).json({ error: e.message });
      }
    })
);

/* ============================================================
   ✅ SYNC TRANSACTIONS
============================================================ */
exports.syncTransactions = onRequest(
  {
    secrets: [PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV],
  },
  (req, res) =>
    cors(req, res, async () => {
      try {
        const { uid } = req.body;

        const tokenSnap = await db.collection("plaidTokens").doc(uid).get();
        if (!tokenSnap.exists) {
          return res.status(404).json({ error: "No Plaid token found" });
        }

        const accessToken = tokenSnap.data().accessToken;
        const plaidClient = getPlaidClient();

        let cursor = tokenSnap.data().cursor || null;
        let added = [];

        do {
          const response = await plaidClient.transactionsSync({
            access_token: accessToken,
            cursor,
          });

          added.push(...response.data.added);
          cursor = response.data.next_cursor;

          if (!response.data.has_more) break;
        } while (true);

        const batch = db.batch();

        for (const tx of added) {
          const merchantName = tx.merchant_name || tx.name || "Unknown";
          const merchantEntityId = tx.merchant_entity_id || "unknown";

          const storeId = merchantName
            .toLowerCase()
            .replace(/[^a-z0-9]/g, "");

          // Store master
          batch.set(
            db.collection("stores").doc(storeId),
            {
              storeId,
              name: merchantName,
              merchantEntityIds:
                admin.firestore.FieldValue.arrayUnion(merchantEntityId),
            },
            { merge: true }
          );

          // Transaction
          batch.set(
            db
              .collection("transactions")
              .doc(uid)
              .collection("plaid")
              .doc(tx.transaction_id),
            {
              storeId,
              storeName: merchantName,
              merchantName,
              merchantEntityId,
              amount: tx.amount,
              currency: tx.iso_currency_code,
              date: tx.date,
              pending: tx.pending,
              category: tx.personal_finance_category?.primary || null,
              source: "plaid",
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
        }

        await db.collection("plaidTokens").doc(uid).update({ cursor });

        await db.collection("users").doc(uid).update({
          "source.bank": "connected",
        });

        await batch.commit();
        res.json({ synced: added.length });
      } catch (e) {
        console.error("syncTransactions error:", e);
        res.status(500).json({ error: e.message });
      }
    })
);

/* ============================================================
   ✅ PROCESS INCOMING EMAIL (MAILGUN)
============================================================ */
// exports.processIncomingEmail = onRequest(async (req, res) => {
//   try {
//     const { from, subject, "body-plain": body } = req.body;
//     const recipient = req.body.recipient;

//     const userSnap = await db
//       .collection("users")
//       .where("forwardingEmail", "==", recipient)
//       .limit(1)
//       .get();

//     if (userSnap.empty) return res.send("User not found");

//     const userId = userSnap.docs[0].id;

//     const docRef = await db
//       .collection("users")
//       .doc(userId)
//       .collection("documents")
//       .add({
//         source: "email",
//         from,
//         subject,
//         status: "processing",
//         createdAt: admin.firestore.FieldValue.serverTimestamp(),
//       });

//     let fullText = body || "";

//     if (req.files) {
//       for (const file of Object.values(req.files)) {
//         const filePath = `users/${userId}/documents/${docRef.id}/${file.name}`;
//         await bucket.file(filePath).save(file.data, {
//           contentType: file.mimetype,
//         });

//         const gcsUrl = `gs://${bucket.name}/${filePath}`;
//         fullText += " " + (await runOCR(gcsUrl));
//       }
//     }

//     const store = detectStore(from, subject, fullText);
//     const type = detectDocumentType(fullText);

//     await ensureStoreExists(store);

//     await docRef.update({
//       storeId: store.storeId,
//       storeName: store.storeName,
//       type,
//       confidence: store.confidence,
//       status: "done",
//     });

//     res.send("Email processed successfully");
//   } catch (err) {
//     console.error("processIncomingEmail error:", err);
//     res.status(500).send("Processing error");
//   }
// });
