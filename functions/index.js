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
              .collection("users")
              .doc(uid)
              .collection("documents")
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
              documentType: tx.personal_finance_category?.primary || null,
              source: "Bank",
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
              storeLogo:tx.storeLogo || null,
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

    // 🔹 Parse fields
    busboy.on("field", (name, value) => {
      fields[name] = value;
    });

    // 🔹 Parse attachments
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
        const fromRaw = fields.from || "";
        const subject = fields.subject || "";
        const body = fields["body-plain"] || "";

        // 🔹 Extract sender email
        const emailMatch = fromRaw.match(/<(.+?)>/);
        const senderEmail = emailMatch ? emailMatch[1] : fromRaw.trim();

        if (!senderEmail) {
          return res.status(400).json({
            error: "Sender email not found",
          });
        }

        // 🔹 STRICT user lookup by email
        const userSnap = await db
          .collection("users")
          .where("email", "==", senderEmail)
          .limit(1)
          .get();

        if (userSnap.empty) {
          return res.status(200).json({
            message: "User not found",
            senderEmail,
          });
        }

        const userDoc = userSnap.docs[0];
        const uid = userDoc.id;

        let fullText = body;

        // 🔹 OCR attachments FIRST (before storing anything)
        for (const file of files) {
          const tempPath = `temp/${Date.now()}-${file.filename}`;

          await bucket.file(tempPath).save(file.buffer, {
            contentType: file.mimeType,
          });

          const gcsUrl = `gs://${bucket.name}/${tempPath}`;
          const ocrText = await runOCR(gcsUrl);
          fullText += " " + ocrText;

          // 🔹 Cleanup temp file
          await bucket.file(tempPath).delete().catch(() => {});
        }

        // 🔹 Detect document type
        const documentType = detectDocumentType(fullText);

        // ❌ DROP UNKNOWN DOCUMENTS
        if (documentType === "unknown") {
          return res.status(200).json({
            success: false,
            reason: "Document type not supported",
            documentType,
          });
        }

        // 🔹 Detect store (only after type is valid)
        const store = detectStore(senderEmail, subject, fullText);

        // 🔹 Create document ONLY NOW
        const docRef = await db
          .collection("users")
          .doc(uid)
          .collection("documents")
          .add({
            source: "email",
            from: senderEmail,
            subject,
            documentType,
            storeId: store.storeId,
            storeName: store.storeName,
            storeLogo: store.storeLogo || null,
            confidence: store.confidence,
            status: "done",
            body: fullText,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        // 🔹 Mark email source as connected
        await db.collection("users").doc(uid).update({
          "source.email": "connected",
        });

        return res.status(200).json({
          success: true,
          uid,
          documentId: docRef.id,
          documentType,
          store: store.storeName,
        });

      } catch (innerError) {
        console.error("INNER ERROR:", innerError);
        return res.status(500).json({
          error: innerError.message,
        });
      }
    });

    busboy.end(req.rawBody);

  } catch (outerError) {
    console.error("OUTER ERROR:", outerError);
    return res.status(500).json({
      error: outerError.message,
    });
  }
});
