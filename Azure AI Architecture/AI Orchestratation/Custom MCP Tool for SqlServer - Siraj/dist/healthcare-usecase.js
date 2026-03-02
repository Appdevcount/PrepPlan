import { handleToolCall } from "./index.js";
// ===== HEALTHCARE USE CASE =====
// Prior Authorization Request Management System
async function healthcareUseCaseDemo() {
    console.log("\n" + "=".repeat(70));
    console.log("🏥 HEALTHCARE USE CASE: PRIOR AUTHORIZATION REQUEST SYSTEM");
    console.log("=".repeat(70));
    // Step 1: Connect
    console.log("\n📍 SETUP: Connect to healthcare database\n");
    await handleToolCall({
        params: {
            name: "connect_database",
            arguments: { type: "sqlite", path: ":memory:" },
        },
    });
    console.log("✅ Connected\n");
    // Step 2: Create healthcare schema
    console.log("📍 Creating healthcare database schema...\n");
    // Patients table
    await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `CREATE TABLE patients (
          patient_id INTEGER PRIMARY KEY,
          patient_name TEXT NOT NULL,
          date_of_birth TEXT,
          insurance_provider TEXT,
          member_id TEXT UNIQUE
        )`,
            },
        },
    });
    // Procedures table
    await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `CREATE TABLE procedures (
          procedure_id INTEGER PRIMARY KEY,
          procedure_code TEXT UNIQUE,
          procedure_name TEXT,
          category TEXT,
          typical_cost REAL,
          requires_auth INTEGER
        )`,
            },
        },
    });
    // Prior Authorization Requests table
    await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `CREATE TABLE auth_requests (
          auth_id INTEGER PRIMARY KEY,
          patient_id INTEGER,
          procedure_id INTEGER,
          request_date TEXT,
          provider_name TEXT,
          diagnosis_code TEXT,
          status TEXT,
          decision_date TEXT,
          approved_sessions INTEGER,
          cost_estimate REAL
        )`,
            },
        },
    });
    console.log("✅ Schema created\n");
    // Step 3: Insert healthcare data
    console.log("📍 Inserting patient and procedure data...\n");
    await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `INSERT INTO patients VALUES
          (2001, 'John Smith', '1965-03-15', 'Blue Cross', 'BC-2025-001'),
          (2002, 'Mary Johnson', '1978-07-22', 'Aetna', 'AET-2025-002'),
          (2003, 'Robert Davis', '1952-11-08', 'Blue Cross', 'BC-2025-003'),
          (2004, 'Jennifer Wilson', '1988-05-30', 'United Health', 'UH-2025-004'),
          (2005, 'Michael Brown', '1975-02-14', 'Blue Cross', 'BC-2025-005'),
          (2006, 'Patricia Miller', '1960-09-25', 'Aetna', 'AET-2025-006'),
          (2007, 'David Moore', '1982-01-10', 'Cigna', 'CIG-2025-007')`,
            },
        },
    });
    console.log("✅ Patients loaded (7 patients)\n");
    await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `INSERT INTO procedures VALUES
          (301, '97110', 'Physical Therapy - Initial', 'Rehabilitation', 150.00, 1),
          (302, '97161', 'Physical Therapy - Evaluation', 'Rehabilitation', 200.00, 1),
          (303, '99213', 'Office Visit - Established', 'General', 100.00, 0),
          (304, '70553', 'MRI Brain without contrast', 'Imaging', 1500.00, 1),
          (305, '70110', 'X-Ray Chest', 'Imaging', 150.00, 0),
          (306, '27447', 'Total knee replacement', 'Surgery', 45000.00, 1),
          (307, '99285', 'Emergency Room Visit', 'Emergency', 500.00, 0)`,
            },
        },
    });
    console.log("✅ Procedures loaded (7 procedures)\n");
    await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `INSERT INTO auth_requests VALUES
          (5001, 2001, 301, '2026-01-05', 'PT Specialists LLC', 'M79.3', 'Approved', '2026-01-07', 12, 1800.00),
          (5002, 2002, 304, '2026-01-06', 'Memorial Hospital', 'J39.0', 'Approved', '2026-01-08', 1, 1500.00),
          (5003, 2003, 306, '2026-01-04', 'Orthopedic Center', 'M17.0', 'Pending', NULL, NULL, 45000.00),
          (5004, 2004, 301, '2026-01-09', 'PT Specialists LLC', 'M25.5', 'Approved', '2026-01-10', 8, 1200.00),
          (5005, 2005, 302, '2026-01-08', 'Rehab Plus', 'M79.3', 'Denied', '2026-01-09', 0, 2000.00),
          (5006, 2006, 304, '2026-01-10', 'Imaging Center', 'G89.2', 'Approved', '2026-01-11', 1, 1500.00),
          (5007, 2007, 301, '2026-01-11', 'PT Specialists LLC', 'M25.5', 'Pending', NULL, NULL, 1800.00)`,
            },
        },
    });
    console.log("✅ Authorization requests loaded (7 requests)\n");
    // QUERY 1: Pending authorizations
    console.log("\n" + "─".repeat(70));
    console.log("⏳ QUERY 1: PENDING AUTHORIZATIONS - Awaiting decision");
    console.log("─".repeat(70) + "\n");
    const pendingAuthResponse = await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT ar.auth_id,
                      p.patient_name,
                      ar.member_id as 'Insurance ID',
                      pr.procedure_name,
                      ar.provider_name,
                      ar.request_date,
                      ar.cost_estimate as 'Est. Cost',
                      CAST(julianday('now') - julianday(ar.request_date) AS INTEGER) as 'Days Pending'
               FROM auth_requests ar
               JOIN patients p ON ar.patient_id = p.patient_id
               JOIN procedures pr ON ar.procedure_id = pr.procedure_id
               WHERE ar.status = 'Pending'
               ORDER BY ar.request_date ASC`,
            },
        },
    });
    console.log("🔍 Awaiting review:");
    console.log(pendingAuthResponse.content[0].text);
    // QUERY 2: Authorization approval rate
    console.log("\n" + "─".repeat(70));
    console.log("📊 QUERY 2: APPROVAL METRICS - Decision statistics");
    console.log("─".repeat(70) + "\n");
    const approvalRateResponse = await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT status,
                      COUNT(*) as request_count,
                      ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM auth_requests), 1) as percentage,
                      ROUND(AVG(cost_estimate), 2) as avg_cost,
                      ROUND(SUM(cost_estimate), 2) as total_estimated_cost
               FROM auth_requests
               GROUP BY status
               ORDER BY request_count DESC`,
            },
        },
    });
    console.log("📈 Decision breakdown:");
    console.log(approvalRateResponse.content[0].text);
    // QUERY 3: Top requested procedures
    console.log("\n" + "─".repeat(70));
    console.log("🏆 QUERY 3: HIGH-VOLUME PROCEDURES - Most requested");
    console.log("─".repeat(70) + "\n");
    const topProceduresResponse = await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT pr.procedure_code,
                      pr.procedure_name,
                      pr.category,
                      COUNT(*) as auth_requests,
                      ROUND(SUM(ar.cost_estimate), 2) as total_cost,
                      ROUND(AVG(ar.cost_estimate), 2) as avg_cost
               FROM auth_requests ar
               JOIN procedures pr ON ar.procedure_id = pr.procedure_id
               GROUP BY ar.procedure_id
               ORDER BY auth_requests DESC`,
            },
        },
    });
    console.log("🩺 Most requested procedures:");
    console.log(topProceduresResponse.content[0].text);
    // QUERY 4: Insurance provider performance
    console.log("\n" + "─".repeat(70));
    console.log("🏢 QUERY 4: INSURANCE CARRIER ANALYSIS - Approval rates by insurer");
    console.log("─".repeat(70) + "\n");
    const insurerPerformanceResponse = await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT p.insurance_provider,
                      COUNT(ar.auth_id) as total_requests,
                      SUM(CASE WHEN ar.status = 'Approved' THEN 1 ELSE 0 END) as approved,
                      SUM(CASE WHEN ar.status = 'Denied' THEN 1 ELSE 0 END) as denied,
                      ROUND(100.0 * SUM(CASE WHEN ar.status = 'Approved' THEN 1 ELSE 0 END) / 
                            COUNT(ar.auth_id), 1) as approval_rate,
                      ROUND(SUM(ar.cost_estimate), 2) as total_cost
               FROM auth_requests ar
               JOIN patients p ON ar.patient_id = p.patient_id
               GROUP BY p.insurance_provider
               ORDER BY approval_rate DESC`,
            },
        },
    });
    console.log("💼 Insurer statistics:");
    console.log(insurerPerformanceResponse.content[0].text);
    // QUERY 5: Approved therapy sessions
    console.log("\n" + "─".repeat(70));
    console.log("✅ QUERY 5: APPROVED SESSIONS - Therapy authorization summary");
    console.log("─".repeat(70) + "\n");
    const approvedSessionsResponse = await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT p.patient_name,
                      pr.procedure_name,
                      ar.provider_name,
                      ar.approved_sessions,
                      pr.typical_cost as cost_per_session,
                      ROUND(ar.approved_sessions * pr.typical_cost, 2) as total_authorized_cost,
                      ar.decision_date
               FROM auth_requests ar
               JOIN patients p ON ar.patient_id = p.patient_id
               JOIN procedures pr ON ar.procedure_id = pr.procedure_id
               WHERE ar.status = 'Approved' AND ar.approved_sessions > 0
               ORDER BY ar.approved_sessions DESC`,
            },
        },
    });
    console.log("🎯 Approved treatment plans:");
    console.log(approvedSessionsResponse.content[0].text);
    // QUERY 6: Denied claims analysis
    console.log("\n" + "─".repeat(70));
    console.log("❌ QUERY 6: DENIAL ANALYSIS - Denied authorizations");
    console.log("─".repeat(70) + "\n");
    const deniedClaimsResponse = await handleToolCall({
        params: {
            name: "query_database",
            arguments: {
                sql: `SELECT ar.auth_id,
                      p.patient_name,
                      pr.procedure_name,
                      ar.diagnosis_code,
                      ar.cost_estimate,
                      ar.decision_date,
                      p.insurance_provider
               FROM auth_requests ar
               JOIN patients p ON ar.patient_id = p.patient_id
               JOIN procedures pr ON ar.procedure_id = pr.procedure_id
               WHERE ar.status = 'Denied'
               ORDER BY ar.decision_date DESC`,
            },
        },
    });
    console.log("📋 Denied requests:");
    console.log(deniedClaimsResponse.content[0].text);
    // Disconnect
    await handleToolCall({
        params: {
            name: "disconnect_database",
            arguments: {},
        },
    });
    console.log("\n✅ Healthcare demo completed\n");
}
// Run healthcare demo
healthcareUseCaseDemo().catch(console.error);
//# sourceMappingURL=healthcare-usecase.js.map