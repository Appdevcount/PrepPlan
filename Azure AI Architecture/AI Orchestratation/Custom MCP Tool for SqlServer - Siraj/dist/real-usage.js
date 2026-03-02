import { handleToolCall } from "./index.js";
// Interactive MCP tool usage
async function demonstrateRealUsage() {
    console.log("\n🔧 SQL MCP SERVER - REAL USAGE DEMONSTRATION\n");
    console.log("=".repeat(60));
    // ===== DEMO 1: Connect to Database =====
    console.log("\n1️⃣  CONNECT TO DATABASE");
    console.log("-".repeat(60));
    const connectCall = {
        params: {
            name: "connect_database",
            arguments: { type: "sqlite", path: ":memory:" },
        },
    };
    console.log("\n📤 Sending:");
    console.log("  Tool: connect_database");
    console.log("  Args: { type: 'sqlite', path: ':memory:' }");
    const connectResult = await handleToolCall(connectCall);
    console.log("\n📥 Response:");
    console.log("  " + connectResult.content[0].text);
    // ===== DEMO 2: Create Sample Data =====
    console.log("\n\n2️⃣  CREATE SAMPLE DATA");
    console.log("-".repeat(60));
    const createTableCall = {
        params: {
            name: "query_database",
            arguments: {
                sql: `CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT, price REAL, stock INTEGER)`,
            },
        },
    };
    console.log("\n📤 Sending:");
    console.log("  Tool: query_database");
    console.log("  SQL: CREATE TABLE products (...)");
    await handleToolCall(createTableCall);
    console.log("✅ Table created");
    // Insert data
    const insertCall = {
        params: {
            name: "query_database",
            arguments: {
                sql: `INSERT INTO products (name, price, stock) VALUES 
               ('Laptop', 1200, 15),
               ('Mouse', 45, 120),
               ('Keyboard', 95, 85),
               ('Monitor', 350, 32)`,
            },
        },
    };
    console.log("\n📤 Sending:");
    console.log("  Tool: query_database");
    console.log("  SQL: INSERT INTO products VALUES (...)");
    await handleToolCall(insertCall);
    console.log("✅ Data inserted (4 products)");
    // ===== DEMO 3: Simple SELECT =====
    console.log("\n\n3️⃣  SIMPLE SELECT QUERY");
    console.log("-".repeat(60));
    const selectCall = {
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT * FROM products`,
            },
        },
    };
    console.log("\n📤 Sending:");
    console.log("  Tool: query_database");
    console.log("  SQL: SELECT * FROM products");
    const selectResult = await handleToolCall(selectCall);
    const responseText = selectResult.content[0].text;
    console.log("\n📥 Response:");
    console.log(responseText);
    // ===== DEMO 4: Filtered Query =====
    console.log("\n\n4️⃣  FILTERED QUERY (Price > 100)");
    console.log("-".repeat(60));
    const filteredCall = {
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT name, price, stock FROM products WHERE price > 100 ORDER BY price DESC`,
            },
        },
    };
    console.log("\n📤 Sending:");
    console.log("  Tool: query_database");
    console.log("  SQL: SELECT name, price, stock FROM products WHERE price > 100");
    const filteredResult = await handleToolCall(filteredCall);
    console.log("\n📥 Response:");
    console.log(filteredResult.content[0].text);
    // ===== DEMO 5: Aggregation Query =====
    console.log("\n\n5️⃣  AGGREGATION QUERY (Statistics)");
    console.log("-".repeat(60));
    const statsCall = {
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT 
                COUNT(*) as total_products,
                AVG(price) as avg_price,
                MAX(price) as most_expensive,
                MIN(price) as cheapest,
                SUM(stock) as total_stock
               FROM products`,
            },
        },
    };
    console.log("\n📤 Sending:");
    console.log("  Tool: query_database");
    console.log("  SQL: SELECT COUNT(*), AVG(price), MAX(price), ... FROM products");
    const statsResult = await handleToolCall(statsCall);
    console.log("\n📥 Response:");
    console.log(statsResult.content[0].text);
    // ===== DEMO 6: Update Data =====
    console.log("\n\n6️⃣  UPDATE OPERATION");
    console.log("-".repeat(60));
    const updateCall = {
        params: {
            name: "query_database",
            arguments: {
                sql: `UPDATE products SET stock = stock - 5 WHERE name = 'Laptop'`,
            },
        },
    };
    console.log("\n📤 Sending:");
    console.log("  Tool: query_database");
    console.log("  SQL: UPDATE products SET stock = stock - 5 WHERE name = 'Laptop'");
    await handleToolCall(updateCall);
    console.log("✅ Update executed");
    // Verify update
    const verifyCall = {
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT name, stock FROM products WHERE name = 'Laptop'`,
            },
        },
    };
    console.log("\n📤 Verifying:");
    console.log("  SQL: SELECT name, stock FROM products WHERE name = 'Laptop'");
    const verifyResult = await handleToolCall(verifyCall);
    console.log("\n📥 Result:");
    console.log(verifyResult.content[0].text);
    // ===== DEMO 7: Join/Complex Query =====
    console.log("\n\n7️⃣  COMPLEX QUERY (Multiple Operations)");
    console.log("-".repeat(60));
    const complexCall = {
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT name, price, stock, 
                      ROUND(price * stock, 2) as inventory_value
               FROM products
               WHERE stock > 0
               ORDER BY inventory_value DESC`,
            },
        },
    };
    console.log("\n📤 Sending:");
    console.log("  Tool: query_database");
    console.log("  SQL: Complex calculation with ORDER BY");
    const complexResult = await handleToolCall(complexCall);
    console.log("\n📥 Response:");
    console.log(complexResult.content[0].text);
    // ===== DEMO 8: Disconnect =====
    console.log("\n\n8️⃣  DISCONNECT");
    console.log("-".repeat(60));
    const disconnectCall = {
        params: {
            name: "disconnect_database",
            arguments: {},
        },
    };
    console.log("\n📤 Sending:");
    console.log("  Tool: disconnect_database");
    const disconnectResult = await handleToolCall(disconnectCall);
    console.log("\n📥 Response:");
    console.log("  " + disconnectResult.content[0].text);
    // ===== SUMMARY =====
    console.log("\n\n" + "=".repeat(60));
    console.log("✨ DEMONSTRATION COMPLETE");
    console.log("=".repeat(60));
    console.log("\n📊 Summary:");
    console.log("  ✅ Connected to database");
    console.log("  ✅ Created table with schema");
    console.log("  ✅ Inserted 4 product records");
    console.log("  ✅ Executed SELECT queries");
    console.log("  ✅ Executed filtered queries");
    console.log("  ✅ Calculated statistics");
    console.log("  ✅ Updated records");
    console.log("  ✅ Executed complex queries");
    console.log("  ✅ Disconnected cleanly");
    console.log("\n");
}
demonstrateRealUsage().catch(console.error);
//# sourceMappingURL=real-usage.js.map