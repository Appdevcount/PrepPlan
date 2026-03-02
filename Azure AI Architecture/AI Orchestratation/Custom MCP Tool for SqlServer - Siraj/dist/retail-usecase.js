import { handleToolCall } from "./index.js";
// ===== RETAIL USE CASE =====
// E-commerce inventory management system
async function retailUseCaseDemo() {
    console.log("\n" + "=".repeat(70));
    console.log("🛍️  RETAIL USE CASE: E-COMMERCE INVENTORY & SALES MANAGEMENT");
    console.log("=".repeat(70));
    // Step 1: Connect
    console.log("\n📍 SETUP: Connect to inventory database\n");
    await handleToolCall({
        params: {
            name: "connect_database",
            arguments: { type: "sqlite", path: ":memory:" },
        },
    });
    console.log("✅ Connected\n");
    // Step 2: Create retail schema
    console.log("📍 Creating retail database schema...\n");
    // Products table
    await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `CREATE TABLE products (
          product_id INTEGER PRIMARY KEY,
          product_name TEXT NOT NULL,
          category TEXT,
          price REAL,
          current_stock INTEGER,
          reorder_level INTEGER,
          supplier_id INTEGER
        )`,
            },
        },
    });
    // Orders table
    await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `CREATE TABLE orders (
          order_id INTEGER PRIMARY KEY,
          customer_id INTEGER,
          order_date TEXT,
          total_amount REAL,
          status TEXT
        )`,
            },
        },
    });
    // Order items table
    await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `CREATE TABLE order_items (
          item_id INTEGER PRIMARY KEY,
          order_id INTEGER,
          product_id INTEGER,
          quantity INTEGER,
          unit_price REAL
        )`,
            },
        },
    });
    console.log("✅ Schema created\n");
    // Step 3: Insert retail data
    console.log("📍 Inserting product inventory...\n");
    await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `INSERT INTO products VALUES
          (101, 'Wireless Headphones', 'Electronics', 89.99, 45, 10, 1),
          (102, 'USB-C Cable', 'Electronics', 12.99, 200, 50, 2),
          (103, 'Phone Case', 'Accessories', 19.99, 120, 30, 3),
          (104, 'Screen Protector', 'Accessories', 8.99, 300, 100, 2),
          (105, 'Portable Charger', 'Electronics', 34.99, 8, 15, 1),
          (106, 'Laptop Stand', 'Accessories', 29.99, 25, 10, 4),
          (107, 'Bluetooth Speaker', 'Electronics', 59.99, 3, 10, 1),
          (108, 'Webcam HD', 'Electronics', 49.99, 0, 5, 5)`,
            },
        },
    });
    console.log("✅ Products loaded (8 items)\n");
    await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `INSERT INTO orders VALUES
          (1001, 501, '2026-01-10', 189.97, 'Delivered'),
          (1002, 502, '2026-01-09', 134.98, 'Shipped'),
          (1003, 503, '2026-01-08', 354.95, 'Delivered'),
          (1004, 504, '2026-01-11', 79.98, 'Processing'),
          (1005, 505, '2026-01-11', 244.98, 'Pending')`,
            },
        },
    });
    console.log("✅ Orders loaded (5 orders)\n");
    await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `INSERT INTO order_items VALUES
          (1, 1001, 101, 2, 89.99),
          (2, 1001, 103, 1, 19.99),
          (3, 1002, 102, 5, 12.99),
          (4, 1002, 104, 2, 8.99),
          (5, 1003, 106, 1, 29.99),
          (6, 1003, 105, 1, 34.99),
          (7, 1003, 101, 3, 89.99),
          (8, 1004, 107, 1, 59.99),
          (9, 1004, 103, 1, 19.99),
          (10, 1005, 102, 10, 12.99),
          (11, 1005, 106, 3, 29.99)`,
            },
        },
    });
    console.log("✅ Order items loaded (11 line items)\n");
    // QUERY 1: Low stock alert
    console.log("\n" + "─".repeat(70));
    console.log("🚨 QUERY 1: LOW STOCK ALERT - Items below reorder level");
    console.log("─".repeat(70) + "\n");
    const lowStockResponse = await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT product_id, product_name, category, current_stock, 
                      reorder_level, (reorder_level - current_stock) as shortage
               FROM products 
               WHERE current_stock <= reorder_level
               ORDER BY shortage DESC`,
            },
        },
    });
    console.log("📊 Items needing reorder:");
    console.log(lowStockResponse.content[0].text);
    // QUERY 2: Revenue by category (last 24 hours)
    console.log("\n" + "─".repeat(70));
    console.log("💰 QUERY 2: SALES PERFORMANCE - Revenue by category today");
    console.log("─".repeat(70) + "\n");
    const revenueResponse = await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT p.category, 
                      COUNT(DISTINCT o.order_id) as order_count,
                      SUM(oi.quantity) as total_units,
                      ROUND(SUM(oi.quantity * oi.unit_price), 2) as revenue,
                      ROUND(AVG(oi.unit_price), 2) as avg_price
               FROM order_items oi
               JOIN products p ON oi.product_id = p.product_id
               JOIN orders o ON oi.order_id = o.order_id
               WHERE o.order_date >= date('now', '-1 day')
               GROUP BY p.category
               ORDER BY revenue DESC`,
            },
        },
    });
    console.log("📈 Category performance:");
    console.log(revenueResponse.content[0].text);
    // QUERY 3: Top selling products
    console.log("\n" + "─".repeat(70));
    console.log("⭐ QUERY 3: TOP SELLING PRODUCTS - By units sold");
    console.log("─".repeat(70) + "\n");
    const topProductsResponse = await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT p.product_name, 
                      SUM(oi.quantity) as total_sold,
                      ROUND(SUM(oi.quantity * oi.unit_price), 2) as total_revenue,
                      COUNT(DISTINCT oi.order_id) as order_frequency,
                      ROUND(AVG(p.price), 2) as price
               FROM order_items oi
               JOIN products p ON oi.product_id = p.product_id
               GROUP BY p.product_id
               ORDER BY total_sold DESC
               LIMIT 5`,
            },
        },
    });
    console.log("🏆 Top 5 sellers:");
    console.log(topProductsResponse.content[0].text);
    // QUERY 4: Inventory value report
    console.log("\n" + "─".repeat(70));
    console.log("💎 QUERY 4: INVENTORY VALUE REPORT - Total asset value");
    console.log("─".repeat(70) + "\n");
    const inventoryValueResponse = await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT category,
                      COUNT(*) as product_count,
                      SUM(current_stock) as total_units,
                      ROUND(SUM(current_stock * price), 2) as inventory_value,
                      ROUND(AVG(price), 2) as avg_price
               FROM products
               GROUP BY category
               ORDER BY inventory_value DESC`,
            },
        },
    });
    console.log("📦 Inventory by category:");
    console.log(inventoryValueResponse.content[0].text);
    // QUERY 5: Order status summary
    console.log("\n" + "─".repeat(70));
    console.log("📋 QUERY 5: ORDER STATUS SUMMARY - Current fulfillment status");
    console.log("─".repeat(70) + "\n");
    const orderStatusResponse = await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT status,
                      COUNT(*) as order_count,
                      ROUND(AVG(total_amount), 2) as avg_order_value,
                      ROUND(SUM(total_amount), 2) as total_revenue
               FROM orders
               GROUP BY status
               ORDER BY order_count DESC`,
            },
        },
    });
    console.log("📊 Order fulfillment status:");
    console.log(orderStatusResponse.content[0].text);
    // Disconnect
    await handleToolCall({
        params: {
            name: "disconnect_database",
            arguments: {},
        },
    });
    console.log("\n✅ Retail demo completed\n");
}
// Run retail demo
retailUseCaseDemo().catch(console.error);
//# sourceMappingURL=retail-usecase.js.map