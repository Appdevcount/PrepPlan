# SQL MCP Server

A simple Model Context Protocol (MCP) server for connecting to and querying local SQL databases.

## Features

- Connect to SQLite or SQL Server databases
- Execute SQL queries with parameter support
- Simple JSON-based communication
- Graceful connection management

## Supported Databases

- **SQLite**: File-based database, great for local development
- **SQL Server (MSSQL)**: Enterprise SQL Server support

## Installation

```bash
npm install
npm run build
```

## Usage

### Running the Server

```bash
npm start
```

Or for development with auto-reload:

```bash
npm run dev
```

## Tools Available

### 1. connect_database
Connect to a local SQL database.

**Parameters:**
- `type` (required): "sqlite" or "mssql"
- `path`: Path to SQLite database file (required for SQLite)
- `server`: SQL Server address (default: localhost)
- `database`: Database name (default: master)
- `username`: MSSQL username
- `password`: MSSQL password
- `port`: MSSQL port (default: 1433)

**Example - SQLite:**
```json
{
  "type": "sqlite",
  "path": "./mydb.sqlite"
}
```

**Example - SQL Server:**
```json
{
  "type": "mssql",
  "server": "localhost",
  "database": "MyDatabase",
  "username": "sa",
  "password": "YourPassword"
}
```

### 2. query_database
Execute a SQL query on the connected database.

**Parameters:**
- `sql` (required): SQL query string
- `params`: Array of query parameters (optional)

**Example:**
```json
{
  "sql": "SELECT * FROM users WHERE id = ?",
  "params": [1]
}
```

### 3. disconnect_database
Disconnect from the current database and clean up resources.

## Architecture

- **database.ts**: Core database connection and query execution logic
- **index.ts**: MCP server implementation with tool handlers

## Error Handling

The server provides detailed error messages for:
- Connection failures
- Query execution errors
- Invalid tool requests
- Missing database connections

## License

MIT
