import { DatabaseConnection, DatabaseConfig } from "./database.js";

// Simple MCP-like server implementation
interface MCPRequest {
  params: {
    name: string;
    arguments?: any;
  };
}

interface MCPResponse {
  content: Array<{
    type: string;
    text: string;
  }>;
  isError?: boolean;
}

let dbConnection: DatabaseConnection | null = null;

// List available tools
const listTools = async (): Promise<any> => {
  return {
    tools: [
      {
        name: "connect_database",
        description:
          "Connect to a local SQL database (SQLite or SQL Server)",
        inputSchema: {
          type: "object",
          properties: {
            type: {
              type: "string",
              enum: ["sqlite", "mssql"],
              description: "Type of database to connect to",
            },
            path: {
              type: "string",
              description: "Path to SQLite database file (required for sqlite)",
            },
            server: {
              type: "string",
              description:
                "SQL Server address (required for mssql, default: localhost)",
            },
            database: {
              type: "string",
              description:
                "Database name (required for mssql, default: master)",
            },
            username: {
              type: "string",
              description: "Username for MSSQL authentication",
            },
            password: {
              type: "string",
              description: "Password for MSSQL authentication",
            },
            port: {
              type: "number",
              description: "Port for MSSQL (default: 1433)",
            },
          },
          required: ["type"],
        },
      },
      {
        name: "query_database",
        description: "Execute a SQL query on the connected database",
        inputSchema: {
          type: "object",
          properties: {
            sql: {
              type: "string",
              description: "SQL query to execute",
            },
            params: {
              type: "array",
              description: "Query parameters (optional)",
            },
          },
          required: ["sql"],
        },
      },
      {
        name: "disconnect_database",
        description: "Disconnect from the current database",
        inputSchema: {
          type: "object",
          properties: {},
          required: [],
        },
      },
    ],
  };
};

// Tool: Connect to database
const handleToolCall = async (request: MCPRequest): Promise<MCPResponse> => {
  const toolName = request.params.name;
  const args = request.params.arguments || {};

  if (toolName === "connect_database") {
    return handleConnect(args);
  } else if (toolName === "query_database") {
    return handleQuery(args);
  } else if (toolName === "disconnect_database") {
    return handleDisconnect(args);
  }

  return {
    content: [
      {
        type: "text",
        text: `Unknown tool: ${toolName}`,
      },
    ],
    isError: true,
  };
};

async function handleConnect(args: any) {
  try {
    if (dbConnection) {
      await dbConnection.close();
    }

    const config: DatabaseConfig = {
      type: args.type,
      path: args.path,
      server: args.server,
      database: args.database,
      username: args.username,
      password: args.password,
      port: args.port,
    };

    dbConnection = new DatabaseConnection(config);
    await dbConnection.connect();

    return {
      content: [
        {
          type: "text",
          text: `Successfully connected to ${args.type} database`,
        },
      ],
    };
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Connection failed: ${error}`,
        },
      ],
      isError: true,
    };
  }
}

async function handleQuery(args: any) {
  try {
    if (!dbConnection) {
      return {
        content: [
          {
            type: "text",
            text: "No database connection. Please connect first using connect_database tool.",
          },
        ],
        isError: true,
      };
    }

    const results = await dbConnection.query(args.sql, args.params);

    return {
      content: [
        {
          type: "text",
          text: `Query executed successfully.\nResults (${results.length} rows):\n${JSON.stringify(
            results,
            null,
            2
          )}`,
        },
      ],
    };
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Query failed: ${error}`,
        },
      ],
      isError: true,
    };
  }
}

async function handleDisconnect(args: any): Promise<MCPResponse> {
  try {
    if (!dbConnection) {
      return {
        content: [
          {
            type: "text",
            text: "No active database connection",
          },
        ],
      };
    }

    await dbConnection.close();
    dbConnection = null;

    return {
      content: [
        {
          type: "text",
          text: "Database disconnected successfully",
        },
      ],
    };
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Disconnection failed: ${error}`,
        },
      ],
      isError: true,
    };
  }
}

// Export for use
export { handleToolCall, listTools };
