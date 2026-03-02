import sqlite3 from "sqlite3";
import * as mssql from "mssql";

export interface DatabaseConfig {
  type: "sqlite" | "mssql";
  path?: string; // For SQLite
  server?: string; // For MSSQL
  database?: string; // For MSSQL
  username?: string; // For MSSQL
  password?: string; // For MSSQL
  port?: number; // For MSSQL
}

export class DatabaseConnection {
  private config: DatabaseConfig;
  private sqliteDb?: sqlite3.Database;
  private mssqlPool?: any;

  constructor(config: DatabaseConfig) {
    this.config = config;
  }

  async connect(): Promise<void> {
    if (this.config.type === "sqlite") {
      await this.connectSQLite();
    } else if (this.config.type === "mssql") {
      await this.connectMSSQL();
    } else {
      throw new Error("Unsupported database type");
    }
  }

  private connectSQLite(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.sqliteDb = new sqlite3.Database(
        this.config.path || ":memory:",
        (err) => {
          if (err) reject(err);
          else resolve();
        }
      );
    });
  }

  private async connectMSSQL(): Promise<void> {
    try {
      const pool = new mssql.ConnectionPool({
        server: this.config.server || "localhost",
        database: this.config.database || "master",
        authentication: {
          type: "default",
          options: {
            userName: this.config.username,
            password: this.config.password,
          },
        },
        options: {
          encrypt: true,
          trustServerCertificate: true,
        },
        port: this.config.port || 1433,
      });

      await pool.connect();
      this.mssqlPool = pool;
    } catch (error) {
      throw new Error(`Failed to connect to MSSQL: ${error}`);
    }
  }

  async query(sql: string, params?: any[]): Promise<any[]> {
    if (this.config.type === "sqlite") {
      return this.querySQLite(sql, params);
    } else if (this.config.type === "mssql") {
      return this.queryMSSQL(sql, params);
    }
    throw new Error("Database not connected");
  }

  private querySQLite(sql: string, params?: any[]): Promise<any[]> {
    return new Promise((resolve, reject) => {
      if (!this.sqliteDb) {
        reject(new Error("SQLite database not connected"));
        return;
      }

      this.sqliteDb.all(sql, params || [], (err, rows) => {
        if (err) reject(err);
        else resolve(rows || []);
      });
    });
  }

  private async queryMSSQL(sql: string, params?: any[]): Promise<any[]> {
    if (!this.mssqlPool) {
      throw new Error("MSSQL database not connected");
    }

    try {
      const request = this.mssqlPool.request();

      // Add parameters if provided
      if (params) {
        params.forEach((value, index) => {
          request.input(`param${index}`, value);
        });
      }

      const result = await request.query(sql);
      return result.recordset;
    } catch (error) {
      throw new Error(`Query failed: ${error}`);
    }
  }

  async close(): Promise<void> {
    if (this.config.type === "sqlite" && this.sqliteDb) {
      return new Promise((resolve, reject) => {
        this.sqliteDb!.close((err) => {
          if (err) reject(err);
          else resolve();
        });
      });
    } else if (this.config.type === "mssql" && this.mssqlPool) {
      await this.mssqlPool.close();
    }
  }
}
