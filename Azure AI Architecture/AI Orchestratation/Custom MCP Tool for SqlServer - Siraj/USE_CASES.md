# 🏪 & 🏥 Real-World Use Cases: Retail & Healthcare

## Use Case 1: 🛍️ RETAIL E-COMMERCE INVENTORY MANAGEMENT

### Business Scenario
An online electronics retailer needs to manage inventory, track sales, and ensure products stay in stock. The system helps with real-time inventory monitoring, sales analytics, and order fulfillment.

### Database Schema

**Products Table** (8 items)
- Wireless Headphones ($89.99, 45 in stock)
- USB-C Cable ($12.99, 200 in stock) ✅ Top seller
- Phone Case ($19.99, 120 in stock)
- Screen Protector ($8.99, 300 in stock)
- Portable Charger ($34.99, 8 in stock) ⚠️ Low stock
- Laptop Stand ($29.99, 25 in stock)
- Bluetooth Speaker ($59.99, 3 in stock) ⚠️ Critical
- Webcam HD ($49.99, 0 in stock) ❌ Out of stock

**Orders Table** (5 orders, $1,005 total revenue)
- 2 Delivered (completed)
- 1 Shipped (in transit)
- 1 Processing (being packed)
- 1 Pending (awaiting pickup)

### Key Insights from Queries

#### 🚨 Query 1: Low Stock Alerts
**Finding**: 3 items need immediate reordering
- Portable Charger: 7 units short
- Bluetooth Speaker: 7 units short
- Webcam HD: Out of stock completely

**Action**: Reorder from suppliers immediately

#### 💰 Query 2: Sales Performance
**Today's Sales**: $299.85 revenue across 2 categories
- **Electronics**: $189.89 (63% of sales)
  - 2 orders, 11 units sold
  - Average price: $36.49
- **Accessories**: $109.96 (37% of sales)
  - 2 orders, 4 units sold
  - Average price: $24.99

#### ⭐ Query 3: Top Selling Products
**Rank 1**: USB-C Cable
- 15 units sold
- $194.85 revenue
- Ordered in 2 separate orders

**Rank 2**: Wireless Headphones
- 5 units sold
- $449.95 revenue (highest value)

**Rank 3**: Laptop Stand
- 4 units sold
- $119.96 revenue

#### 💎 Query 4: Inventory Value Report
**Total Inventory**: $12,952.99 across 8 products
- **Electronics** (5 items): $7,107.44
  - 256 units, average price $49.59
- **Accessories** (3 items): $5,845.55
  - 445 units, average price $19.66

#### 📋 Query 5: Order Status Summary
| Status | Orders | Avg Value | Revenue |
|--------|--------|-----------|---------|
| Delivered | 2 | $272.46 | $544.92 |
| Shipped | 1 | $134.98 | $134.98 |
| Processing | 1 | $79.98 | $79.98 |
| Pending | 1 | $244.98 | $244.98 |

### Business Actions
✅ **Immediate**: Reorder Webcam HD (0 stock), Bluetooth Speaker (3 units), Portable Charger (8 units)
✅ **Strategy**: Increase marketing for USB-C Cable (top seller)
✅ **Forecasting**: Monitor Electronics category (higher margin)
✅ **Logistics**: Ensure 2 shipped orders arrive on time

---

## Use Case 2: 🏥 HEALTHCARE PRIOR AUTHORIZATION SYSTEM

### Business Scenario
A healthcare insurance processor needs to track prior authorization requests for medical procedures. Doctors submit requests for procedures that require approval before patients receive treatment. The system manages approvals, denials, and pending requests.

### Database Schema

**Patients** (7 patients with insurance)
- Blue Cross (3 patients)
- Aetna (2 patients)
- United Health (1 patient)
- Cigna (1 patient)

**Procedures** (7 medical procedures)
- **Physical Therapy - Initial** ($150/session, requires auth)
- **MRI Brain** ($1,500, requires auth)
- **Total Knee Replacement** ($45,000, requires auth)
- **Physical Therapy - Evaluation** ($200, requires auth)
- **Office Visit** ($100, no auth needed)
- **X-Ray Chest** ($150, no auth needed)
- **Emergency Room** ($500, no auth needed)

**Authorization Requests** (7 requests, $54,800 total cost)
- 4 Approved (57%)
- 2 Pending (29%)
- 1 Denied (14%)

### Key Insights from Queries

#### ⏳ Query 1: Pending Authorizations
**2 Requests Awaiting Decision**
- Total knee replacement for Robert Davis ($45,000) - Pending since Jan 4
- Physical therapy for David Moore ($1,800) - Pending since Jan 11

**Days Pending**: Up to 7 days
**Action**: Follow up with reviewers for expedited decisions

#### 📊 Query 2: Approval Metrics
**Overall Approval Rate**: 57.1% (4 out of 7)
- **Approved**: 4 requests, $6,000 total, $1,500 average
- **Pending**: 2 requests, $46,800 total, $23,400 average (high-cost surgeries)
- **Denied**: 1 request, $2,000, therapy evaluation by Blue Cross

**Observation**: High-cost surgeries (knee replacement) take longer for approval

#### 🏆 Query 3: High-Volume Procedures
**Most Requested**: Physical Therapy - Initial (97110)
- 3 authorization requests
- $4,800 total cost
- 100% approval rate

**Second**: MRI Brain (70553)
- 2 authorization requests
- $3,000 total cost
- 100% approval rate

**Most Expensive**: Total Knee Replacement (27447)
- 1 authorization request
- $45,000 cost
- Still pending (1 week)

#### 🏢 Query 4: Insurance Carrier Analysis

| Insurer | Requests | Approval Rate | Total Cost |
|---------|----------|---------------|-----------|
| United Health | 1 | 100% | $1,200 |
| Aetna | 2 | 100% | $3,000 |
| Blue Cross | 3 | 33% | $48,800 |
| Cigna | 1 | 0% | $1,800 |

**Finding**: Blue Cross has strictest approval criteria (33% approval) with high-cost cases
Aetna and United Health approve everything submitted

#### ✅ Query 5: Approved Sessions
**4 Approved Treatment Plans**
1. **John Smith** - 12 PT sessions ($1,800 authorized)
2. **Jennifer Wilson** - 8 PT sessions ($1,200 authorized)
3. **Mary Johnson** - 1 MRI session ($1,500 authorized)
4. **Patricia Miller** - 1 MRI session ($1,500 authorized)

**Total Authorized**: $6,000 in patient care

#### ❌ Query 6: Denial Analysis
**1 Denied Request**
- Patient: Michael Brown
- Procedure: Physical Therapy - Evaluation
- Insurance: Blue Cross
- Cost: $2,000
- Reason: Possibly diagnosis code M79.3 (muscle/ligament disorder) - may need higher level review

### Business Actions
✅ **Urgent**: Follow up on $45,000 knee replacement approval (7 days pending)
✅ **Quality**: Investigate Blue Cross's 67% denial rate - may indicate missing documentation
✅ **Strategy**: Streamline PT approvals (3 requests, 100% approval - fast-track process)
✅ **Patient Care**: Alert 4 approved patients that treatment can begin immediately
✅ **Compliance**: Document denial reason for Michael Brown (potential appeal)

---

## 📊 Comparison: Retail vs Healthcare

| Aspect | Retail | Healthcare |
|--------|--------|-----------|
| **Data Focus** | Inventory, orders, revenue | Patients, procedures, authorizations |
| **Decision Type** | Stock reorder, pricing | Approval/denial, session authorization |
| **Volume** | High (100s of orders/day) | Lower (7-20 requests/day) |
| **Cost Range** | $8 - $1,200 per item | $150 - $45,000 per procedure |
| **Time Sensitivity** | Days (shipping) | Hours/Days (patient treatment) |
| **Compliance** | Inventory accuracy | Medical necessity, coverage rules |
| **Key Metric** | Revenue, inventory value | Approval rate, processing time |

---

## 🚀 Why MCP Works for Both

**Retail Benefits**:
- Real-time inventory alerts
- Instant sales analytics
- Revenue forecasting
- Supplier coordination

**Healthcare Benefits**:
- Automated request tracking
- Insurance approval analytics
- Patient care timeline management
- Compliance documentation

Both use cases show how **SQL queries through MCP** enable AI systems (Claude) to:
✅ Access real-time data
✅ Analyze complex business logic
✅ Generate actionable insights
✅ Automate routine reports
✅ Support decision-making

---

## 📈 Data Summary

### Retail Totals
- **Products**: 8 items
- **Total Inventory Value**: $12,952.99
- **Orders**: 5 orders
- **Revenue**: $1,005.86
- **Line Items**: 11 SKUs
- **Items Needing Reorder**: 3 urgent

### Healthcare Totals
- **Patients**: 7 registered
- **Procedures**: 7 types available
- **Authorization Requests**: 7 total
- **Total Request Value**: $54,800
- **Approved Cost**: $6,000
- **Approval Rate**: 57%
- **Pending Review**: $46,800 (high-cost surgeries)

---

**Use Case Status**: ✅ Both fully operational and documented
**Real Data**: ✅ Realistic scenarios with actual business queries
**Database**: ✅ SQLite with proper schema and relationships
**MCP Integration**: ✅ Full request-response workflow demonstrated
