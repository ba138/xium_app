const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });
const { defineSecret } = require("firebase-functions/params");
const { detectStore, detectDocumentType } = require("./classification");
const { ensureStoreExists } = require("./utils");
const { runOCR } = require("./ocr");
const Busboy = require("busboy");

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
  { secrets: [PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV] },
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
        console.error(e);
        res.status(500).json({ error: e.message });
      }
    })
);

/* ============================================================
   ✅ SYNC TRANSACTIONS
============================================================ */
exports.syncTransactions = onRequest(
  { secrets: [PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV] },
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
              source: "Bank",
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
exports.processIncomingEmail = onRequest(async (req, res) => {
  try {
    const Busboy = require("busboy");
    const busboy = Busboy({ headers: req.headers });

    let fields = {};
    let files = [];

    busboy.on("field", (name, value) => {
      fields[name] = value;
    });

    busboy.on("file", (name, file, info) => {
      const { filename, mimeType } = info;
      const buffers = [];

      file.on("data", data => buffers.push(data));
      file.on("end", () => {
        files.push({
          filename,
          mimeType,
          buffer: Buffer.concat(buffers),
        });
      });
    });

    busboy.on("finish", async () => {
      try {
        const from = fields.from || "";
        const subject = fields.subject || "";
        const body = fields["body-plain"] || "";
        // const recipientRaw = fields.recipient || "";
        const recipientRaw = "receipt+UC3oafFrD9Q9s5rrcsLPQpoqe6c2@mg.xium.io";

        // 🔹 Mailgun may send multiple recipients
        const recipients = recipientRaw
          .split(",")
          .map(r => r.trim());

        // 🔹 Find receipt+UID@mg.xium.io
        const receiptEmail = recipients.find(r =>
          r.startsWith("receipt+")
        );

        if (!receiptEmail) {
          return res.status(200).json({
            message: "No receipt email found",
            recipients,
          });
        }

        // 🔹 Extract UID
        const uid = receiptEmail.split("receipt+")[1].split("@")[0];

        // 🔹 Fetch user by UID (DOC ID)
        const userRef = db.collection("users").doc(uid);
        const userSnap = await userRef.get();

        if (!userSnap.exists) {
          return res.status(200).json({
            message: "User not found",
            uid,
            receiptEmail,
          });
        }

        // 🔹 Create document
        const docRef = await userRef
          .collection("documents")
          .add({
            source: "email",
            from,
            subject,
            recipient: receiptEmail,
            status: "processing",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        let fullText = body;

        // 🔹 Upload attachments + OCR
        for (const file of files) {
          const filePath = `users/${uid}/documents/${docRef.id}/${file.filename}`;

          await bucket.file(filePath).save(file.buffer, {
            contentType: file.mimeType,
          });

          const gcsUrl = `gs://${bucket.name}/${filePath}`;
          const ocrText = await runOCR(gcsUrl);
          fullText += " " + ocrText;
        }

        // 🔹 Classification
        const store = detectStore(from, subject, fullText);
        const documentType = detectDocumentType(fullText);

        await ensureStoreExists(store);

        // 🔹 Final update
        await docRef.update({
          storeId: store.storeId,
          storeName: store.storeName,
          storeLogo: store.storeLogo || null,
          documentType, // invoice | receipt | warranty
          confidence: store.confidence,
          status: "done",
        });

        return res.status(200).json({
          success: true,
          uid,
          documentId: docRef.id,
          store,
          documentType,
        });

      } catch (innerError) {
        console.error("INNER ERROR:", innerError);
        return res.status(500).json({
          error: innerError.message,
          stack: innerError.stack,
        });
      }
    });

    busboy.end(req.rawBody);

  } catch (error) {
    console.error("OUTER ERROR:", error);
    return res.status(500).json({
      error: error.message,
      stack: error.stack,
    });
  }
});

