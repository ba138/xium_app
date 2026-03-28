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

            const match = fromRaw.match(/<(.+?)>/);
            const senderEmail = match ? match[1] : fromRaw.trim();

            if (!senderEmail) {
              return res.status(400).json({ error: "Sender email not found" });
            }

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

            for (const file of files) {
              const tempPath = `temp/${Date.now()}-${file.filename}`;
              await bucket.file(tempPath).save(file.buffer, {
                contentType: file.mimeType,
              });
              await bucket.file(tempPath).delete().catch(() => {});
            }

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
  "type": "input_text",
  "text": `
Analyze this EMAIL and return VALID JSON ONLY.

{
  "documentType": "invoice | receipt | warranty | bank_transaction | subscription | unknown",
  "storeName": string | null,
  "merchantName": string | null,
  "confidence": number (0.0 - 1.0),
  "amount": number | null,
  "currency": string | null,
  "storeLogo": string | null
}
- Normalize store names:
  - Remove suffixes like "Inc", "Ltd", "LLC", "Corp", "Store", "Company"
  - Convert variations to a single common brand name
  - Example:
    - "Apple Inc", "Apple Store", "Apple Music" → "Apple"
    - "Google LLC", "Google Payments", "Google Cloud" → "Google"
    - "Amazon.com", "Amazon EU" → "Amazon"
Rules:
- Ignore marketing/newsletters
- Bank alerts / transfers → documentType = "bank_transaction"
- Use sender + subject + body
- If not a financial document → documentType = "unknown"

- IMPORTANT: Convert ALL detected amounts to EURO (EUR)
  - If the email contains any currency (e.g., PKR, USD, GBP), convert it to EUR using a reasonable current market rate
  - Example: 2000 PKR → convert to EUR
  - Always return the converted value in "amount"
  - Always set "currency" = "EUR"

storeLogo:
- MUST be a valid, direct image URL ending with .png or .jpg
- DO NOT return SVG logos under any condition
- If the official logo is only available in SVG format → return null
- DO NOT guess, generate, or construct a logo URL
- ONLY return a logo URL if it is a real, publicly accessible image
- If unsure or not found → return null

- Extract store name from email body it is very important
- Extract amount as NUMBER if possible
- Extract currency like PKR, USD if present
- JSON ONLY, NO markdown

EMAIL:
\${fullText}
`
}
                  ],
                },
              ],
            });

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

            const allowedTypes = [
              "invoice",
              "receipt",
              "warranty",
              "bank_transaction",
              "subscription",
            ];

            if (!allowedTypes.includes(extracted.documentType)) {
              return res.status(200).json({
                success: false,
                reason: "Unsupported document",
              });
            }

            // ✅ SAME LOGIC ADDED HERE
        let validLogo = await validateLogoUrl(extracted.storeLogo);

            if (!validLogo) {
              const logos = {
            Google: "https://cdn2.hubspot.net/hubfs/53/image8-2.jpg",
            Netflix: "https://static.vecteezy.com/system/resources/previews/017/396/814/non_2x/netflix-mobile-application-logo-free-png.png",
            Facebook: "https://img.freepik.com/premium-photo/facebook-logo_1080029-107.jpg?semt=ais_hybrid&w=740&q=80",
            Apple: "https://1000logos.net/wp-content/uploads/2016/10/Apple-Logo.png",
            Amazon: "https://thumbs.dreamstime.com/b/amazon-logo-amazon-logo-white-background-vector-format-avaliable-124289859.jpg",
            Microsoft: "https://msblogs.thesourcemediaassets.com/2012/08/8867.Microsoft_5F00_Logo_2D00_for_2D00_screen.jpg",
            Instagram:"https://img.freepik.com/premium-psd/instagram-application-logo_23-2151544088.jpg?semt=ais_hybrid&w=740&q=80",
            WhatsApp: "https://img.freepik.com/premium-psd/instagram-application-logo_23-2151544088.jpg?semt=ais_hybrid&w=740&q=80",
            Spotify: "https://cdn.pixabay.com/photo/2016/10/22/00/15/spotify-1759471_1280.jpg",
            YouTube: "https://logo.clearbit.com/youtube.com",
  Twitter: "https://img.freepik.com/free-vector/new-2023-twitter-logo-x-icon-design_1017-45418.jpg?semt=ais_hybrid&w=740&q=80",
  TikTok: "https://img.freepik.com/premium-vector/vector-set-realistic-isolated-blank-price-tag-coupons-discount-vector-illustration_561158-2220.jpg?semt=ais_hybrid&w=740&q=80",
  LinkedIn: "https://img.freepik.com/premium-vector/linkedin-logo-icon_1273375-1174.jpg?semt=ais_hybrid&w=740&q=80",
  Snapchat: "https://img.freepik.com/premium-photo/square-snapchat-logo-isolated-white-background_469489-1032.jpg?semt=ais_hybrid&w=740&q=80",
  Uber: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSaI0-AaIAcwVCkcnR8xdetso-wz9rCOVJB5Q&s",
  Airbnb: "https://s3.us-east-1.amazonaws.com/cdn.designcrowd.com/blog/airbnb-logo-history/Color-Airbnb-Logo.jpg",
  PayPal: "https://i.pinimg.com/736x/7c/e7/97/7ce797e044a880eb6d74bdec009343bf.jpg",
  Visa: "https://www.logo.wine/a/logo/Visa_Inc./Visa_Inc.-Logo.wine.svg",
  Mastercard: "https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg",
  Samsung: "https://static.vecteezy.com/system/resources/previews/020/975/545/non_2x/samsung-logo-samsung-icon-transparent-free-png.png",
  Sony: "https://1000logos.net/wp-content/uploads/2017/06/Sony-Logo.jpg",
  Intel: "https://logos-world.net/wp-content/uploads/2021/09/Intel-Logo-2006-2020-700x394.png",
  Adobe: "https://1000logos.net/wp-content/uploads/2016/10/Adobe-Logo-1993.jpg",
  Walmart: "https://cdn.mos.cms.futurecdn.net/5StAbRHLA4ZdyzQZVivm2c.jpg",
  eBay: "https://1000logos.net/wp-content/uploads/2018/10/Ebay-logo.jpg",
  Alibaba: "https://images.seeklogo.com/logo-png/0/2/alibaba-com-logo-png_seeklogo-6545.png",
  Zara: "https://static.vecteezy.com/system/resources/thumbnails/024/131/336/small/zara-brand-logo-symbol-clothes-black-design-icon-abstract-illustration-free-vector.jpg",
  Nike: "https://thumbs.dreamstime.com/b/vector-logos-collection-most-famous-fashion-brands-world-format-available-illustrator-ai-nike-logo-119869268.jpg",
  Adidas: "https://static.vecteezy.com/system/resources/thumbnails/014/414/689/small/adidas-new-logo-on-transparent-background-free-vector.jpg",
  Tesla: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Tesla_logo.png/500px-Tesla_logo.png"
          };

              let storeKey =
                extracted.merchantName ||
                extracted.storeName ||
                "";

              storeKey = storeKey.trim().toLowerCase();

              const match = Object.keys(logos).find((key) =>
                storeKey.includes(key.toLowerCase())
              );

              if (match) {
                validLogo = logos[match];
              }
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
                storeLogo: validLogo,
                amount: extracted.amount ?? null,
                currency: extracted.currency ?? null,
                confidence: extracted.confidence ?? 0.9,
                status: "done",
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
              });

            await db.collection("users").doc(uid).set(
              {
                source: { email: "connected" },
              },
              { merge: true }
            );

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
  "type": "input_text",
  "text": `
Analyze this file and return VALID JSON ONLY.

{
  "documentType": "invoice | receipt | warranty | subscription | unknown",
  "storeName": string | null,
  "merchantName": string | null,
  "amount": number | null,
  "currency": string | null,
  "date": "YYYY-MM-DD" | null,
  "storeLogo": string | null
}

Rules:
storeLogo:
- MUST be a valid, direct image URL ending with .png or .jpg
- DO NOT return SVG logos under any condition
- If the official logo is only available in SVG format → return null
- DO NOT guess, generate, or construct a logo URL
- ONLY return a logo URL if it is a real, publicly accessible image
- If unsure or not found → return null

- IMPORTANT: Convert ALL detected amounts to EURO (EUR)
  - If the document contains any currency (e.g., PKR, USD, GBP), convert it to EUR using a reasonable current market rate
  - Always return the converted value in "amount"
  - Always set "currency" = "EUR"

- If not a valid document → documentType = "unknown"
- DO NOT add explanations or markdown

- Normalize store names:
  - Remove suffixes like "Inc", "Ltd", "LLC", "Corp", "Store", "Company"
  - Convert variations to a single common brand name
  - Example:
    - "Apple Inc", "Apple Store", "Apple Music" → "Apple"
    - "Google LLC", "Google Payments", "Google Cloud" → "Google"
    - "Amazon.com", "Amazon EU" → "Amazon"
  - Always return a clean, short, canonical brand name in "merchantName"

Return ONLY JSON.
`
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
        let validLogo = await validateLogoUrl(extracted.storeLogo);

        // 🔥 NEW: Fallback logo logic (ONLY ADDITION)
        if (!validLogo) {
          const logos = {
            Google: "https://cdn2.hubspot.net/hubfs/53/image8-2.jpg",
            Netflix: "https://static.vecteezy.com/system/resources/previews/017/396/814/non_2x/netflix-mobile-application-logo-free-png.png",
            Facebook: "https://img.freepik.com/premium-photo/facebook-logo_1080029-107.jpg?semt=ais_hybrid&w=740&q=80",
            Apple: "https://1000logos.net/wp-content/uploads/2016/10/Apple-Logo.png",
            Amazon: "https://thumbs.dreamstime.com/b/amazon-logo-amazon-logo-white-background-vector-format-avaliable-124289859.jpg",
            Microsoft: "https://msblogs.thesourcemediaassets.com/2012/08/8867.Microsoft_5F00_Logo_2D00_for_2D00_screen.jpg",
            Instagram:"https://img.freepik.com/premium-psd/instagram-application-logo_23-2151544088.jpg?semt=ais_hybrid&w=740&q=80",
            WhatsApp: "https://img.freepik.com/premium-psd/instagram-application-logo_23-2151544088.jpg?semt=ais_hybrid&w=740&q=80",
            Spotify: "https://cdn.pixabay.com/photo/2016/10/22/00/15/spotify-1759471_1280.jpg",
            YouTube: "https://logo.clearbit.com/youtube.com",
  Twitter: "https://img.freepik.com/free-vector/new-2023-twitter-logo-x-icon-design_1017-45418.jpg?semt=ais_hybrid&w=740&q=80",
  TikTok: "https://img.freepik.com/premium-vector/vector-set-realistic-isolated-blank-price-tag-coupons-discount-vector-illustration_561158-2220.jpg?semt=ais_hybrid&w=740&q=80",
  LinkedIn: "https://img.freepik.com/premium-vector/linkedin-logo-icon_1273375-1174.jpg?semt=ais_hybrid&w=740&q=80",
  Snapchat: "https://img.freepik.com/premium-photo/square-snapchat-logo-isolated-white-background_469489-1032.jpg?semt=ais_hybrid&w=740&q=80",
  Uber: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSaI0-AaIAcwVCkcnR8xdetso-wz9rCOVJB5Q&s",
  Airbnb: "https://s3.us-east-1.amazonaws.com/cdn.designcrowd.com/blog/airbnb-logo-history/Color-Airbnb-Logo.jpg",
  PayPal: "https://i.pinimg.com/736x/7c/e7/97/7ce797e044a880eb6d74bdec009343bf.jpg",
  Visa: "https://www.logo.wine/a/logo/Visa_Inc./Visa_Inc.-Logo.wine.svg",
  Mastercard: "https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg",
  Samsung: "https://static.vecteezy.com/system/resources/previews/020/975/545/non_2x/samsung-logo-samsung-icon-transparent-free-png.png",
  Sony: "https://1000logos.net/wp-content/uploads/2017/06/Sony-Logo.jpg",
  Intel: "https://logos-world.net/wp-content/uploads/2021/09/Intel-Logo-2006-2020-700x394.png",
  Adobe: "https://1000logos.net/wp-content/uploads/2016/10/Adobe-Logo-1993.jpg",
  Walmart: "https://cdn.mos.cms.futurecdn.net/5StAbRHLA4ZdyzQZVivm2c.jpg",
  eBay: "https://1000logos.net/wp-content/uploads/2018/10/Ebay-logo.jpg",
  Alibaba: "https://images.seeklogo.com/logo-png/0/2/alibaba-com-logo-png_seeklogo-6545.png",
  Zara: "https://static.vecteezy.com/system/resources/thumbnails/024/131/336/small/zara-brand-logo-symbol-clothes-black-design-icon-abstract-illustration-free-vector.jpg",
  Nike: "https://thumbs.dreamstime.com/b/vector-logos-collection-most-famous-fashion-brands-world-format-available-illustrator-ai-nike-logo-119869268.jpg",
  Adidas: "https://static.vecteezy.com/system/resources/thumbnails/014/414/689/small/adidas-new-logo-on-transparent-background-free-vector.jpg",
  Tesla: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Tesla_logo.png/500px-Tesla_logo.png"
          };

          let storeKey =
            extracted.merchantName ||
            extracted.storeName ||
            "";

          storeKey = storeKey.trim().toLowerCase();

          const match = Object.keys(logos).find((key) =>
            storeKey.includes(key.toLowerCase())
          );

          if (match) {
            validLogo = logos[match];
          }
        }

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



