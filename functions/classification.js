const STORES = require("./storeDictionary");

/**
 * Normalize text for matching
 */
function normalizeText(text = "") {
  return text.toLowerCase().replace(/\s+/g, " ");
}

/**
 * Detect store from email + content
 */
function detectStore(from = "", subject = "", text = "") {
  const content = normalizeText(`${from} ${subject} ${text}`);

  for (const store of Object.values(STORES)) {
    if (
      store.keywords.some(k => content.includes(k)) ||
      store.domains.some(d => content.includes(d))
    ) {
      return {
        storeId: store.storeId,
        storeName: store.name,
        storeLogo: store.storeLogo || null,
        confidence: 0.9,
      };
    }
  }

  return {
    storeId: "unknown",
    storeName: "Unknown",
    storeLogo: null,
    confidence: 0.1,
  };
}

/**
 * Detect document type
 */
function detectDocumentType(text = "") {
  text = normalizeText(text);

  if (/(invoice|facture|bill)/.test(text)) return "invoice";
  if (/(receipt|paid|payment)/.test(text)) return "receipt";
  if (/(warranty|guarantee)/.test(text)) return "warranty";

  return "unknown";
}

module.exports = { detectStore, detectDocumentType };
