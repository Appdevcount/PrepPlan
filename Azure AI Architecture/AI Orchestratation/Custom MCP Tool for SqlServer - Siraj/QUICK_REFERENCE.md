# 🎯 Quick Reference: How to Run Each Use Case

## Running the Demonstrations

### Build the Project
```bash
npm install
npm run build
```

### Run Retail Use Case
```bash
node dist/retail-usecase.js
```
**Demonstrates**:
- Inventory management
- Sales analytics
- Low stock alerts
- Order fulfillment tracking
- Revenue by category

### Run Healthcare Use Case
```bash
node dist/healthcare-usecase.js
```
**Demonstrates**:
- Prior authorization requests
- Approval/denial tracking
- Insurance carrier analytics
- Patient treatment authorizations
- Claim cost analysis

### Run Real Usage Example
```bash
node dist/real-usage.js
```
**Demonstrates**:
- Product inventory (4 items)
- 8 sequential database operations
- Complex queries with calculations

### Run Full Simulation
```bash
node dist/test-simulation.js
```
**Demonstrates**:
- Employee database (5 records)
- Department statistics
- High earner filtering
- Complete request-response flow

---

## 📁 Files Structure

```
src/
├── retail-usecase.ts         # 🛍️  E-commerce scenario
├── healthcare-usecase.ts     # 🏥 Prior auth scenario
├── real-usage.ts             # 📊 Product inventory demo
├── test-simulation.ts        # 👥 Employee database demo
├── index.ts                  # MCP server core
└── database.ts               # Database abstraction
```

---

## 🔑 Key Queries by Use Case

### Retail Queries
1. **Low Stock Alert** - Items below reorder level
2. **Sales Performance** - Revenue by category
3. **Top Selling Products** - Units sold ranking
4. **Inventory Value Report** - Total asset value
5. **Order Status Summary** - Fulfillment tracking

### Healthcare Queries
1. **Pending Authorizations** - Awaiting review
2. **Approval Metrics** - Decision statistics
3. **High-Volume Procedures** - Most requested
4. **Insurance Carrier Analysis** - Approval rates
5. **Approved Sessions** - Treatment plans
6. **Denial Analysis** - Rejected requests

---

## 💾 Sample Data

### Retail Database
- **8 Products**: Electronics & Accessories
- **5 Orders**: Mixed statuses (Delivered, Shipped, Processing, Pending)
- **11 Line Items**: Various quantities and prices
- **Total Revenue**: $1,005.86

### Healthcare Database
- **7 Patients**: Different insurance providers
- **7 Procedures**: Various categories and costs
- **7 Auth Requests**: Mix of approved/pending/denied
- **Total Request Value**: $54,800

---

## ✨ Features Demonstrated

✅ **Real-time Inventory Tracking** (Retail)
✅ **Sales Analytics** (Retail)
✅ **Request Processing** (Healthcare)
✅ **Approval Rate Analysis** (Healthcare)
✅ **Complex SQL Queries**
✅ **Aggregations & Calculations**
✅ **Multi-table Joins**
✅ **Conditional Filtering**
✅ **Data Sorting & Ranking**
✅ **Statistical Summaries**

---

**All demonstrations are fully functional and data-driven!** 🚀
