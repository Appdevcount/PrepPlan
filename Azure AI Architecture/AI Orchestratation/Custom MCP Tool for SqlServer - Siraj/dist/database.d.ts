export interface DatabaseConfig {
    type: "sqlite" | "mssql";
    path?: string;
    server?: string;
    database?: string;
    username?: string;
    password?: string;
    port?: number;
}
export declare class DatabaseConnection {
    private config;
    private sqliteDb?;
    private mssqlPool?;
    constructor(config: DatabaseConfig);
    connect(): Promise<void>;
    private connectSQLite;
    private connectMSSQL;
    query(sql: string, params?: any[]): Promise<any[]>;
    private querySQLite;
    private queryMSSQL;
    close(): Promise<void>;
}
//# sourceMappingURL=database.d.ts.map