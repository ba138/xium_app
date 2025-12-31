const functions = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });
const { defineSecret } = require("firebase-functions/params");

admin.initializeApp();

// 🔐 Secrets
const PLAID_CLIENT_ID = defineSecret("PLAID_CLIENT_ID");
const PLAID_SECRET = defineSecret("PLAID_SECRET");
const PLAID_ENV = defineSecret("PLAID_ENV");

const { Configuration, PlaidApi, PlaidEnvironments } = require("plaid");

// 🔹 Create Plaid Client (lazy init)
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

/**
 * ✅ Create Plaid Link Token
 */
exports.createPlaidLinkToken = functions.onRequest(
  {
    region: "us-central1",
    secrets: [PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV],
    memory: "512MiB",
    timeoutSeconds: 60,
  },
  (req, res) => {
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

        res.status(200).json(response.data);
      } catch (e) {
        console.error("createPlaidLinkToken error:", e);
        res.status(500).json({ error: e.message });
      }
    });
  }
);


/**
 * ✅ Exchange Public Token
 */
exports.exchangePlaidToken = functions.onRequest(
  {
    secrets: [PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV],
  },
  (req, res) => {
    cors(req, res, async () => {
      try {
        const { publicToken, uid } = req.body;
        const plaidClient = getPlaidClient();

        const response = await plaidClient.itemPublicTokenExchange({
          public_token: publicToken,
        });

        await admin.firestore()
          .collection("plaidTokens")
          .doc(uid)
          .set({
            accessToken: response.data.access_token,
            itemId: response.data.item_id,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        res.json({ success: true });
      } catch (e) {
        console.error(e);
        res.status(500).json({ error: e.message });
      }
    });
  }
);

/**
 * ✅ Fetch & Store Transactions
 * - Group by merchant
 * - Avoid duplicates using transaction_id
 */
exports.syncTransactions = functions.onRequest(
  {
    secrets: [PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV],
  },
  (req, res) => {
    cors(req, res, async () => {
      try {
        const { uid } = req.body;

        const tokenSnap = await admin.firestore()
          .collection("plaidTokens")
          .doc(uid)
          .get();

        if (!tokenSnap.exists) {
          return res.status(404).json({ error: "No Plaid token found" });
        }

        const accessToken = tokenSnap.data().accessToken;
        const plaidClient = getPlaidClient();

        let cursor = null;
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

        const batch = admin.firestore().batch();

        for (const tx of added) {
          const merchant =
            tx.merchant_name?.toLowerCase().replace(/\s+/g, "_") ||
            "unknown";

          const ref = admin.firestore()
            .collection("users")
            .doc(uid)
            .collection("merchants")
            .doc(merchant)
            .collection("transactions")
            .doc(tx.transaction_id);

          const snap = await ref.get();
          if (!snap.exists) {
            batch.set(ref, {
              ...tx,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          }
        }

        await batch.commit();
        res.json({ synced: added.length });
      } catch (e) {
        console.error(e);
        res.status(500).json({ error: e.message });
      }
    });
  }
);
