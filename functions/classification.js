const STORES = require("./storeDictionary");

function normalizeText(text = "") {
  return text.toLowerCase().replace(/\s+/g, " ");
}

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
        confidence: 0.9
      };
    }
  }

  return {
    storeId: "unknown",
    storeName: "Unknown",
    confidence: 0.1
  };
}

function detectDocumentType(text = "") {
  text = normalizeText(text);

  if (/(invoice|facture|bill)/.test(text)) return "invoice";
  if (/(receipt|paid|payment)/.test(text)) return "receipt";
  if (/(warranty|guarantee)/.test(text)) return "warranty";

  return "unknown";
}

module.exports = { detectStore, detectDocumentType };
