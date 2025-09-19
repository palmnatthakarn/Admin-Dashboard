// server.js
"use strict";

const express = require("express");
const cors = require("cors");
const fs = require("fs").promises;
const path = require("path");

const app = express();

// ===== Config =====
const PORT = parseInt(process.env.PORT, 10) || 3000;
const MAX_PER_PAGE = parseInt(process.env.MAX_PER_PAGE, 10) || 200;
const PRODUCTS_PATH =
  process.env.PRODUCTS_PATH ||
  path.join(__dirname, "..", "assets", "products_real.json");

// ===== Middleware =====
app.use(cors());
app.use(express.json());

// ===== In-memory store =====
let products = { data: [], pagination: {} };
let dealers = { data: [], pagination: {} };

// Indexes for fast filtering
let dealerIndex = new Map(); // dealer_code -> array of product indices
let dealerData = new Map(); // dealer_code -> dealer info
let dataReady = false;

// Build derived data: search fields, indexes
function buildIndexes() {
  dealerIndex = new Map();
  dealerData = new Map();

  // Define dealer names mapping
  const dealerNames = {
    EZ978: "Top Store",
    QC759: "Golden Market",
    WW013: "Premium Plaza",
    LW097: "Fresh Mart",
    TX140: "Super Center",
    LF413: "Quality Shop",
    MK256: "Best Buy",
    RT891: "Corner Store",
    PL634: "Mega Mall",
    VN472: "Local Market",
  };

  // add __search field and build product indexes
  products.data.forEach((p, i) => {
    const name = (p.name || "").toString().toLowerCase();
    const item = (p.item_code || "").toString().toLowerCase();
    const barcode = (p.barcode ?? "").toString().toLowerCase();
    p.__search = `${name} ${item} ${barcode}`;

    const code = (p.dealer_code ?? "").toString();

    // สร้าง dealer data จากข้อมูล products จริง
    if (!dealerData.has(code) && code) {
      dealerData.set(code, {
        dealer_code: code,
        dealer_name: dealerNames[code] || `Dealer ${code}`,
      });
    }

    // สร้าง dealer index
    if (!dealerIndex.has(code)) {
      dealerIndex.set(code, []);
    }
    dealerIndex.get(code).push(i);
  });

  // Build dealers response - เฉพาะ dealers ที่มี products
  const dealersWithProducts = Array.from(dealerData.values())
    .filter((dealer) => dealerIndex.get(dealer.dealer_code).length > 0)
    .sort((a, b) => a.dealer_code.localeCompare(b.dealer_code));

  dealers = {
    data: dealersWithProducts,
    pagination: {
      resource: "dealers",
      page: 1,
      per_page: dealersWithProducts.length,
      total: dealersWithProducts.length,
      total_pages: 1,
    },
  };

  // Debug: Log dealer index
  console.log(`🏷️  Dealer index built with ${dealerIndex.size} dealers:`);
  for (const [code, indices] of dealerIndex.entries()) {
    console.log(`   ${code}: ${indices.length} products`);
    // Show sample products for each dealer
    if (indices.length > 0) {
      const sampleProducts = indices.slice(0, 2).map((i) => {
        const p = products.data[i];
        return `${p.item_code}:${p.name}`;
      });
      console.log(`      Sample: ${sampleProducts.join(", ")}`);
    } else {
      console.log(`      ⚠️  No products found for dealer ${code}`);
    }
  }

  console.log(
    `📊 Dealers with products: ${
      Array.from(dealerIndex.entries()).filter(
        ([code, indices]) => indices.length > 0
      ).length
    }`
  );
  console.log(
    `📊 Dealers without products: ${
      Array.from(dealerIndex.entries()).filter(
        ([code, indices]) => indices.length === 0
      ).length
    }`
  );
}

// Generate dealer name from dealer code
function generateDealerName(dealerCode) {
  // Updated to match actual dealer codes in products.json
  const dealerNames = {
    EZ978: "Top Store",
    QC759: "Golden Market",
    WW013: "Premium Plaza",
    LW097: "Fresh Mart",
    TX140: "Super Center",
    LF413: "Quality Shop",
    MK256: "Best Buy",
    RT891: "Corner Store",
    PL634: "Mega Mall",
    VN472: "Local Market",
  };

  return dealerNames[dealerCode] || `Dealer ${dealerCode}`;
}

// Load JSON asynchronously (non-blocking)
async function loadData() {
  console.time("load:data");
  try {
    // Load products data
    console.log(`📁 Loading products from: ${PRODUCTS_PATH}`);
    const productsRaw = await fs.readFile(PRODUCTS_PATH, "utf8");
    const productsJson = JSON.parse(productsRaw);
    console.log(`📄 File content preview: ${productsRaw.substring(0, 200)}...`);

    // Expecting { data: [...], pagination: {...} }
    if (!productsJson || !Array.isArray(productsJson.data)) {
      throw new Error(
        "Invalid products JSON structure: expected { data: [], pagination: {} }"
      );
    }
    products = productsJson;

    // Dealers will be built from products data in buildIndexes()

    buildIndexes();
    dataReady = true;

    console.timeEnd("load:data");
    console.log(
      `📊 Loaded ${products.data.length} products from ${PRODUCTS_PATH}`
    );
    console.log(
      `🏪 Generated ${dealers.data.length} dealers from products data`
    );
    console.log(`🏷️  Dealers indexed: ${dealerIndex.size}`);
  } catch (err) {
    console.timeEnd("load:data");
    console.error("❌ Failed to load data:", err.message);
    console.log("📝 Falling back to empty dataset");
    products = {
      data: [],
      pagination: {
        resource: "products",
        page: 1,
        per_page: 10,
        total: 0,
        total_pages: 1,
      },
    };
    dealers = {
      data: [],
      pagination: {
        resource: "dealers",
        page: 1,
        per_page: 0,
        total: 0,
        total_pages: 1,
      },
    };
    dealerIndex = new Map();
    dealerData = new Map();
    dataReady = true; // ยังให้บริการได้ (ชุดว่าง)
  }
}

// Gate requests until data-ready
function ensureDataLoaded(req, res, next) {
  if (!dataReady) {
    return res.status(503).json({
      success: false,
      message: "Data is loading, please retry shortly.",
    });
  }
  next();
}

app.use(ensureDataLoaded);

// ===== Routes =====
app.get("/api/products", (req, res) => {
  let {
    page = "1",
    per_page = "10",
    search = "",
    dealer_code = "",
  } = req.query;

  // sanitize numbers
  let pageNum = Number.parseInt(page, 10);
  let perPageNum = Number.parseInt(per_page, 10);
  if (!Number.isFinite(pageNum) || pageNum < 1) pageNum = 1;
  if (!Number.isFinite(perPageNum) || perPageNum < 1) perPageNum = 10;
  perPageNum = Math.min(perPageNum, MAX_PER_PAGE);

  let subset;

  const code = dealer_code.toString().trim();
  console.log(
    `🔍 API Request - dealer_code: "${code}", search: "${search}", page: ${pageNum}`
  );

  if (code) {
    const idxs = dealerIndex.get(code) || [];
    console.log(`   Found ${idxs.length} product indices for dealer ${code}`);
    subset = idxs.map((i) => products.data[i]);
    console.log(`   Mapped to ${subset.length} products`);

    // Debug: Show first few products
    if (subset.length > 0) {
      console.log(`   Sample products for dealer ${code}:`);
      subset.slice(0, 3).forEach((p) => {
        console.log(
          `      - ${p.item_code}: ${p.name} (dealer: ${p.dealer_code})`
        );
      });
    }
  } else {
    subset = products.data; // no spread -> no copy
    console.log(`   No dealer filter - using all ${subset.length} products`);
  }

  const q = search.toString().trim().toLowerCase();
  if (q) {
    const beforeSearch = subset.length;
    subset = subset.filter((p) => p.__search?.includes(q));
    console.log(
      `   Search "${q}" filtered from ${beforeSearch} to ${subset.length} products`
    );
  }

  const total = subset.length;
  const totalPages = Math.max(1, Math.ceil(total / perPageNum));
  const start = (pageNum - 1) * perPageNum;
  const data = subset.slice(start, start + perPageNum);

  console.log(
    `   Final result: ${data.length} products (page ${pageNum}/${totalPages}, total: ${total})`
  );

  res.json({
    pagination: {
      resource: "products",
      page: pageNum,
      per_page: perPageNum,
      total,
      total_pages: totalPages,
      next_page: pageNum < totalPages ? pageNum + 1 : null,
      prev_page: pageNum > 1 ? pageNum - 1 : null,
    },
    data,
  });
});

app.get("/api/dealers", (req, res) => {
  res.json(dealers);
});

app.put("/api/products/:itemCode/price", (req, res) => {
  const { itemCode } = req.params;
  const { price_index, price } = req.body || {};

  if (price_index === undefined || price === undefined) {
    return res
      .status(400)
      .json({ success: false, message: "price_index and price are required." });
  }

  const product = products.data.find((p) => p.item_code === itemCode);
  if (!product) {
    return res
      .status(404)
      .json({ success: false, message: "Product not found." });
  }
  if (!product.prices || product.prices.length === 0) {
    return res
      .status(400)
      .json({ success: false, message: "Product has no prices." });
  }

  const idx = Number(price_index);
  if (!Number.isFinite(idx) || idx < 1) {
    return res
      .status(400)
      .json({ success: false, message: "Invalid price_index." });
  }

  const priceObj = product.prices[0];
  const key = `price_${idx}`;
  if (!(key in priceObj)) {
    return res
      .status(400)
      .json({ success: false, message: "Invalid price index key." });
  }

  const newPrice = Number(price);
  if (!Number.isFinite(newPrice) || newPrice < 0) {
    return res
      .status(400)
      .json({ success: false, message: "Invalid price value." });
  }

  priceObj[key] = newPrice;

  res.json({
    success: true,
    message: "Price updated successfully.",
    updated_price: {
      item_code: itemCode,
      price_index: idx,
      new_price: newPrice,
    },
  });
});

// Health check (with status info)
app.get("/health", (req, res) => {
  res.json({
    status: "OK",
    data_ready: dataReady,
    products: products.data.length,
    dealers: dealers.data.length,
    timestamp: new Date().toISOString(),
  });
});

// ===== Start =====
const server = app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 API Server running on http://0.0.0.0:${PORT}`);
  console.log("🛣️  Endpoints:");
  console.log("   GET  /api/products?dealer_code=&search=&page=&per_page=");
  console.log("   GET  /api/dealers");
  console.log("   PUT  /api/products/:itemCode/price  { price_index, price }");
  console.log("   GET  /health");
});

// Graceful shutdown
function shutdown(sig) {
  console.log(`\n${sig} received, shutting down...`);
  server.close(() => {
    console.log("HTTP server closed.");
    process.exit(0);
  });
  // force-exit after timeout
  setTimeout(() => process.exit(1), 5000).unref();
}
process.on("SIGINT", () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));

// kick off async data loading (non-blocking)
loadData();
