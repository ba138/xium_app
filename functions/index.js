const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });
const { defineSecret } = require("firebase-functions/params");

const { runOCR } = require("./ocr");
const Busboy = require("busboy");
const axios = require("axios");
const functions = require("firebase-functions"); // ✅ needed


const { getStoreLogo } = require("./logo");
const OpenAI = require("openai");
const fetch = require("node-fetch");



admin.initializeApp();

const db = admin.firestore();
const bucket = admin.storage().bucket();



// 🔐 Secrets
const TINK_CLIENT_ID = "39ff2c1100404c7fb39aa32fa78b8a9e"; // store safely via env or Firebase Secret Manager
const TINK_CLIENT_SECRET = "9cf66e424de4441690d9372a8efd9e96";
const REDIRECT_URI = "yourapp://tink-callback";

// 1️⃣ Provide Tink URL for one-time access
exports.getTinkLinkUrl = functions.https.onRequest(async (req, res) => {
  try {
    const { uid } = req.body;
    if (!uid) return res.status(400).json({ error: "uid required" });

    const tinkUrl = `https://link.tink.com/1.0/transactions/connect-accounts?client_id=${TINK_CLIENT_ID}&redirect_uri=${encodeURIComponent(REDIRECT_URI)}&market=GB&locale=en_US`;

    res.json({ tink_url: tinkUrl });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// 2️⃣ Exchange code for access token
// 1️⃣ Exchange Tink code for user access token
exports.exchangeTinkToken = functions.https.onRequest(async (req, res) => {
  try {
    const { uid, code } = req.body;
    if (!uid || !code) return res.status(400).json({ error: "uid and code required" });

    // Exchange authorization code for access token
    const tokenRes = await axios.post(
      "https://api.tink.com/api/v1/oauth/token",
      new URLSearchParams({
        grant_type: "authorization_code",
        code,
        client_id: TINK_CLIENT_ID,
        client_secret: TINK_CLIENT_SECRET
      }),
      { headers: { "Content-Type": "application/x-www-form-urlencoded" } }
    );

    const accessToken = tokenRes.data.access_token;

    // Store token in Firestore
    await db.collection("tinkTokens").doc(uid).set({
      accessToken,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // ✅ Immediately fetch transactions after storing token
    const txCount = await syncTinkTransactionsInternal(uid, accessToken);

    res.json({ success: true, synced: txCount });
  } catch (err) {
    console.error(err.response?.data || err.message);
    res.status(500).json({ error: err.response?.data || err.message });
  }
});

// 2️⃣ Sync Tink transactions function (can be called separately)
exports.syncTinkTransactions = functions.https.onRequest(async (req, res) => {
  try {
    const { uid } = req.body;
    if (!uid) return res.status(400).json({ error: "uid required" });

    // Get stored access token
    const tokenSnap = await db.collection("tinkTokens").doc(uid).get();
    if (!tokenSnap.exists) return res.status(404).json({ error: "No token found" });

    const accessToken = tokenSnap.data().accessToken;

    const txCount = await syncTinkTransactionsInternal(uid, accessToken);

    res.json({ success: true, synced: txCount });
  } catch (err) {
    console.error(err.response?.data || err.message);
    res.status(500).json({ error: err.response?.data || err.message });
  }
});

// 🔹 Internal helper to fetch and save transactions
async function syncTinkTransactionsInternal(uid, accessToken) {
  const txRes = await axios.get("https://api.tink.com/data/v2/transactions", {
    headers: { Authorization: `Bearer ${accessToken}` },
  });

  const transactions = txRes.data.transactions || [];

  const batch = db.batch();
  transactions.forEach(tx => {
    const merchantName = tx.descriptions?.display || tx.descriptions?.original || "Unknown";
    const storeId = merchantName.toLowerCase().replace(/[^a-z0-9]/g, "");
    const merchantEntityId = tx.merchant?.id || null;
    const amount = tx.amount?.value?.unscaledValue
      ? tx.amount.value.unscaledValue / Math.pow(10, tx.amount.value.scale)
      : 0;
    const currency = tx.amount?.currencyCode || "USD";
    const date = tx.dates?.booked || tx.dates?.value || null;
    const pending = tx.status === "PENDING";
    const documentType = tx.personal_finance_category?.primary || "bank transaction";
    const storeLogo = tx.merchant?.logo || null;

    const docRef = db.collection("users").doc(uid).collection("documents").doc(tx.id);
    batch.set(
      docRef,
      {
        storeId,
        storeName: merchantName,
        merchantEntityId,
        amount,
        currency,
        date,
        pending,
        documentType,
        source: "bank",
        storeLogo,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  });

  await batch.commit();
  // 🎯 CHECK IF BANK DOCUMENT ALREADY SAVED TODAY
const startOfDay = new Date();
startOfDay.setHours(0, 0, 0, 0);

const endOfDay = new Date();
endOfDay.setHours(23, 59, 59, 999);

const todayDocs = await db
  .collection("users")
  .doc(uid)
  .collection("documents")
  .where("source", "==", "bank")
  .where("createdAt", ">=", startOfDay)
  .where("createdAt", "<=", endOfDay)
  .get();

// If this is the FIRST bank transaction today → add 100 points
if (todayDocs.size === transactions.length && transactions.length > 0) {
  await db.collection("users").doc(uid).set(
    {
      points: admin.firestore.FieldValue.increment(100),
    },
    { merge: true }
  );
}

  // ✅ Update user document to mark bank as connected
  await db.collection("users").doc(uid).set(
    {
      source: { bank: "connected" }
    },
    { merge: true }
  );

  return transactions.length;
}



exports.processIncomingEmail = onRequest(
  { secrets: ["OPENAI_API_KEY"] },
  (req, res) =>
    cors(req, res, async () => {
      try {
        const busboy = Busboy({ headers: req.headers });

        const fields = {};
        const files = [];

        // 🔹 Parse fields
        busboy.on("field", (name, value) => {
          fields[name] = value;
        });

        // 🔹 Parse attachments (optional)
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

            // ✅ MANUAL FORWARDING → sender is YOUR gmail
            const match = fromRaw.match(/<(.+?)>/);
            const senderEmail = match ? match[1] : fromRaw.trim();

            if (!senderEmail) {
              return res.status(400).json({ error: "Sender email not found" });
            }

            // 🔍 FIND USER BY SENDER EMAIL
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

            const fullText = `
FROM: ${senderEmail}
SUBJECT: ${subject}

${body}
            `;

            // 🧹 Save & delete attachments (no OCR yet)
            for (const file of files) {
              const tempPath = `temp/${Date.now()}-${file.filename}`;
              await bucket.file(tempPath).save(file.buffer, {
                contentType: file.mimeType,
              });
              await bucket.file(tempPath).delete().catch(() => {});
            }

            // 🔐 OPENAI CLASSIFICATION
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
  "documentType": "invoice | receipt | warranty | bank_transaction | unknown",
  "storeName": string | null,
  "merchantName": string | null,
  "confidence": number (0.0 - 1.0),
  "amount": number | null,
  "currency": string | null
  "storeLogo": 
- MUST be a direct URL ending with .png or .jpg
- If the official logo is only available as SVG → return null
- SVG logos are FORBIDDEN,
}

Rules:
- Ignore marketing/newsletters
- Bank alerts / transfers → documentType = "bank_transaction"
- Use sender + subject + body
- If not a financial document → documentType = "unknown"
- MUST be a direct URL ending with .png or .jpg
- If the official logo is only available as SVG → return null
- SVG logos are FORBIDDEN
- Extract store name from email body it is very important

- Extract amount as NUMBER if possible
- Extract currency like PKR, USD if present
- JSON ONLY, NO markdown

EMAIL:
${fullText}
                      `,
                    },
                  ],
                },
              ],
            });

            // 🧹 CLEAN RESPONSE
            let rawText = aiResponse.output_text || "";
            rawText = rawText.replace(/```json|```/g, "").trim();

            let extracted;
            try {
              extracted = JSON.parse(rawText);
            } catch (e) {
              return res.status(400).json({
                error: "Failed to parse AI response",
                rawText,
              });
            }

            // ❌ Ignore unsupported docs
            const allowedTypes = [
              "invoice",
              "receipt",
              "warranty",
              "bank_transaction",
            ];

            if (!allowedTypes.includes(extracted.documentType)) {
              return res.status(200).json({
                success: false,
                reason: "Unsupported document",
              });
            }

            // 💾 SAVE DOCUMENT
            const docRef = await db
              .collection("users")
              .doc(uid)
              .collection("documents")
              .add({
                source: "email",
                from: senderEmail,
                subject,
                body,
                documentType: extracted.documentType,
                storeName: extracted.storeName ?? "Unknown",
                merchantName: extracted.merchantName ?? null,
                storeLogo: extracted.storeLogo ?? null,
                amount: extracted.amount ?? null,
                currency: extracted.currency ?? null,
                confidence: extracted.confidence ?? 0.9,
                status: "done",
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
              });

            // 🔹 Mark email connected
            await db.collection("users").doc(uid).set(
              {
                source: { email: "connected" },
              },
              { merge: true }
            );
            // 🎯 CHECK IF EMAIL DOCUMENT ALREADY SAVED TODAY
const startOfDay = new Date();
startOfDay.setHours(0, 0, 0, 0);

const endOfDay = new Date();
endOfDay.setHours(23, 59, 59, 999);

const todayDocs = await db
  .collection("users")
  .doc(uid)
  .collection("documents")
  .where("source", "==", "email")
  .where("createdAt", ">=", startOfDay)
  .where("createdAt", "<=", endOfDay)
  .get();

// If this is the FIRST email document today → add 100 points
if (todayDocs.size === 1) {
  await db.collection("users").doc(uid).set(
    {
      points: admin.firestore.FieldValue.increment(100),
    },
    { merge: true }
  );
}

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
    })
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
        const { uid, imageUrl, filetype } = req.body;

        if (!uid || !imageUrl || !filetype) {
          return res.status(400).json({
            error: "uid, imageUrl, and filetype are required",
          });
        }

        const openai = new OpenAI({
          apiKey: process.env.OPENAI_API_KEY,
        });

        // 🔹 Set input type based on filetype
        let fileInput;
        if (filetype === "image") {
          fileInput = {
            type: "input_image",
            image_url: imageUrl,
          };
        } else if (filetype === "pdf") {
          fileInput = {
            type: "input_file",
            file_url: imageUrl,
          };
        } else {
          return res.status(400).json({ error: "Invalid filetype" });
        }

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
Analyze this file and return VALID JSON ONLY.

{
  "documentType": "invoice | receipt | warranty | subscription | unknown",
  "storeName": string | null,
  "merchantName": string | null,
  "amount": number | null,
  "currency": string | null,
  "date": "YYYY-MM-DD" | null,
storeLogo:
- MUST be a direct URL ending with .png or .jpg
- If the official logo is only available as SVG → return null
- SVG logos are FORBIDDEN
}

Rules:
- MUST be a direct URL ending with .png or .jpg
- If the official logo is only available as SVG → return null
- SVG logos are FORBIDDEN
- If not a valid document → documentType = "unknown"
- DO NOT add explanations or markdown.

- Normalize store names:
  - Remove suffixes like "Inc", "Ltd", "LLC", "Corp", "Store", "Company"
  - Convert variations to a single common brand name
  - Example:
    - "Apple Inc", "Apple Store" → "Apple"
    - "Google LLC", "Google Payments", "Google Cloud" → "Google"
    - "Amazon.com", "Amazon EU" → "Amazon"
  - Always return a clean, short, canonical brand name in "merchantName"
`,
                },
                fileInput,
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

        // ✅ 🔥 FIX: Merchant fallback + normalization
        let merchant =
          extracted.merchantName ||
          extracted.storeName ||
          null;

        if (!merchant) {
          merchant = "Unknown";
        }

        if (merchant) {
          merchant = merchant
            .replace(/\b(inc|ltd|llc|corp|store|company)\b/gi, "")
            .trim();

          merchant =
            merchant.charAt(0).toUpperCase() +
            merchant.slice(1);
        }

        // 🔹 Save to Firestore
        const docRef = await db
          .collection("users")
          .doc(uid)
          .collection("documents")
          .add({
            source: "ocr",
            imageUrl,
            documentType: extracted.documentType,
            storeName: merchant,
            storeLogo: validLogo,
            merchantName: merchant,
            amount: extracted.amount ?? null,
            currency: extracted.currency ?? null,
            date: extracted.date ?? null,
            confidence: 0.9,
            status: "done",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            fileformat: filetype,
          });

        // 🔹 Mark OCR connected
        await db.collection("users").doc(uid).set(
          {
            source: { ocr: "connected" },
          },
          { merge: true }
        );

        // 🎯 Check today's OCR documents
        const startOfDay = new Date();
        startOfDay.setHours(0, 0, 0, 0);
        const endOfDay = new Date();
        endOfDay.setHours(23, 59, 59, 999);

        const todayDocs = await db
          .collection("users")
          .doc(uid)
          .collection("documents")
          .where("source", "==", "ocr")
          .where("createdAt", ">=", startOfDay)
          .where("createdAt", "<=", endOfDay)
          .get();

        if (todayDocs.size === 1) {
          await db.collection("users").doc(uid).set(
            {
              points: admin.firestore.FieldValue.increment(100),
            },
            { merge: true }
          );
        }

        return res.status(200).json({
          success: true,
          documentId: docRef.id,
          data: {
            ...extracted,
            storeLogo: validLogo,
          },
        });
      } catch (error) {
        await db.collection("errors").doc(uid).set({ "": error });
        console.error("OCR Function Error:", error);
        return res.status(500).json({
          error: error.message,
        });
      }
    })
);



