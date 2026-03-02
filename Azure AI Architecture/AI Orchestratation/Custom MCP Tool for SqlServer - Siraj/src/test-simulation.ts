import { handleToolCall, listTools } from "./index.js";
import { DatabaseConnection } from "./database.js";

// Simulate live MCP calls
async function runLiveSimulation() {
  console.log("====================================");
  console.log("🚀 SQL MCP SERVER - LIVE SIMULATION");
  console.log("====================================\n");

  // Step 1: List available tools
  console.log("📋 STEP 1: List Available Tools");
  console.log("─────────────────────────────────");
  try {
    const tools = await listTools();
    console.log(JSON.stringify(tools, null, 2));
    console.log("\n✅ Tools listed successfully\n");
  } catch (error) {
    console.error("❌ Error:", error);
  }

  // Step 2: Connect to SQLite database
  console.log("📋 STEP 2: Connect to SQLite Database");
  console.log("─────────────────────────────────────");
  console.log("Request: Connect to in-memory SQLite database\n");

  const connectRequest = {
    params: {
      name: "connect_database",
      arguments: {
        type: "sqlite",
        path: ":memory:",
      },
    },
  };

  console.log("📤 Request sent:");
  console.log(JSON.stringify(connectRequest, null, 2));
  console.log("\n");

  const connectResponse = await handleToolCall(connectRequest);
  console.log("📥 Response received:");
  console.log(JSON.stringify(connectResponse, null, 2));
  console.log("\n✅ Connected successfully\n");

  // Step 3: Create a test table
  console.log("📋 STEP 3: Create Test Table");
  console.log("────────────────────────────");

  const createTableRequest = {
    params: {
      name: "query_database",
      arguments: {
        sql: `CREATE TABLE employees (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          department TEXT,
          salary REAL,
          hire_date TEXT
        )`,
      },
    },
  };

  console.log("📤 Request sent:");
  console.log(JSON.stringify(createTableRequest, null, 2));
  console.log("\n");

  const createTableResponse = await handleToolCall(createTableRequest);
  console.log("📥 Response received:");
  console.log(JSON.stringify(createTableResponse, null, 2));
  console.log("\n✅ Table created successfully\n");

  // Step 4: Insert test data
  console.log("📋 STEP 4: Insert Test Data");
  console.log("───────────────────────────");

  const insertRequest = {
    params: {
      name: "query_database",
      arguments: {
        sql: `INSERT INTO employees (name, department, salary, hire_date) VALUES
          ('Alice Johnson', 'Engineering', 95000, '2021-03-15'),
          ('Bob Smith', 'Sales', 75000, '2020-06-20'),
          ('Carol White', 'Engineering', 105000, '2019-01-10'),
          ('David Brown', 'HR', 65000, '2022-02-28'),
          ('Emma Davis', 'Sales', 80000, '2021-11-05')`,
      },
    },
  };

  console.log("📤 Request sent:");
  console.log(JSON.stringify(insertRequest, null, 2));
  console.log("\n");

  const insertResponse = await handleToolCall(insertRequest);
  console.log("📥 Response received:");
  console.log(JSON.stringify(insertResponse, null, 2));
  console.log("\n✅ Data inserted successfully\n");

  // Step 5: Query 1 - Get all employees
  console.log("📋 STEP 5: Query All Employees");
  console.log("───────────────────────────────");

  const queryAllRequest = {
    params: {
      name: "query_database",
      arguments: {
        sql: `SELECT * FROM employees ORDER BY salary DESC`,
      },
    },
  };

  console.log("📤 Request sent:");
  console.log(JSON.stringify(queryAllRequest, null, 2));
  console.log("\n");

  const queryAllResponse = await handleToolCall(queryAllRequest);
  console.log("📥 Response received:");
  console.log(JSON.stringify(queryAllResponse, null, 2));
  console.log("\n✅ Query executed successfully\n");

  // Step 6: Query 2 - Get high earners (salary > 80000)
  console.log("📋 STEP 6: Query High Earners (Salary > $80,000)");
  console.log("─────────────────────────────────────────────────");

  const queryHighEarnersRequest = {
    params: {
      name: "query_database",
      arguments: {
        sql: `SELECT name, department, salary FROM employees WHERE salary > 80000 ORDER BY salary DESC`,
      },
    },
  };

  console.log("📤 Request sent:");
  console.log(JSON.stringify(queryHighEarnersRequest, null, 2));
  console.log("\n");

  const queryHighEarnersResponse = await handleToolCall(queryHighEarnersRequest);
  console.log("📥 Response received:");
  console.log(JSON.stringify(queryHighEarnersResponse, null, 2));
  console.log("\n✅ Query executed successfully\n");

  // Step 7: Query 3 - Get department statistics
  console.log("📋 STEP 7: Department Statistics");
  console.log("────────────────────────────────");

  const queryStatsRequest = {
    params: {
      name: "query_database",
      arguments: {
        sql: `SELECT 
          department,
          COUNT(*) as employee_count,
          AVG(salary) as avg_salary,
          MAX(salary) as max_salary,
          MIN(salary) as min_salary
        FROM employees
        GROUP BY department
        ORDER BY avg_salary DESC`,
      },
    },
  };

  console.log("📤 Request sent:");
  console.log(JSON.stringify(queryStatsRequest, null, 2));
  console.log("\n");

  const queryStatsResponse = await handleToolCall(queryStatsRequest);
  console.log("📥 Response received:");
  console.log(JSON.stringify(queryStatsResponse, null, 2));
  console.log("\n✅ Query executed successfully\n");

  // Step 8: Disconnect
  console.log("📋 STEP 8: Disconnect from Database");
  console.log("──────────────────────────────────");

  const disconnectRequest = {
    params: {
      name: "disconnect_database",
      arguments: {},
    },
  };

  console.log("📤 Request sent:");
  console.log(JSON.stringify(disconnectRequest, null, 2));
  console.log("\n");

  const disconnectResponse = await handleToolCall(disconnectRequest);
  console.log("📥 Response received:");
  console.log(JSON.stringify(disconnectResponse, null, 2));
  console.log("\n✅ Disconnected successfully\n");

  console.log("====================================");
  console.log("✨ SIMULATION COMPLETED SUCCESSFULLY");
  console.log("====================================");
}

// Run the simulation
runLiveSimulation().catch(console.error);


