const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });
const { defineSecret } = require("firebase-functions/params");
const { detectStore, detectDocumentType } = require("./classification");
const { ensureStoreExists } = require("./utils");
const { runOCR } = require("./ocr");
const Busboy = require("busboy");
const { getStoreLogo } = require("./logo");
const OpenAI = require("openai");
const fetch = require("node-fetch");



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
          const merchantEntityId = tx.merchant_entity_id || null;

          const storeId = merchantName
            .toLowerCase()
            .replace(/[^a-z0-9]/g, "");

          const storeLogo = await getStoreLogo({
            plaidClient,
            merchantEntityId,
            website: tx.website || null,
          });

          batch.set(
            db
              .collection("users")
              .doc(uid)
              .collection("documents")
              .doc(tx.transaction_id),
            {
              storeId,
              storeName: merchantName,
              merchantEntityId,
              amount: tx.amount,
              currency: tx.iso_currency_code,
              date: tx.date,
              pending: tx.pending,
              documentType: tx.personal_finance_category?.primary || null,
              source: "bank",
            storeLogo:  tx.logo_url,
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

exports.processIncomingEmail = onRequest(
  { secrets: ["OPENAI_API_KEY"] },
  async (req, res) => {
    try {
      const busboy = Busboy({ headers: req.headers });

      let fields = {};
      let files = [];

      busboy.on("field", (name, value) => {
        fields[name] = value;
      });

      busboy.on("file", (name, file, info) => {
        const buffers = [];
        file.on("data", d => buffers.push(d));
        file.on("end", () => {
          files.push({
            filename: info.filename,
            mimeType: info.mimeType,
            buffer: Buffer.concat(buffers),
          });
        });
      });

      busboy.on("finish", async () => {
        try {
          const fromRaw = fields.from || "";
          const subject = fields.subject || "";
          const body = fields["body-plain"] || "";

          const match = fromRaw.match(/<(.+?)>/);
          const senderEmail = match ? match[1] : fromRaw.trim();

          if (!senderEmail) {
            return res.status(400).json({ error: "Sender email not found" });
          }

          // 🔹 Find user by email (unchanged)
          const userSnap = await db
            .collection("users")
            .where("email", "==", senderEmail)
            .limit(1)
            .get();

          if (userSnap.empty) {
            return res.status(200).json({
              success: false,
              message: "User not found",
              senderEmail,
            });
          }

          const uid = userSnap.docs[0].id;

          let fullText = `
FROM: ${senderEmail}
SUBJECT: ${subject}

${body}
          `;

          // Attachments saved & deleted (unchanged)
          for (const file of files) {
            const tempPath = `temp/${Date.now()}-${file.filename}`;
            await bucket.file(tempPath).save(file.buffer, {
              contentType: file.mimeType,
            });
            await bucket.file(tempPath).delete().catch(() => {});
          }

          // 🔐 OpenAI (ONLY classification)
          const openai = new OpenAI({
            apiKey: process.env.OPENAI_API_KEY,
          });

          const aiResponse = await openai.responses.create({
            model: "gpt-4.1",
            input: [
              {
                role: "user",
                content: [
                  {
                    type: "input_text",
                    text: `
Analyze this EMAIL and return VALID JSON ONLY.

{
  "documentType": "invoice | receipt | warranty | unknown",
  "storeName": string | null,
  "merchantName": string | null,
  "storeLogo": "public logo url (png/jpg/svg) or null",
  "confidence": number (0.0 - 1.0)
  "amount": number | null
  "currency": string | null
}

Rules:
- Ignore marketing/newsletters
- Use sender + subject + body
- If not a financial document → documentType = "unknown"
- Store logo: search the web for the logo of the storeName.
  - If a real public logo URL is found (png/jpg/svg) return it.
  - If no official logo is found, return null.
- JSON ONLY, no markdown
- use body text to find amount as number if possible else null
-use store name from the body if possible unknown otherwise
-also extract currency from body like USD if possible else null
- DO NOT invent or hallucinate logos.
DO NOT add explanations or markdown.

EMAIL:
${fullText}
                    `,
                  },
                ],
              },
            ],
          });

          let rawText = aiResponse.output_text || "";
          rawText = rawText.replace(/```json|```/g, "").trim();

          let extracted;
          try {
            extracted = JSON.parse(rawText);
          } catch {
            return res.status(400).json({
              error: "Failed to parse AI response",
              rawText,
            });
          }

          // ❌ Ignore unknown documents
          if (extracted.documentType === "unknown") {
            return res.status(200).json({
              success: false,
              reason: "Unsupported document",
            });
          }

          // 🔹 Save document (same structure)
          const docRef = await db
            .collection("users")
            .doc(uid)
            .collection("documents")
            .add({
              amount: extracted.amount ?? null,
              source: "email",
              from: senderEmail,
              subject,
              body,
              documentType: extracted.documentType,
              storeName: extracted.storeName ?? "Unknown",
              storeLogo: extracted.storeLogo ?? null,
              merchantName: extracted.merchantName ?? null,
              confidence: extracted.confidence ?? 0.8,
              status: "done",
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
              currency: extracted.currency ?? null,
            });

          await db.collection("users").doc(uid).update({
            "source.email": "connected",
          });

          return res.status(200).json({
            success: true,
            documentId: docRef.id,
            data: extracted,
          });
        } catch (err) {
          console.error("INNER ERROR:", err);
          return res.status(500).json({ error: err.message });
        }
      });

      busboy.end(req.rawBody);
    } catch (err) {
      console.error("OUTER ERROR:", err);
      return res.status(500).json({ error: err.message });
    }
  }
);

exports.deleteUserAccount = onRequest(async (req, res) => {
  try {
    // 🔐 Check auth token
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const idToken = authHeader.split("Bearer ")[1];
    const decoded = await admin.auth().verifyIdToken(idToken);
    const uid = decoded.uid;

    const userRef = db.collection("users").doc(uid);

    // 🔹 Helper: delete a subcollection
    const deleteSubCollection = async (collectionRef) => {
      const snapshot = await collectionRef.get();
      const batch = db.batch();

      snapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      await batch.commit();
    };

    // 🔹 Delete subcollections
    await deleteSubCollection(userRef.collection("documents"));
    await deleteSubCollection(userRef.collection("loyaltyCards"));

    // 🔹 Delete user document
    await userRef.delete();

    // 🔹 Delete Firebase Auth user
    await admin.auth().deleteUser(uid);

    return res.status(200).json({
      success: true,
      message: "User deleted from Auth and Firestore successfully",
    });

  } catch (error) {
    console.error("deleteUserAccount error:", error);
    return res.status(500).json({
      error: error.message,
    });
  }
});

async function validateLogoUrl(url) {
  try {
    if (!url) return null;

    const res = await fetch(url, { method: "HEAD", timeout: 5000 });
    if (!res.ok) return null;

    const contentType = res.headers.get("content-type") || "";
    if (!contentType.startsWith("image/")) return null;

    return url;
  } catch {
    return null;
  }
}

/**
 * Clean AI JSON (remove ```json fences)
 */
function extractJson(text) {
  return text
    .replace(/```json/i, "")
    .replace(/```/g, "")
    .trim();
}

exports.processImageDocument = onRequest(
  { secrets: ["OPENAI_API_KEY"] },
  (req, res) =>
    cors(req, res, async () => {
      try {
        const { uid, imageUrl } = req.body;

        if (!uid || !imageUrl) {
          return res.status(400).json({
            error: "uid and imageUrl are required",
          });
        }

        const openai = new OpenAI({
          apiKey: process.env.OPENAI_API_KEY,
        });

        // 🧠 OCR + Classification + Logo search
        const response = await openai.responses.create({
          model: "gpt-4.1",
          input: [
            {
              role: "user",
              content: [
                {
                  type: "input_text",
                  text: `
Analyze this image and return VALID JSON ONLY.

{
  "documentType": "invoice | receipt | warranty | unknown",
  "storeName": string | null,
  "merchantName": string | null,
  "amount": number | null,
  "currency": string | null,
  "date": "YYYY-MM-DD" | null,
  "storeLogo": "public logo image url or null"
}

Rules:
- Find official store logo from the web
- Logo must be public PNG/JPG/SVG
- If unsure → storeLogo = null
- If not a valid document → documentType = "unknown"
DO NOT add explanations or markdown.
`,
                },
                {
                  type: "input_image",
                  image_url: imageUrl,
                },
              ],
            },
          ],
        });

        const rawText = response.output_text;
        if (!rawText) {
          throw new Error("Empty AI response");
        }

        // 🧹 Clean & parse JSON
        let extracted;
        try {
          extracted = JSON.parse(extractJson(rawText));
        } catch (e) {
          return res.status(400).json({
            error: "Failed to parse AI response",
            rawText,
          });
        }

        // ❌ Unsupported document
        if (extracted.documentType === "unknown") {
          return res.status(200).json({
            success: false,
            reason: "Unsupported document",
          });
        }

        // ✅ Validate logo
        const validLogo = await validateLogoUrl(extracted.storeLogo);

        // 🔹 Save to Firestore
        const docRef = await db
          .collection("users")
          .doc(uid)
          .collection("documents")
          .add({
            source: "ocr",
            imageUrl,
            documentType: extracted.documentType,
            storeName: extracted.storeName || "Unknown",
            storeLogo: validLogo,
            merchantName: extracted.merchantName ?? null,
            amount: extracted.amount ?? null,
            currency: extracted.currency ?? null,
            date: extracted.date ?? null,
            confidence: 0.9,
            status: "done",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        // 🔹 Mark OCR connected
        await db.collection("users").doc(uid).set(
          {
            source: { ocr: "connected" },
          },
          { merge: true }
        );

        return res.status(200).json({
          success: true,
          documentId: docRef.id,
          data: {
            ...extracted,
            storeLogo: validLogo,
          },
        });
      } catch (error) {
        console.error("OCR Function Error:", error);
        return res.status(500).json({
          error: error.message,
        });
      }
    })
);



