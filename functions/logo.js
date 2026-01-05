const axios = require("axios");

/**
 * Dynamically resolve store logo
 * Priority:
 * 1. Plaid Merchant API
 * 2. Clearbit
 * 3. Google favicon
 */
async function getStoreLogo({ plaidClient, merchantEntityId, website }) {
  try {
    // 1️⃣ Try Plaid Merchant API
    if (merchantEntityId) {
      try {
        const res = await plaidClient.merchantsGet({
          merchant_ids: [merchantEntityId],
        });

        const merchant = res.data.merchants?.[0];

        if (merchant?.logo_url) return merchant.logo_url;
        if (!website && merchant?.website) website = merchant.website;
      } catch (_) {}
    }

    if (!website) return null;

    const domain = new URL(website).hostname;

    // 2️⃣ Clearbit
    try {
      const clearbitUrl = `https://logo.clearbit.com/${domain}`;
      const r = await axios.get(clearbitUrl, { timeout: 3000 });
      if (r.status === 200) return clearbitUrl;
    } catch (_) {}

    // 3️⃣ Google favicon fallback
    return `https://www.google.com/s2/favicons?domain=${domain}&sz=128`;
  } catch (_) {
    return null;
  }
}

module.exports = { getStoreLogo };
