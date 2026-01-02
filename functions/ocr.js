const vision = require("@google-cloud/vision");
const client = new vision.ImageAnnotatorClient();

async function runOCR(gcsUrl) {
  const [result] = await client.textDetection(gcsUrl);
  return result.fullTextAnnotation?.text || "";
}

module.exports = { runOCR };
