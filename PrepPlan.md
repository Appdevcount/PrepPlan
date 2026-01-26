# 1️⃣ Target Roles & Mindset (Very Important)

## 🎯 Roles You Should Target

With your profile, **do NOT downgrade yourself**.

**Best-fit roles:**
- Senior Software Engineer / Lead Engineer
- Technical Lead
- Associate Solution Architect
- Full-Stack Architect (for product companies)

## 🧠 Interview Mindset

**Think and answer as:**
> "I design systems, make trade-offs, guide teams, and still code."

**Avoid:**
- Over-focusing on syntax
- Junior-level explanations
- "I only worked on assigned tasks"


## Ground Rules
- 3–4 focused hours/day
- No over-learning
- Every day ends with interview-ready outputs
- Always think: "How would I explain this in an interview?"

## Phase-Wise Split

| Phase | Days | Goal |
|-------|------|------|
| Phase 1 | Day 1–5 | Core foundation + positioning |
| Phase 2 | Day 6–12 | Depth in backend, system design & cloud |
| Phase 3 | Day 13–17 | Architect-level thinking + leadership |
| Phase 4 | Day 18–21 | Mock interviews + polishing |

## DEPTH PHILOSOPHY (IMPORTANT)

**"More depth" does NOT mean:**
- More frameworks
- More syntax
- More memorization

**It DOES mean:**
- Understanding why things fail
- Explaining trade-offs
- Knowing limits & edge cases
- Showing ownership mindset
- Speaking with clarity under pressure

Every topic below is chosen to help you answer:
- "Why did you do it this way?"
- "What would break first?"
- "What would you change if scale doubled?"

---

# 🟢 PHASE 1 — POSITIONING & CORE FOUNDATION

**Critical for ALL timelines**

## Day 1 – Resume, Role Strategy & Narrative (VERY IMPORTANT)

### Topics

**Resume restructuring (impact, scale, decisions)**
- Metrics: users, TPS, data size, cost, latency
- 2 resume versions:
  - Product company
  - Service / consulting

**Rewrite resume to architect/lead narrative**
- Career storyline: Developer → Senior → Design Owner → Mentor
- Each project → show:
  - Business problem
  - Architecture
  - Tech decisions
  - Trade-offs
  - Impact (performance, cost, scale)

**Prepare 3 strong project stories:**
- One core business system
- One scalability/performance challenge
- One failure or production issue

**Must-prepare answers:**
- "Tell me about your current project"
- "What was the most complex system you worked on?"
- "What architectural decisions did you make?"
- STAR format answers ready

### Deliverables
- ✔ Resume finalized
- ✔ 2-min + 5-min self-intro
- ✔ 3 flagship project stories:
  - Complex system
  - Performance/scaling win
  - Failure/incident

---

## Day 2 — Advanced C# & .NET Internals (DEEP)

### Topics

**async/await internals**
- State machine – conceptual
- Task vs Thread vs ValueTask
- CPU-bound vs IO-bound
- ThreadPool starvation
- Sync-over-async deadlocks

**Garbage Collection:**
- Generations
- LOH
- Allocation pressure

**Other key topics:**
- Struct vs class trade-offs
- DI lifetimes & captive dependencies
- Exception handling strategy
- Performance profiling mindset

### Deliverables
- ✔ 25+ advanced C# Q&A
- ✔ 2 real performance/failure stories

📌 **Be ready to answer:** "How do you design a scalable .NET API?"

---

## Day 3 — ASP.NET Core & API Architecture (DEEP)

### Topics

- Clean Architecture layers & flow
- Kestrel → Middleware → Filters → Controllers
- Middleware vs Filters (order & use cases)
- Model binding & validation
- Global error handling
- API versioning strategies
- Idempotent APIs
- Background services
- Graceful shutdown
- Logging & correlation IDs
- Health checks

### Deliverables
- ✔ End-to-end request flow explanation
- ✔ Clear "where logic belongs / does not belong"

---

## Day 4–5 — [Core Foundation Topics]

---

## Day 6 — Testing & Quality Engineering (Often Missed, Very Strong)

### Topics

- Unit vs Integration vs E2E
- Test pyramid
- Mocking vs faking
- Testing async code
- Contract testing
- Coverage vs confidence
- What NOT to test

### Deliverables
- ✔ Clear testing strategy explanation

---

# 🔵 PHASE 2 — SYSTEM DESIGN & DISTRIBUTED SYSTEMS

## Day 7 — System Design Fundamentals (DEEP)

### Topics

- Monolith vs Microservices
- Stateless services
- Sync vs Async communication
- Caching strategies
- Cache invalidation
- Retry & circuit breaker
- Rate limiting
- Idempotency
- CAP theorem (practical)
- Read/write separation
- Back-pressure handling

### Deliverables
- ✔ 1 complete system design walkthrough

---

## Day 8 — Distributed Systems & Messaging (DEEP)

### Topics

- Event-driven architecture
- Message ordering
- Duplicate handling
- Exactly-once myth
- Poison messages
- Saga pattern
- Orchestration vs choreography
- Compensating transactions
- Eventual consistency

### Deliverables
- ✔ Event-driven system explained with failures

---

## Day 9 — Design Patterns & DDD (PRACTICAL)

### Topics

- SOLID (real examples)
- Factory, Strategy, Decorator
- Repository & Unit of Work (when NOT to use)
- Anemic vs rich domain model
- Aggregates & invariants
- Domain events
- Application vs domain services
- Anti-patterns & over-engineering

### Deliverables
- ✔ Pattern misuse story (very impressive in interviews)

---

## Day 10 — Azure Core Services (Decision-Based, DEEP)

### Topics

**Service selection:**
- App Service vs Container Apps vs AKS
- Azure SQL vs Cosmos DB
- Service Bus vs Event Grid vs Event Hub

**Platform features:**
- API Management (policies)
- Azure AD vs Azure AD B2C
- Managed Identity
- Key Vault

**Networking basics:**
- VNet
- Private endpoints
- Cold starts
- Throttling limits

### Deliverables
- ✔ Azure reference architecture with trade-offs

---

## Day 11 — Cloud Scale, Reliability & Cost (VERY DEEP)

### Topics

- Horizontal vs vertical scaling
- Failure domains
- Blast radius containment
- High availability
- Disaster recovery (RTO/RPO)
- Geo-replication
- Autoscaling rules
- Chaos engineering mindset
- Cost optimization strategies
- Reserved vs PAYG
- Cost monitoring & alerts

### Deliverables
- ✔ Scaling + cost optimization case study

📌 **Prepare:** One Azure reference architecture explanation

---

## Day 12 — Security Architecture (DEEP)

### Topics

- Authentication vs Authorization
- OAuth flows & grant types
- JWT lifecycle & revocation
- OWASP Top 10
- Secure headers
- Rate limiting abuse scenarios
- Defense in depth
- Secrets management
- Secure CI/CD pipelines
- Zero trust basics

### Deliverables
- ✔ Security checklist
- ✔ Threat modeling explanation

---

## Day 13 — DevOps, CI/CD & Release Strategy

### Topics

- CI/CD pipeline stages
- Quality gates
- Code coverage strategy
- Blue-green vs Canary
- Feature toggles
- Rollback vs roll-forward
- Infra as Code mindset
- Environment promotion

### Deliverables
- ✔ End-to-end release pipeline explanation

---

## Day 14 — Full System + Azure Whiteboard Drill (HARD DAY)

### Tasks

**60-minute design:**
- Requirements
- Architecture
- Security
- Scale
- Cost
- Failure handling

### Deliverables
- ✔ Architect-level confidence

---

# 🔵 PHASE 3 — LEADERSHIP, CODING & DOMAIN

## Day 15 — Behavioral & Leadership (VERY DEEP)

### Topics

- Production outages
- Conflict resolution
- Saying "No" to stakeholders
- Mentoring juniors
- Handling under-performance
- Balancing tech debt vs delivery
- Ownership examples

---

## Day 16 — Senior-Level Coding (Non-DSA)

### Topics

- Clean code
- Refactoring legacy code
- SOLID application
- Exception-safe code
- Performance-aware coding
- Testable design

---

## Day 17 — Domain-Specific System Design

### Topics

- Healthcare / FinTech / E-commerce flows
- Compliance awareness
- Data privacy & regulations

---

# 🔵 PHASE 4 — MOCKS & POLISH

## Day 18 — Mock Technical Interviews

## Day 19 — Mock System Design + Azure

## Day 20 — Mock Behavioral + HR + Negotiation

## Day 21 — Light Review & Confidence Reset

---

# 🔵 PHASE 5 — OPTIONAL EXTRA EDGE (DAY 22–25)

## Day 22 — Architecture Decision Records (ADR)

- Recording decisions
- Explaining rejected options

---

## Day 23 — Production Failures & Postmortems

- RCA
- Prevention strategies

---

## Day 24 — Company-Specific Deep Prep

- Product vs service mindset
- Tech stack alignment

---

## Day 25 — Final Mock + Confidence Boost

**Focus on:**
- Stories
- Calm explanations
- Clear thinking

---

# 3️⃣ Topic-Wise Preparation Map (What Depth Is Enough)

| Area | Depth Required |
|------|---|
| C# | Internals + async |
| Web API | Architecture + patterns |
| Database | Design + performance |
| Frontend | Architecture understanding |
| Azure | Service selection logic |
| System Design | Trade-offs |
| Security | Awareness + implementation |
| Leadership | Strong |

---

# 4️⃣ Interview-Ready Artifacts (Very Important)

**Prepare these before interviews start:**

- ✔ 3 solid project stories
- ✔ 2 architecture diagrams (mentally)
- ✔ 1 failure/incident story
- ✔ 1 optimization story
- ✔ 1 leadership story

---

# 5️⃣ How to Answer Like a 12-Year Professional

❌ **Don't say:**
- "I used this because team decided…"

✅ **Say:**
- "We evaluated 3 options. We chose X due to scalability and cost trade-offs."

---

# 6️⃣ Common Mistakes to Avoid

- Over-preparing DSA (not needed at your level)
- Over-learning new frameworks
- Underselling experience
- Giving textbook answers
- Saying "I didn't work on that" too quickly

---

# 7️⃣ After 2 Weeks – Continuation Strategy

**If interviews extend:**
- Deepen system design
- Strengthen Azure architecture
- Prepare for Architect-level rounds

---

# 📊 DEPTH SUMMARY (WHAT MATTERS MOST)

| Area | Depth |
|------|-------|
| C# / .NET internals | 🔥🔥🔥 |
| API & Backend | 🔥🔥🔥 |
| System Design | 🔥🔥🔥 |
| Azure Architecture | 🔥🔥🔥 |
| Frontend | 🔥🔥 |
| Security | 🔥🔥 |
| DSA | 🔥 (minimal) |

---

# 8️⃣ EXPECTED INTERVIEW QUESTIONS & ANSWERS (Based on Your Experience)

## 🎯 Your Role Summary

**Senior Full-Stack Architect & Technical Lead**

You are a results-driven technical leader with deep expertise in designing and delivering mission-critical, distributed healthcare and fintech systems under extreme constraints. Your strength lies in:
- **Strategic architecture** for high-scale, event-driven microservices
- **Cost optimization** and resource-constrained delivery
- **Crisis management** in time-critical, weekend-mode production scenarios
- **Cross-team orchestration** spanning platform, backend, frontend, and infrastructure teams
- **Modern cloud-native patterns** with proven expertise in Kafka, AKS, event sourcing, and enterprise integration
- **Mentoring teams** through POC and emerging technologies (MCP, AI-assisted development)

---

## 📋 EXPECTED TECHNICAL QUESTIONS

### **1. Event-Driven Architecture & Kafka (3 Questions)**

**Q1: Design an event-driven healthcare prior authorization system. How would you handle message ordering, duplicate events, and replay scenarios?**

**Sample Answer:**
```
Architecture:
- Events (AuthorizationRequested, AuthApproved) → Kafka topics
- Partitioned by PatientID for ordering
- Event Store (CosmosDB) maintains full history
- Idempotent consumer: Store processed event IDs, skip duplicates
- Replay: Recover state by replaying events

Failure Scenarios:
- Duplicate message: Idempotency key prevents double approvals
- Out-of-order: Single partition per patient = ordering guaranteed
- Consumer down: Kafka retains, consumer resumes from offset
- Poison message: DLQ with alerting
```

---

**Q1b: How would you handle Kafka consumer lag and scaling? What monitoring would you set up?**

**Sample Answer:**
```
Consumer Lag Monitoring:
- Track: Current offset vs committed offset
- Alert if lag > 5 minutes (for 100k requests/day)
- Dashboard: Consumer group lag, partition distribution

Scaling Strategies:
1. Increase consumer instances (max = partition count)
   - 8 partitions = max 8 consumers
   - Each consumer processes 1-N partitions

2. Increase partition count (careful: ordering!)
   - Only add partitions if partitioned by non-timestamp
   - Rebalancing causes temporary lag spike

3. Optimize consumer processing
   - Batch size: 100 → 500 (process more at once)
   - Compression: Snappy or LZ4
   - Parallelism: Process non-dependent events in parallel

Monitoring Metrics:
- Consumer lag (per partition)
- Processing time (p50, p99)
- Error rate per consumer
- Rebalancing frequency
- Memory usage per consumer

When to Scale:
- If lag > 5 mins AND processing speed stable: Add consumers
- If lag growing: Processing bottleneck, optimize code
- If rebalancing frequent: Resource contention, bigger instances
```

---

**Q1c: How would you design a system to handle out-of-order events while maintaining business correctness?**

**Sample Answer:**
```
Scenario: Events arrive out of order (network delays, retries)
Problem: AuthorizationApproved arrives before AuthorizationSubmitted

Solution Architecture:

1. Event Versioning:
   {
     aggregateId: "auth_123",
     version: 3,
     timestamp: ISO,
     event: AuthApproved
   }

2. Ordering by Version + Timestamp:
   - Version: Guaranteed order within aggregate
   - Timestamp: Tiebreaker if versions equal

3. Buffering Strategy:
   - Store events for 5 seconds (max expected delay)
   - Process only when all prior versions received
   - Timeout after 5s: Log warning, process anyway

4. State Validation:
   - Before applying event, check preconditions
   - Reject AuthApproved if state ≠ Submitted
   - Store in DLQ for manual review

5. Idempotency Check:
   - Even if applied twice: Same result
   - Example: Approve already-approved → No-op, return existing

Testing:
- Test suite: Send events in all permutations
- Chaos test: 10-second random delays per event
- Verify: Final state same regardless of order
```

---

### **2. Time-Critical Delivery Under Constraints (3 Questions)**

**Q2: Tell me about a project with tight timelines, fewer resources, and high stakes.**

**Sample Answer:**
```
Situation: Healthcare migration, 3 weeks, skeleton team, fixed go-live

Actions:
1. Scope ruthlessly (3 core features vs 7 nice-to-haves)
2. Parallelize teams (platform + app simultaneously)
3. Automate everything (CI/CD, data validation, smoke tests)
4. POC-driven approach first week
5. Async communication (detailed docs, structured PR reviews)

Tools:
- Feature toggles for incomplete features
- Canary deployment (5% traffic, 24h monitoring)
- Auto-rollback on error > 2%

Outcome:
- On-time delivery
- Zero production incidents week 1
- 99.5% uptime month 1
- Client appreciated transparency
```

---

**Q2b: How do you identify what to cut when time is running out? Walk me through your prioritization method.**

**Sample Answer:**
```
MoSCoW Framework (Moscow, not Russia):

MUST HAVE (Core functionality, without this system is useless):
✔ Patient data import from legacy system
✔ Rules engine (automated 80% of decisions)
✔ Manual review queue (20% need clinician review)
✔ Notifications to clinicians (they won't use without alerts)
✔ Basic security (HIPAA compliance minimum)

SHOULD HAVE (Important, but can be added week 1-2 post-launch):
✔ Analytics dashboard (nice to understand trends, not critical)
✔ Appeals process (can be manual initially)
✔ Advanced reporting (can use basic export first)
✔ Email notifications (SMS might be enough initially)

COULD HAVE (Nice to have, low priority):
✔ Multi-language support (English only for launch)
✔ Voice-based notifications
✔ Custom branding (use generic theme)

WON'T HAVE (Defer to phase 2):
✔ AI-powered decision suggestions
✔ Blockchain audit trail (overkill, database audit is fine)
✔ Predictive analytics
✔ Mobile app (web responsive enough)

Decision Matrix:
Business Impact | Effort | Priority | Decision
High            | Low    | MUST     | Build now
High            | High   | SHOULD   | Cut to SHOULD
Medium          | Low    | SHOULD   | Build
Medium          | High   | COULD    | Cut
Low             | Any    | WON'T    | Defer

Real Example (Healthcare Migration):
- Cut: Complex data validation rules (MVP: basic only)
  * Reason: High effort, can be added later with better testing
- Cut: Multi-tenant support (design for single tenant)
  * Reason: Premature optimization, tenant expansion is phase 2
- Cut: Workflow builder UI (hardcode rules initially)
  * Reason: 3 static rules don't need UI builder
- Keep: Data integrity (ACID transactions required)
  * Reason: Medical data loss = lawsuit
- Keep: Security/compliance (HIPAA audit logging)
  * Reason: Non-negotiable

Stakeholder Communication:
1. Present 3 scenarios:
   - Scenario A: Full feature set = 8 weeks
   - Scenario B: Must-haves only = 3 weeks (chosen)
   - Scenario C: Core only = 2 weeks (risky)

2. Show impact:
   - Scenario B trades "advanced reporting" for "on-time launch"
   - "We can add reporting in week 2, but patients need core system on day 1"

3. Get buy-in:
   - Sign-off document: "We're cutting X, Y, Z intentionally"
   - Reduces mid-project scope creep
```

---

**Q2c: Your team is burned out from crunch time. How do you manage morale while still meeting deadline?**

**Sample Answer:**
```
Red Flags (Time to Intervene):

1. Increased bugs (fatigue → careless mistakes)
   → Action: Code review more carefully, or reduce scope
   → Decision: "We'll cut feature Z, buy 2 days of slack"

2. Slowing velocity (team loses momentum)
   → Action: Unblock immediately, reduce meetings
   → Decision: All standup async, office hours only on request

3. Cynicism or silence (morale down, disengagement)
   → Action: 1-on-1 with each engineer, listen
   → Decision: "Who wants next week off? Plan recovery time"

4. "I'm looking for a new job" (turnover talk)
   → Action: Immediate conversation
   → Decision: Stop and renegotiate timeline with business

5. Zero overtime yet falling behind (plan unrealistic)
   → Action: This isn't a team problem, it's a timeline problem
   → Decision: Negotiate deadline extension or cut more scope

Morale Management (DO):
✔ Celebrate daily wins (stand-up shout-outs of progress)
✔ Reduce meetings (async > sync, no meeting hell)
✔ Remove blockers immediately (don't make them wait for approval)
✔ Rotate on-call (don't burn same person 3 nights straight)
✔ Give context (why deadline matters: "Hospital goes live Monday")
✔ Offer flexibility (10-6 OK if they prefer, not 8-8)
✔ Plan recovery time (3-day weekend after go-live)
✔ Celebrate completion (team lunch, gift cards, public credit)

What NOT To Do:
✗ Blame culture ("Why didn't you finish this?")
✗ Micromanagement ("Walk me through every commit")
✗ Surprise deadlines (communicate early, not Wednesday for Friday)
✗ Scope creep without trade-offs ("Just add this one feature")
✗ Assume everyone's OK with weekends (ask, don't tell)

Real Story:
Week 3 of 3-week project. Team exhausted.
I said: "Weekend work is optional but expected. Those who come in Saturday get Monday off."
- 70% team showed up (peer pressure + incentive)
- We finished features by noon
- Had Sunday celebration (VP paid for catered meal)
- Everyone felt ownership, not resentment

Key Principle:
Make crunch *opt-in* when possible, not *forced*.
- Voluntary: High morale, people own it
- Forced: Resentment, looking for exit doors

Post-Crunch:
- Follow through on time off (don't schedule more work)
- Debrief: What worked? What was awful?
- Improve: Don't make same mistake next time
- Prevent burnout: "No more 3-week crunches"
```

---

### **3. Microservices Architecture & Event Sourcing (3 Questions)**

**Q3a: You're building a clinical review system with multiple aggregates. Design the microservices architecture, define transaction boundaries, and explain how you'd handle consistency.**

**Sample Answer:**
```
Clinical Review Microservices Architecture:

Core Aggregates (Transaction Boundaries):
1. ReviewRequest (entire lifecycle: draft → submitted → completed)
   - State: pending, assigned, in-review, approved, rejected
   - Responsible for: Patient data, request metadata, compliance rules
   - Not responsible for: Clinical comments (separate aggregate)

2. Review (clinician's actions)
   - State: started, reviewed, submitted, escalated
   - Responsible for: Clinician work, timestamps, decision path
   - Not responsible for: Overall request state (parent owns)

3. ClinicalDecision (final outcome)
   - State: pending, approved, rejected, escalated, cancelled
   - Responsible for: Decision + justification, appeal eligibility
   - Not responsible for: Request lifecycle (ReviewRequest owns)

Transaction Boundaries:
- Within aggregate: ACID (atomic, consistent, isolated, durable)
- Across aggregates: Eventual consistency + Saga pattern

Example: ReviewRequest approval
Step 1: ReviewRequest.Approve() → ReviewApprovedEvent
Step 2: → Send event to ReviewService
Step 3: Review.Updated() → ReviewCompletedEvent
Step 4: → Send event to AuthService
Step 5: Auth.UpdateCompliance() → ComplianceUpdatedEvent

If step 4 fails:
- ReviewRequest state: APPROVED (already committed)
- Review state: COMPLETED (already committed)
- Auth state: WAITING (not updated yet)
- Compensating transaction: ReviewRequest.Cancel() → start over

Event Sourcing:
- Events: ReviewRequested, ReviewerAssigned, ReviewCommented, DecisionMade, AppealsInitiated
- Event Store: Cosmos DB, append-only, immutable
- Versioning: Each event has schema version (allows evolution)
- Snapshots: Every 10 events (reduces replay cost)
- Rehydration: Rebuild state from event stream, apply snapshots

Consistency Model:
- Strong: Within aggregate (database transaction)
- Eventual: Across aggregates (async messaging)
- Reconciliation: Scheduled job (nightly) checks for inconsistencies

Data Example:
ReviewRequest aggregate:
{
  id: "REQ-123",
  patientId: "PAT-456",
  state: "APPROVED",
  appliedRules: ["Rule-A", "Rule-B"],
  version: 7,
  timestamp: "2024-01-15T10:00:00Z"
}

Events (immutable):
[
  { type: "ReviewRequested", version: 1, timestamp: "...", patientId: "PAT-456" },
  { type: "ReviewerAssigned", version: 2, timestamp: "...", clinicianId: "DOC-789" },
  { type: "ReviewCommented", version: 3, timestamp: "...", comment: "..." },
  { type: "DecisionMade", version: 4, timestamp: "...", decision: "APPROVED" }
]

Failure Handling:
- Idempotent operations: DecisionMade event has idempotency key
  * If processed twice: 2nd time returns cached result
  * No duplicate state change
- Dead letter queue: If step fails, message goes to DLQ
- Manual intervention: Team reviews DLQ, decides next step
- Retry with backoff: Exponential retry (100ms, 200ms, 400ms)
```

---

**Q3b: A clinician is halfway through writing a review, the service crashes at step 3/5, then comes back up. What happens to their data? Walk me through recovery.**

**Sample Answer:**
```
Scenario:
Clinician clicks "Save Draft" with 5 comments
Service crashes right after persisting comment #4
When system restarts, what state are we in?

Architecture (Transactional Outbox Pattern):

User Action: SaveDraftComment(commentId, text)

Backend Flow:
1. BEGIN transaction
2. Append ReviewCommentedEvent to ReviewEvents table
   {
     id: GUID,
     aggregateId: "REV-123",
     eventType: "CommentAdded",
     commentText: "This needs more info",
     version: 5,
     timestamp: NOW()
   }
3. Append event to OutboxEvents table (polling-based)
   {
     id: GUID,
     eventId: (above),
     aggregateId: "REV-123",
     published: false,
     timestamp: NOW()
   }
4. Update Review aggregate (cache):
   cache["REV-123"].comments.push(newComment)
5. COMMIT transaction

If Crash Scenarios:

Scenario A: Crash before step 2 (before any persistence)
→ ReviewEvents: No event
→ OutboxEvents: No event
→ Frontend: Error response
→ User sees: "Failed to save, please retry"
→ Retry: Works, creates event

Scenario B: Crash at step 3 (after ReviewEvents, within transaction)
→ ReviewEvents: Event is there (database persisted)
→ OutboxEvents: Event started, but COMMIT failed
→ Frontend: Timeout, user retries
→ Retry: Database detects duplicate (unique constraint on eventId)
→ Result: Gracefully handles duplicate, no double-save

Scenario C: Crash at step 5 (after COMMIT, during response)
→ ReviewEvents: ✓ Saved
→ OutboxEvents: ✓ Saved
→ COMMIT: Succeeded, service crashed during response
→ Frontend: Timeout, user refreshes page
→ System state: Event is saved! Comment is there!
→ User sees: Comment appears (exactly-once semantics achieved)

Recovery Process:

Background Job (every 5 minutes):
1. SELECT * FROM OutboxEvents WHERE published = false
2. For each unpublished event:
   a. Publish to Kafka (ReviewTopics)
   b. If Kafka ACK received:
      - Update OutboxEvents SET published = true
   c. If Kafka fails:
      - Leave as unpublished
      - Try again next cycle
      - Alert after 3 failures

Example:
OutboxEvents table before recovery:
┌────┬──────────────┬───────────┐
│ id │ eventId      │ published │
├────┼──────────────┼───────────┤
│ 1  │ event-123    │ true      │
│ 2  │ event-124    │ false     │  ← Unpublished
│ 3  │ event-125    │ false     │  ← Unpublished
└────┴──────────────┴───────────┘

Recovery runs:
1. Find unpublished events (2, 3)
2. Publish event-124 to Kafka → ACK → Set published=true
3. Publish event-125 to Kafka → ACK → Set published=true

Result:
┌────┬──────────────┬───────────┐
│ id │ eventId      │ published │
├────┼──────────────┼───────────┤
│ 1  │ event-123    │ true      │
│ 2  │ event-124    │ true      │  ← Published
│ 3  │ event-125    │ true      │  ← Published
└────┴──────────────┴───────────┘

Frontend Handling:
- Optimistic UI: Show comment immediately while saving
- Save button disabled until confirmed
- If success: Checkmark appears
- If error: Show red error, "Retry" button
- If network timeout: Ask "Unsure if saved. Try again?"

Guarantees Achieved:
✔ No lost comments (even if service crashes)
✔ No duplicate comments (idempotency key prevents replay)
✔ Clinician never confused (UI shows actual state)
✔ Zero manual intervention needed (automatic recovery)
```

---

**Q3c: You're migrating from a monolith to microservices while handling live traffic. How do you avoid downtime? Explain your phased approach.**

**Sample Answer:**
```
Strangler Pattern (Gradual Migration Without Downtime):

Phase 1 (Week 1-2): Parallel Deployment
┌──────────────────┐     ┌──────────────────┐
│ MONOLITH (Prod)  │     │ MICROSERVICES    │
├──────────────────┤     ├──────────────────┤
│ Review API       │     │ Review API (new) │
│ Auth Service     │     │ Auth (new)       │
│ Kafka Consumer   │     │ Kafka (new)      │
└──────────────────┘     └──────────────────┘
   100% traffic            Shadow traffic
                          (5% real users, read-only)

Both read/write same database (monolith DB)
Microservices test in parallel, find bugs early
No downtime, no user impact

Phase 2 (Week 3-4): Canary Switchover
Monolith: 95% traffic
Microservices: 5% traffic (real production requests)

Monitoring (24/7):
- Error rate: Monolith vs Microservices
- Latency: p50/p99 response time
- Business metrics: Reviews approved/hour

If issues detected:
- Automatic rollback to 100% monolith
- Alert team, investigate

Phase 3 (Week 5-6): Gradual Ramp
Day 1: 70% Monolith, 30% Microservices
Day 3: 50% / 50%
Day 5: 30% / 70%
Day 7: 10% / 90%

Each step: 24+ hours monitoring
Issues → rollback entire phase

Phase 4 (Week 7): Full Switchover
Monolith: 0% traffic
Microservices: 100% traffic (live)

Keep monolith running for 2 more weeks (backup)

Phase 5 (Week 9): Decommission
If zero issues for 14 days:
- Shutdown monolith
- Repurpose infrastructure

Risk Mitigation Strategies:

1. Database Coupling (Risk: Consistency issues)
   Strategy: Don't separate databases immediately
   - Microservices still read from monolith DB
   - Use triggers to sync new database when ready
   - Avoids complex cross-service consistency

2. Instant Rollback (Risk: Slow recovery)
   Strategy: Feature flags
   - Route request to monolith or microservices based on flag
   - Flip flag in 30 seconds if issues
   - No deployment needed

3. Backwards Compatibility (Risk: Breaking changes)
   Strategy: API versioning
   - Monolith API v1, Microservices API v2
   - Both available during transition
   - Clients migrate at their own pace

4. Data Replication (Risk: Data divergence)
   Strategy: Log-based CDC (Change Data Capture)
   - Monolith DB → Kafka → Microservices DB
   - Real-time synchronization
   - Manual audits (daily reconciliation queries)

Monitoring Dashboard:

│ Phase 2 (Canary)      │ Monolith      │ Microservices │
├───────────────────────┼───────────────┼───────────────┤
│ Traffic              │ 95%           │ 5%            │
│ Error Rate           │ 0.5%          │ 0.6% ✓ OK     │
│ Latency (p99)        │ 200ms         │ 250ms ✓ OK    │
│ Reviews/hour         │ 1200          │ 120 ✓ OK      │
│ Cost/month           │ $5k (fixed)   │ $200 (running)│
└───────────────────────┴───────────────┴───────────────┘

Rollback Procedure (if issues):
1. Alert fires (error rate > 5% on microservices)
2. Automatic action: Revert traffic to 100% monolith
3. Investigate: What broke?
4. Fix: Deploy patch
5. Resume: Restart phase from beginning

Total Downtime: 0 minutes (or < 1 minute for automatic rollback)
User Experience: Seamless (they don't know migration happening)
```

---

### **4. Azure Architecture & Service Selection (3 Questions)**

**Q4a: Design the complete architecture for a healthcare system: frontend, API layer, compute, data storage, and messaging. Justify each service choice.**

**Sample Answer:**
```
Healthcare Platform Architecture:

PRESENTATION LAYER:
├─ ReactJS + Redux
│  ├─ Client-side state caching (reduces API calls)
│  ├─ Optimistic updates (show results before server confirmation)
│  └─ Offline queue (queue actions, sync when online)
├─ Deployed on: Azure Static Web App
│  ├─ Why: CDN by default, serverless, cheap ($9/month)
│  ├─ Built-in CI/CD (GitHub integration)
│  └─ CORS handling for API calls
└─ Alternative: App Service if custom backend needed

API LAYER:
├─ Azure API Management (APIM)
│  ├─ Rate limiting (prevent abuse: 100 req/min per user)
│  ├─ JWT validation (centralized auth, signed by Azure AD)
│  ├─ Request/response transformation (sanitize PII)
│  ├─ API versioning (v1, v2 coexist during migration)
│  ├─ Analytics (track API usage, find bottlenecks)
│  └─ Cost: ~$300/month (Standard tier)
├─ Behind Azure AppGateway
│  ├─ Web Application Firewall (WAF)
│  ├─ SSL/TLS termination
│  ├─ Path-based routing (route /api/* to APIM, /ui/* to static)
│  ├─ DDoS protection
│  └─ Cost: ~$100/month base
└─ Both provide defense-in-depth

COMPUTE LAYER:
├─ Azure Kubernetes Service (AKS) for production
│  ├─ Microservices: ReviewService, AuthService, NotificationService
│  ├─ Auto-scaling: CPU > 70% → Add pods
│  ├─ Node pools: Spot VMs (80% cheaper for non-critical)
│  ├─ Service mesh: Istio for advanced traffic management (later)
│  ├─ Logging: Container Insights → Log Analytics → Grafana
│  └─ Cost: $200-400/month base + compute
├─ Why AKS (not App Service)?
│  ├─ Event-driven workloads (Kafka consumers)
│  ├─ Custom networking (service mesh, network policies)
│  ├─ Multi-container deployments
│  └─ Cost savings at scale (high container density)
└─ Alternative: Container Apps for simpler services

DATA LAYER:
├─ Azure SQL Server (ACID-required data)
│  ├─ Reviews, decisions, clinical notes (relational schema)
│  ├─ Stored procedures for complex logic
│  ├─ Backups: 7-day retention, geo-redundant
│  ├─ Tier: Standard S3 ($200/month) → handles 1000 concurrent
│  └─ Read replicas: For analytics without blocking transactional
├─ Cosmos DB (NoSQL for events)
│  ├─ Event store: append-only, globally distributed
│  ├─ Session state: TTL = 24 hours (auto-delete)
│  ├─ Provision: Serverless mode ($0.25/million RUs, cheaper at low volume)
│  └─ Backup: Auto 4-hour copies
├─ Azure Cache for Redis (Session cache)
│  ├─ Avoid database hits for session lookup
│  ├─ 10k concurrent users → Basic tier ($15/month)
│  └─ TTL on session keys
└─ PostgreSQL for reference data (Formularies, Rules)
   └─ Read-heavy, large dataset, Standard tier

SEARCH LAYER:
├─ Azure Search Index
│  ├─ Full-text search on clinical notes
│  ├─ Faceted search (filter by status, clinician, date)
│  ├─ Relevance tuning (BM25 algorithm)
│  ├─ Indexing pipeline: SQL → Search Index (scheduled)
│  └─ Cost: Standard tier ($300/month base)
└─ Why not Elasticsearch?
   └─ Managed service (Azure Search) = less ops overhead

MESSAGING:
├─ Event Hubs (Real-time event streaming)
│  ├─ Authorization events (DecisionMade, ReviewCompleted)
│  ├─ Partitions: 32 (high throughput)
│  ├─ Retention: 7 days
│  ├─ Consumer groups: Dashboard (real-time), Analytics (delayed)
│  └─ Cost: $100/month (Standard)
├─ Service Bus (Commands & async workflows)
│  ├─ SendNotification command (guarantee delivery)
│  ├─ Dead letter queue for failed messages
│  ├─ Topics: Notifications, AuditLog, Escalations
│  └─ Cost: $50/month (Standard)
└─ Why not both Kafka?
   └─ No self-managed infrastructure, Azure manages

AUTHENTICATION:
├─ Azure AD B2C (Patient portal)
│  ├─ Self-service signup/signin
│  ├─ OIDC/OAuth 2.0 flows
│  ├─ Custom policies for MFA
│  ├─ Branding: Customizable login page
│  └─ Cost: Included in subscription
├─ Azure AD (Clinician authentication)
│  ├─ Enterprise directory integration
│  ├─ Multi-factor authentication
│  ├─ Conditional access (IP-based, device-based)
│  └─ Cost: Included
└─ Token issuance: JWT signed by Azure AD
   └─ Validated at APIM, cached in Redis

SECURITY:
├─ Azure Key Vault
│  ├─ Secrets: DB connection strings, API keys
│  ├─ Certificates: SSL/TLS for services
│  ├─ HSM: Hardware security module for high-sensitivity keys
│  ├─ Access control: RBAC on vault level
│  └─ Cost: $0.60/month per vault
├─ Managed Identity
│  ├─ Services authenticate to Key Vault (no secrets in code)
│  ├─ AKS pods get identity, access Azure resources
│  └─ Eliminates credential management
├─ Network Security:
│  ├─ VNet: Private subnet for AKS, APIM, databases
│  ├─ Private endpoints: No internet exposure for databases
│  ├─ Network policies on AKS: Pod-to-pod communication control
│  ├─ NSG (Network Security Groups): Firewall rules
│  └─ Example: Only APIM can talk to AKS
└─ Data Encryption:
   ├─ At rest: Encryption enabled on all storage
   └─ In transit: TLS 1.3 everywhere

NETWORKING:
├─ VNet with subnets:
│  ├─ Public subnet: AppGateway (internet-facing)
│  ├─ Private subnet: APIM (not internet-accessible)
│  ├─ Cluster subnet: AKS nodes (fully private)
│  └─ Database subnet: SQL, Cosmos (no internet)
├─ Private Link:
│  ├─ Databases accessible only from VNet
│  ├─ No data leaves Azure backbone network
│  └─ Compliant with healthcare data residency
└─ DDoS Protection: Standard (managed by Azure)

MONITORING & LOGGING:
├─ Application Insights
│  ├─ Traces: Application logs, request telemetry
│  ├─ Dependency tracking: SQL, Redis, Event Hubs calls
│  ├─ Alerts: Error rate > 5%, latency > 1s
│  ├─ Sampling: 100% for errors, 10% for normal requests
│  └─ Cost: ~$20/month
├─ Log Analytics Workspace
│  ├─ Container Insights logs (AKS pod metrics)
│  ├─ Query language: KQL (powerful analytics)
│  ├─ Retention: 30 days default
│  └─ Cost: ~$30/month
└─ Alerts:
   ├─ CPU > 80% on AKS → Page on-call engineer
   ├─ Error rate spike → Slack notification
   └─ SQL deadlock → Auto-escalate to DBA

INFRASTRUCTURE AS CODE:
├─ Bicep files (Azure's IaC language)
│  ├─ Define all services above
│  ├─ Parameters: Environment (dev/staging/prod)
│  ├─ Outputs: Connection strings, endpoints
│  └─ Git-tracked, reviewed, versioned
└─ Terraform alternative (multi-cloud)

COST ESTIMATE:
Service          | Monthly Cost | Notes
──────────────────────────────────────
Static Web App   | $9           | Free tier OK for <100GB
APIM             | $300         | Standard tier
AppGateway       | $100         | Minimal base
AKS              | $400         | 10 nodes, spot VM for non-critical
SQL Server       | $200         | Standard S3
Cosmos DB        | $100         | Serverless
Event Hubs       | $100         | Standard
Service Bus      | $50          | Standard
Azure Search     | $300         | Standard
Key Vault        | $1           | Negligible
Application Insights | $20      | Basic monitoring
Log Analytics    | $30          | Log retention
──────────────────────────────────────
TOTAL            | ~$1,610      | Mature, highly available system

Scaling Plan:
- 100k users → No changes needed
- 1M users → Add more AKS nodes, SQL read replicas
- 10M users → Partition data by region, multi-region failover
```

---

**Q4b: Your healthcare system needs to integrate with 3 external systems (EHR, Insurance Claims, Pharmacy). Design resilient integration without cascading failures.**

**Sample Answer:**
```
Resilience Architecture for External Integrations:

EXTERNAL SYSTEM 1: EHR (Real-time API, Synchronous)
├─ Purpose: Fetch patient demographics, insurance eligibility
├─ API: REST, HTTPS
├─ Timeout: 5 seconds (fail fast, don't block clinician)
├─ Retry policy:
│  ├─ Exponential backoff: 100ms → 200ms → 400ms (max 5 seconds total)
│  └─ Retry on: 5xx errors, timeouts (NOT 4xx, that's user error)
├─ Circuit Breaker:
│  ├─ Open after 5 failures in 60 seconds
│  ├─ Stay open for 30 seconds
│  ├─ Half-open state: Allow 1 probe request
│  └─ If probe succeeds: Close circuit, resume normal
├─ Fallback:
│  ├─ Cache patient data for 24 hours
│  ├─ If EHR down: Use cached patient data
│  ├─ Clinician warned: "Data from yesterday, may be stale"
│  └─ Patient notified if critical info is outdated
└─ Implementation (Polly in C#):
   ```csharp
   var ehrClient = new HttpClient();
   var retryPolicy = Policy
       .Handle<HttpRequestException>()
       .Or<TimeoutException>()
       .Or<OperationCanceledException>()
       .WaitAndRetryAsync(
           retryCount: 3,
           sleepDurationProvider: attempt => 
               TimeSpan.FromMilliseconds(Math.Pow(2, attempt) * 100)
       );
   
   var circuitBreakerPolicy = Policy
       .Handle<HttpRequestException>()
       .OrResult<HttpResponseMessage>(r => !r.IsSuccessStatusCode)
       .CircuitBreakerAsync(
           handledEventsAllowedBeforeBreaking: 5,
           durationOfBreak: TimeSpan.FromSeconds(30)
       );
   
   var timeoutPolicy = Policy.TimeoutAsync(TimeSpan.FromSeconds(5));
   var fallbackPolicy = Policy
       .WrapAsync(retryPolicy, circuitBreakerPolicy, timeoutPolicy);
   ```

EXTERNAL SYSTEM 2: Insurance Claims (Batch API, Async)
├─ Purpose: Send approved requests to insurance for reimbursement
├─ API: SFTP + batch upload (not real-time)
├─ Schedule: Every 6 hours (00:00, 06:00, 12:00, 18:00 UTC)
├─ Timeout: 30 seconds (batch jobs have more patience)
├─ Retry policy:
│  ├─ Batch job fails → Retry next cycle (6 hours later)
│  ├─ Failed 2 cycles → Alert on-call engineer
│  └─ Failure reason: Network down, Insurance system down, invalid data
├─ Fallback:
│  ├─ Store batch in local queue (Azure Service Bus)
│  ├─ Retry indefinitely until success
│  ├─ Manual override: Operator can re-run batch anytime
│  └─ Cost: No user wait time (async)
├─ Monitoring:
│  ├─ Alert: Batch job takes > 5 minutes (unusual)
│  ├─ Alert: Batch job fails 2 consecutive times
│  ├─ Dashboard: Show last 10 batch executions, success rate
│  └─ Data: How many claims sent, how many succeeded
└─ Implementation (Durable Functions in Azure):
   ```csharp
   [FunctionName("InsuranceBatchOrchestrator")]
   public static async Task RunOrchestrator(
       [OrchestrationTrigger] IDurableOrchestrationContext context)
   {
       var input = context.GetInput<BatchInput>();
       
       // Retry: 3 times, every 6 hours if fails
       var retryOptions = new RetryOptions(
           firstRetryInterval: TimeSpan.FromHours(6),
           maxNumberOfAttempts: 3);
       
       try 
       {
           await context.CallActivityWithRetryAsync(
               "SendInsuranceBatch", retryOptions, input);
       }
       catch (Exception ex)
       {
           // After 3 attempts failed, alert team
           await context.CallActivityAsync("AlertEngineer", ex.Message);
       }
   }
   ```

EXTERNAL SYSTEM 3: Pharmacy (Message Queue, Event-driven)
├─ Purpose: Receive pharmacy prescriptions, send confirmations
├─ API: HL7 v2 messages via Azure Service Bus
├─ Provider sends → We consume → We send ACK
├─ Timeout: 10 seconds per message (message processing)
├─ Poison message handling:
│  ├─ Failed to parse HL7: Move to Dead Letter Queue (DLQ)
│  ├─ DLQ stored for 14 days
│  ├─ Manual review: Operator checks DLQ, decides action
│  ├─ Options: Replay, discard, fix and retry
│  └─ Alert: "3 poison messages in DLQ, investigate"
├─ Idempotency:
│  ├─ Pharmacy sends same message twice (network retry)
│  ├─ We detect duplicate (message ID in dedup store)
│  ├─ Send ACK without re-processing
│  └─ Result: Pharmacy thinks message processed only once
├─ Guaranteed delivery:
│  ├─ Message remains in queue until ACK received
│  ├─ If we crash before ACK: Message redelivered
│  ├─ Our idempotency key prevents duplicate processing
│  └─ Net result: Exactly-once semantics
└─ Implementation (Azure Service Bus):
   ```csharp
   public async Task ProcessPharmacyMessage(
       ServiceBusReceivedMessage message, 
       ServiceBusMessageActions messageActions,
       ILogger log)
   {
       var deduplicationKey = message.MessageId;
       
       // Check if already processed
       var existing = await _deduplicationStore.Get(deduplicationKey);
       if (existing != null)
       {
           log.LogInformation("Duplicate message, skipping");
           await messageActions.CompleteMessageAsync(message);
           return;
       }
       
       try 
       {
           var hl7Message = ParseHL7(message.Body);
           await ProcessPrescription(hl7Message);
           
           // Store as processed
           await _deduplicationStore.Store(deduplicationKey, hl7Message);
           
           // Send ACK to Pharmacy
           await _serviceBusClient.SendAsync(
               "pharmacy-ack-queue", 
               new ServiceBusMessage($"ACK:{message.MessageId}"));
           
           // Complete message in Service Bus
           await messageActions.CompleteMessageAsync(message);
       }
       catch (Exception ex)
       {
           log.LogError($"Error processing pharmacy message: {ex}");
           
           // Move to Dead Letter Queue (auto-handled by Service Bus)
           await messageActions.DeadLetterMessageAsync(message);
       }
   }
   ```

UNIFIED RESILIENCE PATTERNS:

1. Timeouts (Don't wait forever):
   System        | Timeout  | Rationale
   ─────────────────────────────────────
   EHR           | 5s       | User-facing, fail fast
   Insurance     | 30s      | Batch job, not blocking
   Pharmacy      | 10s      | Message processing
   ─────────────────────────────────────

2. Circuit Breakers (Stop hammering failed service):
   - Protects EHR: Don't keep retrying if it's down
   - Fallback to cached data while EHR recovers
   - Automatic recovery: Circuit checks every 30 seconds

3. Fallback Strategies:
   System        | Level 1          | Level 2              | Level 3
   ─────────────────────────────────────────────────────────────
   EHR           | Cache (24h)      | Null defaults        | Manual lookup
   Insurance     | Service Bus      | Retry next cycle     | Alert team
   Pharmacy      | Poison DLQ       | Manual intervention  | Pharmacy support
   ─────────────────────────────────────────────────────────────

4. Monitoring Checklist:
   ☐ Alert if EHR unavailable > 5 minutes
   ☐ Alert if Insurance batch failed 2x
   ☐ Alert if Pharmacy poison queue > 5 messages
   ☐ Dashboard: Integration health (green/yellow/red)
   ☐ Metrics: Latency p99 per integration
   ☐ Metrics: Success rate % per integration

5. Testing:
   Test Case               | Method          | Expectation
   ──────────────────────────────────────────────────────
   EHR timeout           | Mock delay 10s   | Fail fast, use cache
   EHR down (circuit)    | Mock 404         | After 5 failures, circuit opens
   Insurance batch fails | Mock SFTP error  | Retry next cycle
   Pharmacy poison msg   | Send invalid HL7 | Move to DLQ, alert

Deployment:
- EHR integration: AKS microservice + Redis cache
- Insurance batch: Durable Function (Azure) + Service Bus
- Pharmacy consumer: AKS microservice + Service Bus listener
```

---

**Q4c: Your Azure bill jumped from $8k to $12k per month. How would you identify the culprit and optimize to $6k?**

**Sample Answer:**
```
Cost Audit Process:

Step 1: Identify Cost Increases
Use: Azure Cost Management + Billing
Time period: Last 30 days vs previous 30 days
Drill down by:
- Service type (compute, storage, networking)
- Resource group (production, staging, dev)
- Resource (specific AKS cluster, database)

Example Output:
Service          | Last Month | This Month | Change
──────────────────────────────────────────────
AKS              | $3,000     | $5,000     | +$2,000 ← CULPRIT
SQL Database     | $300       | $300       | —
Cosmos DB        | $200       | $600       | +$400 ← Also high
App Service      | $100       | $150       | +$50
Storage          | $50        | $50        | —
──────────────────────────────────────────
TOTAL            | $8,000     | $12,000    | +$4,000

Step 2: Investigate AKS Spike (+$2,000)

Query AKS metrics:
- Node count: Was 10 nodes, now 25 nodes (auto-scaled?)
- Instance type: Upgraded from Standard_B2s to Standard_D4s_v3?
- What caused the spike?
  Option A: Auto-scaling triggered (high load)
  Option B: Manual scale-up forgotten
  Option C: New deployment consuming more resources
  Option D: Zombie pods (stuck resources)

Commands to investigate:
$ kubectl top nodes
NAME                CPU(cores)  MEM(GB)
aks-node-0          2500m       3.5
aks-node-1          2400m       3.2
... (25 more nodes)
→ Total: ~2400m CPU avg per node = 60 units × 25 = 1500m
→ If only 30% utilized, scale down to 10 nodes

$ kubectl top pods
POD                           CPU(cores)  MEM(GB)
review-service-abc12         1500m       2.0
notification-service-def34   800m        1.5
... (many more)
→ Find pods with high usage, optimize

Step 3: Investigate Cosmos DB Spike (+$400)

Query Cosmos DB metrics:
- RUs consumed: Was 1000 RU/s, now 5000 RU/s?
- Why increased? (more events, inefficient queries, hot partitions)
- Cost model: Provisioned vs Serverless?

Commands to investigate:
- Query: SELECT * FROM c WHERE c.partition = 'hot'
- Find hot partitions (all queries hitting same key)
- Check query latency, RU consumption per query

Possible causes:
- Bug: Query running in loop (new feature)
- Load: More events (expected if more users)
- Inefficiency: SELECT * instead of SELECT specific fields
- Indexing: Missing index on frequently filtered field

Step 4: Cost Optimization Plan

OPTIMIZATION #1: AKS Downsizing ($5,000 → $2,000)

Current setup:
- 25 Standard_D4s_v3 nodes = $200/month each = $5,000
- Average CPU utilization: 30%
- Average Memory utilization: 35%

Analysis:
- Why 25 nodes? Unknown, probably auto-scaled due to spike
- Do we need 25? NO, probably 10 sufficient
- Trade-off: Slightly slower peak performance, significant cost savings

Solution:
1. Set max nodes = 12 (was unlimited)
   a. Prevents future unexpected scaling
   b. Keeps some headroom for spikes
2. Scheduled scale-down (nights):
   a. 2 AM - 6 AM: Scale down to 3 nodes (batch jobs only)
   b. 6 AM: Scale back to 10
   c. Saves: $100-150/month (non-critical hours)
3. Use Spot VMs for non-critical workloads:
   a. Spot VMs: 80% cheaper than standard
   b. Risk: Eviction notice 30 seconds before termination
   c. Use for: Batch jobs, analytics, non-blocking services
   d. Cost: $40/month instead of $200/month per node
   e. Savings: $150/month (4 spot nodes for batch)
4. Node size reduction:
   a. Current: Standard_D4s_v3 ($200/month, 4 CPU, 16GB RAM)
   b. New: Standard_B2s ($30/month, 2 CPU, 4GB RAM)
   c. Trade-off: Lower peak performance, sufficient for average
   d. Savings: $170 × 10 nodes = $1,700/month

Sub-total savings: ~$2,500/month

OPTIMIZATION #2: Cosmos DB Efficiency ($600 → $150)

Current: Provisioned 5000 RU/s = $600/month
Analysis:
- Spike cause: Hot partition on ReviewRequest aggregate
- All queries filtering by patientId → hits same partition
- Solution: Refactor to use better partition key

Fix:
1. Repartition by:
   - Old: partition=patientId (hot, all patients vs few clinicians)
   - New: partition=clinicianId (more even distribution)
   - Or composite: partition={year}/{month}/clinicianId
2. Re-index with better key
3. New RU consumption: 1000 RU/s instead of 5000
4. New cost: $120/month instead of $600

Alternative: Switch to serverless
- Current (provisioned): 5000 RU/s = $600/month
- Serverless: Pay per operation = ~$100/month for same load
- Trade-off: No burst capacity (if load spikes, queries slow)
- Decision: Choose serverless (acceptable risk)

Sub-total savings: ~$450/month

OPTIMIZATION #3: SQL Database Right-sizing ($300 → $150)

Current: Premium P6 tier = $300/month
Analysis:
- DTU utilization: Peak 40%, average 20%
- Why premium? Legacy decision, never revisited
- Read/write split: 70% reads, 30% writes

Fix:
1. Downgrade to: Standard S3 tier = $50/month
   - Capacity: 200 DTUs (vs 1000 in P6)
   - Performance: Slight slowdown on peak (acceptable)
   - Savings: $250/month
2. Add read replica (separate Standard S2):
   - For read-heavy queries (analytics, dashboards)
   - Route reads to replica, writes to primary
   - Cost: $75/month extra
   - But eliminates contention, net improvement
3. Archive old data:
   - Move 2-year-old reviews to Archive tier (cold storage)
   - Cost: $10/month for archive storage
   - Speedup: Fewer rows to scan on current data

Sub-total savings: ~$150/month

OPTIMIZATION #4: Other Services

App Service:
- Reduce instance type (if using App Service)
- Estimated savings: $30-50/month

Storage:
- Review retention policies (don't keep everything)
- Delete test/dev storage accounts
- Estimated savings: $20-30/month

Total Optimization Plan:
Service         | Current | Optimized | Savings
──────────────────────────────────────────────
AKS             | $5,000  | $2,500    | $2,500
Cosmos DB       | $600    | $150      | $450
SQL Database    | $300    | $150      | $150
App Service     | $150    | $120      | $30
Storage         | $50     | $30       | $20
Networking      | $200    | $200      | —
──────────────────────────────────────────────
TOTAL           | $12,000 | $6,350    | $5,650

Result: Exceeded target ($6k), achieved $6.35k (~$350 over)
Final step: Remove some non-critical service or negotiate further

Risk Mitigation:
- Monitoring: Alert if latency > 1 second (indicates undersizing)
- Auto-scale: Restore to original if demand spikes
- Gradual rollout: Implement changes one at a time, measure impact
- Backup plan: Document how to scale back up quickly

Cost Governance Going Forward:
1. Weekly cost review (Monday morning)
2. Budget alerts: Set hard limits per service
3. Reserved instances: For predictable workloads (longer commitment = lower cost)
4. Spot VMs: Use for non-critical workloads (70% savings)
5. Cleanup schedule: Every quarter, remove unused resources
6. Enforce tagging: By cost center, project, environment (enables chargeback)
```

---

### **5. Orchestrator vs Choreography (3 Questions)**

**Q5a: Design a multi-step clinical approval workflow. Should you use orchestrator or choreography pattern? Explain the tradeoffs.**

**Sample Answer:**
```
Clinical Approval Workflow (5 Steps):
1. Patient submits authorization request
2. Verify patient eligibility (check insurance)
3. Route to appropriate clinician based on specialty
4. Clinician reviews and makes decision
5. Send decision to insurance + patient

OPTION A: Orchestrator Pattern

Central Authority: ReviewOrchestrator service
├─ Step 1: ReviewRequested event
├─ Step 2: Verify eligibility (call EligibilityService)
├─ Step 3: Assign to clinician (call AssignmentService)
├─ Step 4: Wait for clinical decision (watch ReviewService)
├─ Step 5: Send to insurance (call InsuranceService)
└─ Compensations: If step 3 fails, unassign from step 2

Benefits:
✔ Clear audit trail: "This is the flow"
✔ Easy debugging: Orchestrator owns entire workflow
✔ Compliance: Regulatory approval = explicit sequence
✔ Testing: Mock services, test end-to-end
✔ Error handling: Explicit compensations

Drawbacks:
✗ Tight coupling: Orchestrator knows all services
✗ Bottleneck: Orchestrator becomes single point of failure
✗ Scaling: Complex state management at scale
✗ Reusable steps: Hard to share (coupled to orchestrator)

Code Example (Orchestrator):
```csharp
public class ReviewApprovalOrchestrator
{
    public async Task ApproveReview(ReviewRequest request)
    {
        try 
        {
            // Step 1: Create request (implicit)
            var review = new Review { Id = request.Id };
            
            // Step 2: Verify eligibility
            var eligibility = await _eligibilityService.CheckEligibility(
                request.PatientId, request.InsurerId);
            
            if (!eligibility.IsEligible)
            {
                await _insuranceService.NotifyIneligible(request);
                return; // Early exit
            }
            
            // Step 3: Assign to clinician
            var assignment = await _assignmentService.AssignClinician(
                request.SpecialtyRequired);
            
            if (assignment == null)
            {
                // Compensation: No clinician available, alert supervisor
                await _supervisorService.AlertNoCapacity(request);
                return;
            }
            
            review.AssignedClinician = assignment.ClinicianId;
            
            // Step 4: Wait for clinical decision
            var decision = await _reviewService.WaitForDecision(
                request.Id, timeout: TimeSpan.FromDays(7));
            
            if (decision == null)
            {
                // Timeout: Escalate to supervisor
                await _supervisorService.Escalate(request.Id);
                return;
            }
            
            // Step 5: Send to insurance
            await _insuranceService.SendDecision(request, decision);
            
            // Success: Mark as completed
            await _reviewService.MarkCompleted(request.Id);
        }
        catch (Exception ex)
        {
            // Error: Log and compensate
            _logger.LogError($"Approval failed: {ex}");
            await _reviewService.MarkFailed(request.Id);
        }
    }
}
```

OPTION B: Choreography Pattern

Event-driven, no central authority:
ReviewService publishes → ReviewRequested event
├─ EligibilityService listens → CheckEligibility → EligibilityVerified event
├─ AssignmentService listens → EligibilityVerified → AssignClinician → ClinicalianAssigned event
├─ ReviewService listens → ClinicalianAssigned → CreateReview → Ready for clinician
├─ InsuranceService listens → DecisionMade → SendDecision → DecisionSent event
└─ PatientService listens → DecisionSent → NotifyPatient → PatientNotified event

Benefits:
✔ Loose coupling: Services independent, don't know each other
✔ Scalable: Easy to add new services (just listen to events)
✔ Autonomous: Each service owns its data
✔ Resilient: One failure doesn't block others

Drawbacks:
✗ Hard to understand flow: No single place to see workflow
✗ Complex debugging: Trace events across 5 services
✗ No audit trail: "Why did this happen?" is hard to answer
✗ Distributed transactions: Harder to rollback (no single point)
✗ Eventual consistency: Patient might see decision before it's saved

Code Example (Choreography):
```csharp
// EligibilityService listens to ReviewRequested
[FunctionName("CheckEligibilityOnReviewRequested")]
public async Task ProcessReviewRequested(
    [ServiceBusTrigger("review-events")] 
    ReviewRequestedEvent @event)
{
    var eligibility = await CheckEligibility(
        @event.PatientId, @event.InsurerId);
    
    // Publish eligibility result
    var eligibilityEvent = eligibility.IsEligible 
        ? new EligibilityVerifiedEvent { ... }
        : new IneligibilityEvent { ... };
    
    await _publishEvents(eligibilityEvent);
}

// AssignmentService listens to EligibilityVerified
[FunctionName("AssignClinicianOnEligibility")]
public async Task ProcessEligibilityVerified(
    [ServiceBusTrigger("eligibility-events")] 
    EligibilityVerifiedEvent @event)
{
    var clinician = await AssignClinician(@event.SpecialtyRequired);
    
    // Publish assignment result
    await _publishEvents(new ClinicalianAssignedEvent 
    { 
        ClinicianId = clinician.Id 
    });
}
```

WHICH TO CHOOSE?

For Healthcare (Regulatory, Compliance):
→ **ORCHESTRATOR** is better

Reasons:
1. Audit trail: Regulators need to see exact flow
2. Compliance: "Show me the approval path for request XYZ"
3. Deterministic: Same input = same flow (important for audits)
4. Explicit error handling: Clear compensations

For E-commerce (Resilience, Scale):
→ **CHOREOGRAPHY** is better

Reasons:
1. Loose coupling: New integrations (like new payment method) don't affect others
2. Resilience: One slow service doesn't block rest
3. Scale: Add services without changing core

Decision Matrix:
Criteria              | Orchestrator | Choreography
──────────────────────────────────────────────────
Regulatory audit     | ✓ Good       | ✗ Poor
Understanding flow   | ✓ Easy       | ✗ Hard
Adding new services  | ✗ Coupling   | ✓ Independent
Debugging            | ✓ Centralized| ✗ Distributed
Error handling       | ✓ Explicit   | ✗ Implicit
Performance          | ✗ Bottleneck | ✓ Decoupled
──────────────────────────────────────────────────

For clinical system: Choose Orchestrator
```

---

**Q5b: Your orchestrator becomes a bottleneck (1000 concurrent workflows). How would you scale it without moving to choreography?**

**Sample Answer:**
```
Orchestrator Bottleneck Scenarios:

Symptom 1: CPU maxed on orchestrator (1000 concurrent reviews)
├─ Cause: Single-threaded sync operations
├─ Fix: Async/await (C#) → Handle 1000 concurrently on single machine
└─ Impact: Can scale from 100 req/s to 1000 req/s

Symptom 2: Database maxed (state management)
├─ Cause: Orchestrator constantly reading/writing workflow state
├─ Fix: Distributed cache (Redis) for hot workflows
└─ Impact: Reduce DB load 90%

Symptom 3: Single instance failure = all workflows stop
├─ Cause: No redundancy
├─ Fix: Run 3+ instances, load balance
└─ Impact: Can lose 1 instance, 2 still running

Scaling Strategy 1: Vertical Scaling (Single, bigger machine)

FROM: Single Small (1 vCPU, 2GB)
TO: Single Large (4 vCPU, 16GB)

Cost: 4x cheaper than 4 machines
Throughput: Handles 1000 concurrent (async processing)
Limitation: Still single instance (fails, everything stops)

Implementation:
```csharp
public class AsyncOrchestrator
{
    // Use async/await to handle concurrency
    public async Task ApproveReviewAsync(ReviewRequest request)
    {
        // Non-blocking await
        var eligibility = await _eligibilityService
            .CheckEligibilityAsync(request.PatientId);
        
        var assignment = await _assignmentService
            .AssignClinicianAsync(request.Specialty);
        
        // All operations concurrent, single thread handles 1000s
    }
}
```

Scaling Strategy 2: Horizontal Scaling (Multiple instances)

3 Orchestrator instances (each can handle 500 concurrent)
└─ Load Balancer (Round-robin)
   ├─ Instance 1: Workflows A, B, C
   ├─ Instance 2: Workflows D, E, F
   └─ Instance 3: Workflows G, H, I

State Persistence (critical):
- Orchestrator state in Redis (not in-memory)
- If Instance 1 crashes, Instance 2 picks up its workflows
- Each instance just consumes state from Redis

Implementation (Durable Functions):
```csharp
[FunctionName("ReviewOrchestrator")]
public async Task RunOrchestrator(
    [OrchestrationTrigger] IDurableOrchestrationContext context)
{
    // This function runs on ANY instance (not tied to specific machine)
    // State persisted to Azure storage
    // Can be resumed on different instance if first one crashes
    
    var input = context.GetInput<ReviewRequest>();
    
    var eligibility = await context.CallActivityAsync(
        "CheckEligibility", input);
    
    // If service crashes here, another instance picks up from this point
    
    var assignment = await context.CallActivityAsync(
        "AssignClinician", input.Specialty);
}
```

Scaling Strategy 3: Partitioning by Workflow Type

Separate orchestrators for different workflow types:
├─ FastTrack: Simple approvals (1-2 minutes)
│  └─ Handles 5000 req/sec (mostly fast path)
├─ Standard: Normal approvals (1-7 days)
│  └─ Handles 1000 req/sec (longer-running)
└─ Complex: Multi-level reviews (up to 30 days)
   └─ Handles 100 req/sec (rare, complex)

Benefits:
✔ Each orchestrator tuned for its workflow type
✔ Fast-track doesn't compete with slow complex reviews
✔ Easier scaling: Add instance to FastTrack as needed

Implementation:
```csharp
[FunctionName("ReviewOrchestrator")]
public async Task RouteReview(
    [ServiceBusTrigger("reviews")] ReviewRequest request,
    IAsyncCollector<ReviewRequest> fastTrackQueue,
    IAsyncCollector<ReviewRequest> standardQueue,
    IAsyncCollector<ReviewRequest> complexQueue)
{
    // Route based on complexity
    if (request.Complexity == "FAST_TRACK")
        await fastTrackQueue.AddAsync(request);
    else if (request.Complexity == "STANDARD")
        await standardQueue.AddAsync(request);
    else
        await complexQueue.AddAsync(request);
}

[FunctionName("FastTrackOrchestrator")]
public async Task ProcessFastTrack(
    [ServiceBusTrigger("fast-track")] ReviewRequest request)
{
    // Simple, optimized flow for fast-track
}

[FunctionName("StandardOrchestrator")]
public async Task ProcessStandard(
    [ServiceBusTrigger("standard")] ReviewRequest request)
{
    // Full flow for standard
}
```

Scaling Strategy 4: Hybrid (Orchestrator + Mini-Choreography)

Keep orchestrator for main flow, use choreography for substeps:

Orchestrator (Central):
├─ Verify eligibility
├─ Assign clinician
├─ **Delegate** clinical decision to choreography
├─ Send to insurance
└─ Notify patient

Choreography (Sub-workflow):
Clinical decision flow:
├─ ClinicalReviewStarted (event)
├─ ClinicalianAddsComment (event)
├─ ClinicalianMakesDecision (event)
└─ DecisionMade (event back to orchestrator)

Benefits:
✔ Orchestrator handles only critical steps (small state, fast)
✔ Complex clinical review (comments, iterations) handled by choreography
✔ Orchestrator waits for DecisionMade event, then continues

Monitoring Checklist for Scaled Orchestrator:
☐ Orchestrator CPU: < 80% (headroom for spikes)
☐ Workflow latency: p99 < 2 seconds (fast response)
☐ State size: < 100KB per workflow (light state)
☐ Redis hit rate: > 95% (cache effective)
☐ Failed workflow rate: < 0.1% (healthy)
☐ Instance count: Can scale ±1 without impact (elasticity)
```

---

**Q5c: An orchestration step fails halfway through. How would you implement a compensating transaction to maintain consistency?**

**Sample Answer:**
```
Scenario: Clinical assignment fails after eligibility verified

Flow:
Step 1 ✓ VERIFIED: Patient is eligible
Step 2 ✗ FAILED: No clinician available for specialty

Problem:
- Eligibility service updated its cache
- System says patient is eligible (true)
- But no clinician assigned (incomplete)
- Clinician dashboard shows no pending review (good)
- But backend state is inconsistent

Solution: Compensating Transactions (Saga Failure Handling)

Orchestrator Pattern for Forward Flow:
Step 1: VerifyEligibility (service: EligibilityService)
   ├─ Input: patientId, insuranceId
   ├─ Success: EligibilityVerifiedEvent
   ├─ Failure: EligibilityFailedEvent
   └─ Compensation: UndoEligibilityVerification

Step 2: AssignClinician (service: AssignmentService)
   ├─ Input: specialty, priority
   ├─ Success: ClinicalianAssignedEvent
   ├─ Failure: NoClinicianAvailableEvent
   └─ Compensation: UnassignClinician

Step 3: CreateReview (service: ReviewService)
   ├─ Input: patientId, clinicianId
   ├─ Success: ReviewCreatedEvent
   └─ Compensation: DeleteReview

Step 4: NotifyClinic ian (service: NotificationService)
   ├─ Input: clinicianId, reviewId
   ├─ Success: ClinicalNotifiedEvent
   └─ Compensation: CancelNotification

Step 5: SendToInsurance (service: InsuranceService)
   ├─ Input: reviewId, decision
   ├─ Success: InsuranceNotifiedEvent
   └─ Compensation: ReverseInsuranceNotification

Failure Scenario 1: Failure at Step 2 (No clinician available)

Forward Actions Completed:
✔ Step 1: VerifyEligibility (DONE)

Backward Actions (Compensations):
1. Call EligibilityService.UndoEligibilityVerification(patientId)
   ├─ Action: Update eligibility cache, mark as "pending human review"
   ├─ Data change: eligibility.status = "PENDING_MANUAL"
   └─ Alert: Send to supervisor for manual assignment

2. Mark Review as FAILED (in database)
   ├─ Reason: "No clinician available"
   ├─ Retry: Schedule automatic retry after 4 hours
   └─ Manual: Supervisor can assign manually anytime

Implementation (Orchestrator with Compensations):
```csharp
[FunctionName("ReviewOrchestrator")]
public async Task RunOrchestrator(
    [OrchestrationTrigger] IDurableOrchestrationContext context)
{
    var request = context.GetInput<ReviewRequest>();
    var undoStack = new Stack<Func<Task>>();
    
    try
    {
        // Step 1: Verify Eligibility
        var eligibility = await context.CallActivityAsync(
            "VerifyEligibility", request);
        
        // Register compensation for step 1
        undoStack.Push(async () => 
            await context.CallActivityAsync("UndoEligibility", request));
        
        // Step 2: Assign Clinician
        var clinician = await context.CallActivityAsync(
            "AssignClinician", request.Specialty);
        
        if (clinician == null)
        {
            // Assignment failed, compensate
            throw new NoClinicianAvailableException();
        }
        
        // Register compensation for step 2
        undoStack.Push(async () => 
            await context.CallActivityAsync("UnassignClinician", 
                new { request.Id, clinician.Id }));
        
        // Step 3: Create Review
        var review = await context.CallActivityAsync(
            "CreateReview", new { request.Id, clinician.Id });
        
        // Register compensation for step 3
        undoStack.Push(async () => 
            await context.CallActivityAsync("DeleteReview", review.Id));
        
        // Step 4: Notify Clinician
        await context.CallActivityAsync(
            "NotifyClinician", new { clinician.Id, review.Id });
        
        // Register compensation for step 4
        undoStack.Push(async () => 
            await context.CallActivityAsync("CancelNotification", 
                new { clinician.Id, review.Id }));
        
        // Step 5: Send to Insurance
        await context.CallActivityAsync(
            "SendToInsurance", new { review.Id });
        
        // Success: All steps completed
        await context.CallActivityAsync("MarkCompleted", request.Id);
    }
    catch (Exception ex)
    {
        // Error: Execute compensations in reverse order (LIFO)
        while (undoStack.Count > 0)
        {
            var compensation = undoStack.Pop();
            try
            {
                await compensation();
            }
            catch (Exception compEx)
            {
                // Log compensation failure, continue with remaining
                context.CreateTimer(
                    context.CurrentUtcDateTime.AddSeconds(5), 
                    CancellationToken.None).Wait();
            }
        }
        
        // Mark as failed
        await context.CallActivityAsync("MarkFailed", 
            new { request.Id, reason = ex.Message });
    }
}

// Compensation Activities
[FunctionName("UndoEligibility")]
public async Task UndoEligibility([ActivityTrigger] ReviewRequest request)
{
    // Reverse the eligibility check
    await _eligibilityService.RevertEligibilityCheck(request.PatientId);
    _logger.LogInformation($"Reverted eligibility for {request.PatientId}");
}

[FunctionName("UnassignClinician")]
public async Task UnassignClinician([ActivityTrigger] dynamic data)
{
    var reviewId = data.reviewId;
    var clinicianId = data.clinicianId;
    
    // Remove assignment
    await _assignmentService.UnassignClinician(reviewId);
    _logger.LogInformation($"Unassigned clinician {clinicianId} from {reviewId}");
}

[FunctionName("DeleteReview")]
public async Task DeleteReview([ActivityTrigger] string reviewId)
{
    // Delete the partially created review
    await _reviewService.DeleteReview(reviewId);
    _logger.LogInformation($"Deleted review {reviewId}");
}
```

Failure Scenario 2: Failure at Step 5 (Insurance API timeout)

Forward Actions Completed:
✔ Step 1: VerifyEligibility
✔ Step 2: AssignClinician
✔ Step 3: CreateReview
✔ Step 4: NotifyClinician

Backward Actions (Compensations) executed in REVERSE order:
1. CancelNotification(clinician)
   ├─ Send cancellation email: "Review assignment cancelled"
   └─ Remove from clinician's pending list
2. DeleteReview(reviewId)
   ├─ Delete review record
   └─ Data consistency: No orphaned reviews
3. UnassignClinician(reviewId)
   ├─ Free up clinician's slot
   └─ Assignment service: Clinician available again
4. UndoEligibility(patientId)
   ├─ Revert eligibility cache
   └─ Patient service: Status reverted

Idempotency (Important for Retries):

What if compensation is called twice?

Example: UndoEligibility called twice (first call succeeds, second retry)
- Second call finds status already reverted
- Should be idempotent: No error, just return success
- Implementation: Check status before reverting

```csharp
[FunctionName("UndoEligibility")]
public async Task UndoEligibility([ActivityTrigger] ReviewRequest request)
{
    // Check current status
    var status = await _eligibilityService.GetStatus(request.PatientId);
    
    if (status == "VERIFIED")
    {
        // Not yet compensated, do it now
        await _eligibilityService.Revert(request.PatientId);
    }
    else if (status == "PENDING_MANUAL")
    {
        // Already compensated, idempotent return
        _logger.LogInformation("Already reverted, skipping");
    }
}
```

Monitoring Compensation Flow:

Track all orchestrations:
┌─ ID: orch-12345
├─ Status: FAILED (compensation in progress)
├─ Failed Step: AssignClinician (step 2 of 5)
├─ Compensation Progress:
│  ├─ ✓ CancelNotification (step 4 compensation)
│  ├─ ✓ DeleteReview (step 3 compensation)
│  ├─ ⏳ UnassignClinician (step 2 compensation, in progress)
│  └─ ⏳ UndoEligibility (step 1 compensation, pending)
├─ Retry Policy: Retry entire flow at 14:00 UTC
└─ Manual Action: Supervisor reviewing for manual intervention
```

---

### **6. Idempotent Consumer Pattern (3 Questions)**

**Q6a: Design a Kafka consumer that processes clinical events. How would you guarantee exactly-once processing even with duplicate message delivery?**

**Sample Answer:**
```
Problem: Kafka delivery guarantees
- At-most-once: Message delivered 0 or 1 times (loss possible)
- At-least-once: Message delivered 1+ times (duplicates possible)
- Exactly-once: Message delivered exactly once (ideal, hard to achieve)

For healthcare: We need exactly-once (duplicate review = duplicate billing, bad)

Architecture: At-Least-Once + Idempotent Processing

Kafka Consumer Configuration:
```
enable.auto.commit = false  (don't auto-commit offset)
auto.offset.reset = earliest (if consumer crashes, reprocess from start)
isolation.level = read_committed (only read committed messages)
```

Processing Flow:

1. Consume message from Kafka
   Message: { id: "123", type: "ReviewDecided", decision: "APPROVED" }

2. Check deduplication store FIRST
   Query: SELECT result FROM DeduplicationStore WHERE messageId = "123"
   
   If exists:
   ├─ Return cached result (idempotent)
   └─ Commit offset (message already processed)
   
   If not exists:
   └─ Continue to step 3

3. Begin transaction
   BEGIN TRANSACTION

4. Process message (business logic)
   - Update Review.Status = "APPROVED"
   - Update DecisionLog with timestamp
   - Send to Insurance notification queue

5. Store result in deduplication store (same transaction)
   INSERT INTO DeduplicationStore (messageId, result, timestamp)
   VALUES ("123", { status: "APPROVED", ... }, NOW)
   
   Key point: INSERT within same transaction as business logic
   - If fails: Neither business change nor dedup entry is committed
   - If succeeds: Both are committed atomically

6. Commit transaction
   COMMIT TRANSACTION
   
   If fails: Retry from step 3

7. Commit Kafka offset
   consumer.commitSync()  (synchronous commit)
   
   Only after business transaction succeeds!
   If Kafka commit fails: Offset not advanced
   → Consumer will reprocess same message on restart
   → Step 2 dedup check catches it

Deduplication Store Design:

Table: DeduplicationStore
```
┌────────────┬──────────────────┬────────────┬────────────────┐
│ messageId  │ aggregateId      │ result     │ timestamp      │
├────────────┼──────────────────┼────────────┼────────────────┤
│ msg-12345  │ REV-678          │ APPROVED   │ 2024-01-15...  │
│ msg-12346  │ REV-679          │ REJECTED   │ 2024-01-15...  │
│ msg-12347  │ REV-680          │ ESCALATED  │ 2024-01-15...  │
└────────────┴──────────────────┴────────────┴────────────────┘

Indexes:
- Primary: (messageId)  // Fast lookup
- Secondary: (timestamp) // TTL cleanup

TTL: 30 days
- After 30 days, delete dedup entry
- Old messages won't be redelivered anyway
- Saves storage, keeps table small
```

Code Implementation (C# + Kafka Consumer):
```csharp
public class ReviewDecisionConsumer
{
    private readonly IDeduplicationStore _dedup;
    private readonly IReviewService _reviewService;
    private readonly IKafkaConsumer _consumer;
    
    public async Task ProcessReviewDecisions(CancellationToken ct)
    {
        _consumer.Subscribe("review.decisions");
        
        while (!ct.IsCancellationRequested)
        {
            // Step 1: Consume message
            var message = _consumer.Poll(timeout: TimeSpan.FromSeconds(1));
            if (message == null) continue;
            
            var decodedMessage = JsonConvert.DeserializeObject<ReviewDecisionEvent>(
                Encoding.UTF8.GetString(message.Value));
            
            // Step 2: Check deduplication store
            var existing = await _dedup.GetAsync(message.Key);
            if (existing != null)
            {
                _logger.LogInformation(
                    $"Message {message.Key} already processed, skipping");
                
                // Commit offset (message handled)
                _consumer.CommitSync(new[] { message.TopicPartitionOffset });
                continue;
            }
            
            // Step 3-6: Process within transaction
            using (var transaction = _dbContext.Database.BeginTransaction())
            {
                try
                {
                    // Step 4: Business logic
                    var review = await _reviewService.GetAsync(decodedMessage.ReviewId);
                    review.Status = decodedMessage.Decision;
                    review.DecidedAt = decodedMessage.Timestamp;
                    
                    await _reviewService.SaveAsync(review);
                    
                    // Step 5: Store dedup entry (SAME TRANSACTION)
                    await _dedup.StoreAsync(new DeduplicationEntry
                    {
                        MessageId = message.Key,
                        AggregateId = decodedMessage.ReviewId,
                        Result = decodedMessage.Decision,
                        Timestamp = DateTime.UtcNow,
                        Ttl = TimeSpan.FromDays(30)
                    });
                    
                    // Step 6: Commit
                    transaction.Commit();
                    
                    _logger.LogInformation($"Processed message {message.Key}");
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Error processing {message.Key}: {ex}");
                    transaction.Rollback();
                    throw;
                }
            }
            
            // Step 7: Commit Kafka offset (only after success)
            try
            {
                _consumer.CommitSync(new[] { message.TopicPartitionOffset });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Failed to commit offset: {ex}");
                // Don't throw, let it retry on next poll
            }
        }
    }
}
```

Failure Scenarios:

Scenario A: Crash between step 6 and 7
- Business transaction: COMMITTED (decision saved)
- Kafka offset: NOT committed
- On restart: Consumer reprocesses same message
- Dedup store: Finds existing entry
- Result: Idempotent, no duplicate

Scenario B: Crash during step 5
- Business transaction: ROLLED BACK (no decision, no dedup entry)
- Kafka offset: NOT committed
- On restart: Consumer retries same message
- Dedup store: No entry
- Result: Processes again (correct)

Scenario C: Network hiccup, Kafka delivers duplicate
- Message 1: Processed, dedup entry stored, offset committed
- Network issue causes message 1 to be redelivered
- Message 1 (duplicate): Dedup store finds it
- Result: Skipped (idempotent)

Performance Optimizations:

1. Batch Deduplication Checks:
   - Group 100 messages
   - Check all in single query: WHERE messageId IN (...)
   - Faster than individual lookups

2. In-Memory Dedup Cache:
   - Keep last 10k messageIds in Redis
   - Check Redis first (fast), then DB
   - TTL 1 minute (matches Kafka segment retention)

3. Parallel Processing (with caution):
   - Only works if aggregateIds are independent
   - If two messages for same reviewId, must serialize
   - Use per-partition threads (Kafka partition → thread)

Monitoring:

☐ Dedup hit rate: How many duplicates detected?
☐ Dedup miss rate: First time seeing message
☐ Latency: p99 < 100ms for dedup check + processing
☐ Reprocess rate: How often does restart cause reprocessing?
☐ Dedup store size: Keep < 1GB (or adjust TTL)
```

---

**Q6b: Your deduplication store goes down for 2 hours. How would you handle processing during the outage without losing idempotency guarantees?**

**Sample Answer:**
```
Dedup Store Outage Scenario:

11:00 AM: Cosmos DB (dedup store) goes down
11:00 AM - 1:00 PM: Messages continue flowing from Kafka (buffered)
1:00 PM: Cosmos DB recovers

Challenge:
- Can't check dedup store for 2 hours
- Can't guarantee "not processed before"
- Risk: Duplicate processing

Solution 1: Fail Closed (Stop processing)

When dedup store unavailable:
- Pause Kafka consumer (don't process)
- Alert: "Dedup store unavailable, processing paused"
- Wait for store recovery
- Resume processing

Pros:
✔ Conservative, no risk of duplicates
✔ Simple, easy to reason about

Cons:
✗ Service unavailable for 2 hours
✗ Kafka messages pile up
✗ Catch-up processing slow after recovery
✗ SLA breach (unacceptable for healthcare)

Code:
```csharp
try
{
    var isDedupAvailable = await _dedup.CheckHealth();
    
    if (!isDedupAvailable)
    {
        throw new DependencyUnavailableException(
            "Dedup store is unavailable");
    }
    
    // Process normally
}
catch (DependencyUnavailableException)
{
    _consumer.Pause();  // Stop consuming
    _alerting.SendAlert("Dedup store down, consumer paused");
    
    // Wait for recovery (background job)
    await WaitForDependency("dedup-store");
    _consumer.Resume();
}
```

Solution 2: Fail Open (Allow duplicates, detect later)

When dedup store unavailable:
- Continue processing (optimistic)
- Skip dedup check
- BUT: Write to write-ahead log (WAL)
- Later: Detect and reconcile duplicates

Dedup Check Flow (modified):
```
1. Try to read dedup store
2. If timeout/error:
   ├─ Log to WAL (local file)
   └─ Assume "not seen before" (risky assumption)
3. Process message
4. Try to write dedup entry
5. If timeout/error:
   ├─ Add to local retry queue
   └─ Assume written (optimistic)
6. Commit Kafka offset
```

Risk: What if message was actually processed?
- WAL contains: [msg-123, msg-124, msg-125] (processed during outage)
- No dedup entry (store was down)
- On restart: Consumer reprocesses all 3
- Result: Duplicate decisions, need reconciliation

Reconciliation Process (After Recovery):
```
1. Query Kafka: Last 1000 messages while store was down
   SELECT * FROM messages WHERE timestamp BETWEEN 11:00 AND 13:00

2. Query Database: What was actually processed?
   SELECT * FROM Review WHERE ProcessedAt BETWEEN 11:00 AND 13:00

3. Find duplicates: Kafka message NOT in dedup store but IS in Review
   duplicates = kafka_messages - dedup_entries - reviews

4. Remediate:
   For each duplicate review:
   ├─ If decision same: OK, ignore
   ├─ If decision different: ERROR, escalate to human
   └─ Delete duplicate dedup entries
```

Code for Dedup Check with Fallback:
```csharp
public async Task<bool> IsProcessed(string messageId)
{
    try
    {
        var result = await _dedup.GetAsync(messageId, 
            timeout: TimeSpan.FromSeconds(2));
        return result != null;
    }
    catch (TimeoutException)
    {
        _logger.LogWarning($"Dedup store timeout for {messageId}");
        
        // Dedup store unavailable
        // Write to WAL for later reconciliation
        await _writeAheadLog.AppendAsync(
            new WalEntry 
            { 
                MessageId = messageId,
                Timestamp = DateTime.UtcNow,
                Action = "DEDUP_CHECK_FAILED"
            });
        
        // Fail open: Assume not seen (process it)
        return false;
    }
    catch (Exception ex)
    {
        _logger.LogError($"Dedup store error: {ex}");
        
        // Exponential backoff retry
        await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, _retryCount++)));
        
        if (_retryCount > 5)
        {
            throw;  // Give up, pause consumer
        }
        
        return await IsProcessed(messageId);  // Retry
    }
}
```

Solution 3: Hybrid (Fail Open + Background Remediation)

Best for healthcare (recovery from outage, detect/fix duplicates later):

During Outage:
- Process messages (fail open)
- Write to WAL for each message
- Mark as "UNVERIFIED" in database

After Recovery:
- Background job runs reconciliation
- Compares WAL + database + dedup store
- Finds conflicts (if duplicate processing occurred)
- Alerts for human review (clinician reviews policy)

Implementation:
```csharp
// During outage
public async Task ProcessWithFallback(KafkaMessage message)
{
    bool dedupAvailable = false;
    bool isProcessed = false;
    
    try
    {
        isProcessed = await IsProcessed(message.Key, timeout: 2 seconds);
        dedupAvailable = true;
    }
    catch
    {
        // Dedup store unavailable, assume not processed
        isProcessed = false;
        dedupAvailable = false;
        
        // Log to WAL
        await _wal.Write(new
        {
            messageId = message.Key,
            action = "FALLBACK_PROCESS",
            reason = "DEDUP_UNAVAILABLE"
        });
    }
    
    if (!isProcessed)
    {
        // Process message
        var decision = await ProcessReviewDecision(message);
        
        // Mark as unverified if dedup unavailable
        await _db.SaveAsync(new Review
        {
            ...decision...
            IsDeduplicationVerified = dedupAvailable  // False if risky
        });
    }
}

// After recovery - background reconciliation job
[FunctionName("ReconciliateDuplicates")]
public async Task Reconciliate([TimerTrigger("0 */5 * * * *")] TimerInfo timer)
{
    // Every 5 minutes, check for potential duplicates
    
    // Step 1: Find all reviews marked as unverified
    var unverifiedReviews = await _db.GetAsync(
        r => r.IsDeduplicationVerified == false);
    
    // Step 2: For each, verify it's truly unduplicates
    foreach (var review in unverifiedReviews)
    {
        // Check if message now in dedup store
        var inDedup = await _dedup.GetAsync(review.MessageId);
        
        if (inDedup != null)
        {
            // Good, dedup entry exists
            review.IsDeduplicationVerified = true;
            await _db.SaveAsync(review);
        }
        else
        {
            // Problem: Review exists but no dedup entry
            // This means it was processed while store was down
            
            _alerting.SendAlert(new
            {
                type = "DUPLICATE_DETECTION",
                reviewId = review.Id,
                messageId = review.MessageId,
                action = "MANUAL_REVIEW_REQUIRED"
            });
        }
    }
}
```

Decision Tree:

Is dedup store availability critical?
├─ YES (healthcare): Use fail-closed + alert + manual handling
├─ MAYBE (e-commerce): Use fail-open + reconciliation
└─ NO (social media): Use fail-open + eventual fix

For Healthcare + Idempotency:
✔ Prefer fail-closed during short outages (< 1 hour)
✔ Switch to fail-open + reconciliation for longer outages
✔ Always have manual override for critical reviews
✔ Alert humans immediately when duplicates detected
```

---

**Q6c: A message is partially processed (failure after step 4 business logic, before step 5 dedup store write). How does recovery work?**

**Sample Answer:**
```
Scenario:

Processing ReviewDecisionEvent (msg-999):
Step 1 ✓ Dedup check: Not seen before
Step 2 ✓ Read message: ReviewId=REV-123, Decision=APPROVED
Step 3 ✓ Begin transaction
Step 4 ✓ Business logic: Review.Status = APPROVED (saved to database)
Step 5 ✗ CRASH: Before writing to dedup store
Step 6 ✗ Never reached: Commit transaction

Database State After Crash:
- Review table: REV-123.Status = APPROVED ✓ (persisted)
- Dedup store: No entry for msg-999 (never written)
- Kafka: msg-999 offset not committed

On Restart:

Consumer resumes from last committed offset (before msg-999)
Sees message msg-999 again

Processing msg-999 (Attempt 2):
Step 1: Dedup check
   Query: SELECT * FROM DeduplicationStore WHERE messageId = 'msg-999'
   Result: NOT FOUND (because crash happened before writing)

Step 2-4: Business logic
   Try to execute: Review.Status = APPROVED
   
   But REV-123.Status is ALREADY approved from Attempt 1!
   
   This is idempotent operation:
   - Setting Status = APPROVED when already APPROVED
   - No side effects (timestamp already set)
   - Safe to execute twice

Step 5: Write dedup entry
   INSERT INTO DeduplicationStore (messageId, aggregateId, result, ...)
   VALUES ('msg-999', 'REV-123', 'APPROVED', ...)
   → SUCCESS (this time!)

Step 6: Commit
   COMMIT TRANSACTION → SUCCESS

Step 7: Commit Kafka offset
   consumer.CommitSync() → SUCCESS

Result: Message processed exactly once, even with crash

Key Point: Idempotency is guaranteed by idempotent business logic

Review.Status = APPROVED (idempotent):
- Execute once: Status changes to APPROVED ✓
- Execute twice: Status is already APPROVED, no change ✓
- Execute 100x: Status is APPROVED, always same ✓

Non-Idempotent Example (Counter-example):

Review.DecisionCount += 1  (NOT idempotent):
- Execute once: DecisionCount = 1 ✗
- Execute twice: DecisionCount = 2 ✗ (WRONG! Should be 1)

If crash before dedup write:
Restart → Reprocess → DecisionCount increments again → DUPLICATE

How to make it idempotent:
- Instead of += 1
- Use: DecisionCount = 1 (set, don't increment)
- Or: Use timestamp as key (if already decided at this time, skip)

Handling Non-Idempotent Operations:

If business logic NOT idempotent, must store result BEFORE executing:

Revised Flow:

Step 3: Begin transaction
Step 4a: Pre-store dedup entry (BEFORE business logic!)
  INSERT INTO DeduplicationStore (messageId, status)
  VALUES ('msg-999', 'PENDING')

Step 4b: Execute business logic
  Review.DecisionCount += 1

Step 4c: Update dedup status
  UPDATE DeduplicationStore 
  SET status = 'COMPLETED', result = APPROVED
  WHERE messageId = 'msg-999'

Step 5: Commit transaction

Now if crash happens at any point:
- Dedup entry exists with status = PENDING or COMPLETED
- On restart: Dedup check finds entry
- Dedup status = COMPLETED? Return cached result
- Dedup status = PENDING? Something went wrong, retry

Code Comparison:

Idempotent Approach (Simpler):
```csharp
using (var tx = db.BeginTransaction())
{
    // No pre-dedup write needed
    var review = await db.Reviews.Get(reviewId);
    review.Status = decision;  // Idempotent!
    
    await db.SaveAsync(review);
    
    // Now safe to write dedup
    await dedup.Store(messageId, decision);
    
    tx.Commit();
}
```

Non-Idempotent Approach (More careful):
```csharp
using (var tx = db.BeginTransaction())
{
    // PRE-dedup: Mark as in-progress
    await dedup.Store(new
    {
        messageId,
        status = "IN_PROGRESS",
        timestamp = now
    });
    
    // Business logic (non-idempotent)
    var review = await db.Reviews.Get(reviewId);
    review.DecisionCount += 1;
    
    // POST-dedup: Mark as completed with result
    await dedup.Update(messageId, new
    {
        status = "COMPLETED",
        result = decision,
        timestamp = now
    });
    
    tx.Commit();
}

// On restart, dedup check returns completed status
// Even if consumer re-fetches, dedup prevents reprocessing
```

Monitoring Partial Failures:

Track:
┌─ Total messages consumed: 1,000,000
├─ Fully processed: 999,998
├─ Partially processed (no dedup): 2
│  └─ Recovered on restart: 2 ✓
├─ Failed during dedup write: 0 (caught by monitoring)
└─ Failed during business logic: 0 (rolled back)

Alerts:
- If crash during dedup write: Low severity (recovered automatically)
- If crash during business logic: Medium severity (rollback, retry)
- If repeated crashes on same message: High severity (possible poison message)

Test Case:
Inject failure at step 4 (business logic), verify:
1. Message reprocessed on restart ✓
2. Dedup prevents duplicate ✓
3. Final state correct (exactly-once semantics) ✓
```

---

### **7. Polly Retry & Circuit Breaker (3 Questions)**

**Q7a: An external EHR API is flaky (50% success rate). Design a resilience strategy using Polly to protect your system. What policies would you combine?**

**Sample Answer:**
```
EHR API Characteristics:
- Flaky: 50% success rate (normal network issue)
- Timeout: Takes 2-10 seconds
- Failure types: 5xx errors, connection timeouts, 429 rate limits
- Impact: Patient eligibility check blocks clinician workflow

Resilience Strategy: Layered Policies (Onion Model)

Layer 1: Timeout Policy (fail fast)
- Max wait: 5 seconds
- If exceeds: Cancel request, throw TimeoutException
- Prevents hanging forever

Layer 2: Retry Policy (exponential backoff)
- Max attempts: 3
- Backoff: 100ms → 200ms → 400ms (exponential)
- Handle: 5xx errors, timeouts
- Skip: 4xx errors (user's fault, don't retry)

Layer 3: Circuit Breaker (prevent cascading failure)
- Opens after: 5 failures in 60 seconds
- Duration: 30 seconds (give API time to recover)
- States: Closed → Open → Half-Open → Closed

Layer 4: Fallback Policy (graceful degradation)
- If circuit open: Return cached data
- Cache: Patient eligibility from 24 hours ago
- Display: "Data may be stale, last updated 12:30 PM"

Polly Implementation (C#):
```csharp
public class EhrClientService
{
    private readonly HttpClient _httpClient;
    private readonly IAsyncPolicy<HttpResponseMessage> _ehrPolicy;
    private readonly IDistributedCache _cache;
    
    public EhrClientService(HttpClient httpClient, IDistributedCache cache)
    {
        _httpClient = httpClient;
        _cache = cache;
        
        // Build policies
        var timeoutPolicy = Policy.TimeoutAsync<HttpResponseMessage>(
            timeout: TimeSpan.FromSeconds(5),
            timeoutStrategy: TimeoutStrategy.Optimistic);
        
        var retryPolicy = Policy
            .HandleResult<HttpResponseMessage>(r => !r.IsSuccessStatusCode)
            .Or<HttpRequestException>()
            .Or<TaskCanceledException>()  // Timeout
            .WaitAndRetryAsync(
                retryCount: 3,
                sleepDurationProvider: attempt =>
                    TimeSpan.FromMilliseconds(Math.Pow(2, attempt) * 100),
                onRetry: (outcome, duration, retry, context) =>
                {
                    _logger.LogWarning(
                        $"Retry {retry}/3 after {duration.TotalMilliseconds}ms");
                });
        
        var circuitBreakerPolicy = Policy
            .HandleResult<HttpResponseMessage>(r => !r.IsSuccessStatusCode)
            .Or<HttpRequestException>()
            .CircuitBreakerAsync<HttpResponseMessage>(
                handledEventsAllowedBeforeBreaking: 5,
                durationOfBreak: TimeSpan.FromSeconds(30),
                onBreak: (outcome, duration) =>
                {
                    _logger.LogError($"Circuit breaker opened for {duration.TotalSeconds}s");
                    _alerting.SendAlert("EHR API circuit open");
                },
                onReset: () =>
                {
                    _logger.LogInformation("Circuit breaker reset");
                });
        
        var fallbackPolicy = Policy
            .HandleResult<HttpResponseMessage>(r => !r.IsSuccessStatusCode)
            .Or<BrokenCircuitException>()
            .FallbackAsync(
                fallbackAction: async (context) =>
                {
                    _logger.LogWarning("Using fallback: cached eligibility");
                    return new HttpResponseMessage(System.Net.HttpStatusCode.OK)
                    {
                        Content = new StringContent(
                            await GetCachedEligibility(context["patientId"].ToString()))
                    };
                });
        
        // Combine policies: Fallback wraps CircuitBreaker wraps Retry wraps Timeout
        _ehrPolicy = Policy.WrapAsync<HttpResponseMessage>(
            fallbackPolicy,
            circuitBreakerPolicy,
            retryPolicy,
            timeoutPolicy);
    }
    
    public async Task<EligibilityResponse> CheckEligibility(
        string patientId, string insurerId)
    {
        var context = new Polly.Context
        {
            ["patientId"] = patientId,
            ["insurerId"] = insurerId
        };
        
        try
        {
            var request = new HttpRequestMessage(HttpMethod.Get, 
                $"/api/eligibility?patientId={patientId}&insurerId={insurerId}");
            
            var response = await _ehrPolicy.ExecuteAsync(
                async (ctx) =>
                {
                    return await _httpClient.SendAsync(request);
                },
                context);
            
            var json = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<EligibilityResponse>(json);
        }
        catch (BrokenCircuitException)
        {
            _logger.LogError("EHR API unavailable (circuit open), using cache");
            return await GetCachedEligibilityAsObject(patientId);
        }
        catch (Exception ex)
        {
            _logger.LogError($"Failed to check eligibility: {ex}");
            return new EligibilityResponse { IsEligible = null };  // Unknown
        }
    }
}
```

Policy Interaction Example:

Request 1: Succeeds
   Timeout → Retry → CircuitBreaker → Fallback
   ✓ Response within 2 seconds
   Status: Closed

Request 2: Fails (5xx error)
   Timeout → Retry 1 (wait 100ms, fails)
   → Retry 2 (wait 200ms, fails)
   → Retry 3 (wait 400ms, fails)
   → CircuitBreaker (1st failure)
   Status: Closed (1/5 failures)

Requests 3-6: All fail (network issue)
   Each goes through retries, all fail
   CircuitBreaker counts: 2/5 → 3/5 → 4/5 → 5/5
   
Request 7: Circuit opens
   Timeout → Retry skipped (CB decision)
   → CircuitBreaker OPENS (rejects request)
   → Fallback executes (returns cached data)
   Status: Open (circuit open for 30 seconds)

Requests 8-10 (during open): Rejected immediately
   Circuit open → Fallback returns cache
   Response time: < 10ms (no actual HTTP call)

Request 11 (30s later): Half-open state
   Circuit tries 1 probe request
   If succeeds: Circuit closes (back to normal)
   If fails: Circuit stays open 30 more seconds

Metrics to Track:

CircuitBreakerStatistics:
- Opens: How many times circuit opened? (target: < 1/day)
- Duration: How long stayed open? (target: < 5 min total)
- Prevents: How many requests rejected by circuit? (target: < 100)

RetryStatistics:
- Attempts: How many retries? (target: < 1% of requests)
- Backoff cumulative: Total time spent retrying? (target: < 500ms total)

FallbackStatistics:
- Invoked: How many times used cached data? (target: < 0.1%)
- Cache hit rate: Was cache available? (target: > 95%)

Monitoring Dashboard:
Service    | Health | Success% | P99 latency | Circuit State
───────────────────────────────────────────────────────────────
EHR        | 🟢     | 99.5%    | 450ms       | Closed
Auth       | 🟢     | 99.8%    | 200ms       | Closed
Insurance  | 🟡     | 94%      | 800ms       | Half-Open (recovering)
Pharmacy   | 🔴     | 40%      | N/A         | Open (30s remaining)
───────────────────────────────────────────────────────────────

Alerting Rules:
- Circuit opens: Notify engineer (manual investigation)
- Circuit open > 5 minutes: Page on-call
- Success rate < 90%: Alert (degraded)
- Success rate < 70%: Page (critical)
```

---

**Q7b: Your system is experiencing thundering herd (all clients retry simultaneously after outage). How would you prevent this?**

**Sample Answer:**
```
Thundering Herd Problem:

Scenario:
- EHR API goes down for 10 seconds
- All 500 clinicians try to check eligibility
- Each waits 5 seconds, then retries
- 10 seconds later: Outage ends
- All 500 retries hit API simultaneously
- 500 requests × 2 retries = 1000 requests in 1 second
- API can't handle it, stays down longer

Thundering Herd Solutions:

Solution 1: Jitter (Randomized Backoff)

Instead of:
```
Retry 1: 100ms (all clients wait same time)
Retry 2: 200ms (all clients retry simultaneously)
Retry 3: 400ms (all retry together again)
```

Use:
```
Retry 1: 100ms + random(0-50ms) = 105-150ms
Retry 2: 200ms + random(0-100ms) = 200-300ms
Retry 3: 400ms + random(0-200ms) = 400-600ms
```

Result: Retries spread across time, not simultaneous

Polly Implementation:
```csharp
var jitterProvider = new Random();
var retryPolicy = Policy
    .Handle<HttpRequestException>()
    .WaitAndRetryAsync(
        retryCount: 3,
        sleepDurationProvider: attempt =>
        {
            var exponentialBackoff = Math.Pow(2, attempt) * 100;
            var jitter = jitterProvider.Next(
                0, 
                (int)(exponentialBackoff * 0.5));  // 50% jitter
            
            return TimeSpan.FromMilliseconds(exponentialBackoff + jitter);
        });
```

Solution 2: Bulkhead Isolation

Limit concurrent requests to prevent overwhelming API

```csharp
var bulkheadPolicy = Policy.BulkheadAsync<HttpResponseMessage>(
    maxParallelization: 50,  // Only 50 concurrent EHR calls
    maxQueuingActions: 100,  // Queue additional 100 requests
    onBulkheadRejectedAsync: (context) =>
    {
        _logger.LogWarning("Bulkhead rejected request, too many concurrent");
        return Task.CompletedTask;
    });

var combinedPolicy = Policy.WrapAsync(bulkheadPolicy, retryPolicy);
```

Example:
- 500 clinicians try simultaneously
- Bulkhead allows only 50 concurrent
- Rest wait in queue
- As requests complete, queued requests start
- Prevents spike, spreads load

Solution 3: Request Coalescing (Cache-Aside)

Multiple clinicians checking same patient simultaneously → Only hit API once

```csharp
public async Task<EligibilityResponse> CheckEligibility(
    string patientId, string insurerId)
{
    var cacheKey = $"eligibility:{patientId}:{insurerId}";
    
    // Check cache
    var cached = await _cache.GetAsync(cacheKey);
    if (cached != null)
        return JsonConvert.DeserializeObject<EligibilityResponse>(cached);
    
    // Not in cache, but check if request in-flight
    if (_inFlightRequests.ContainsKey(cacheKey))
    {
        // Another clinician is already fetching
        // Wait for their result instead of making new request
        var task = _inFlightRequests[cacheKey];
        return await task;
    }
    
    // No cached, no in-flight → Make request
    var task = FetchFromEhrAsync(patientId, insurerId);
    _inFlightRequests[cacheKey] = task;
    
    try
    {
        var result = await task;
        
        // Cache result
        await _cache.SetAsync(cacheKey, 
            Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(result)),
            options: new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1)
            });
        
        return result;
    }
    finally
    {
        _inFlightRequests.Remove(cacheKey);
    }
}

// Usage:
Request 1: CheckEligibility(patientId=PAT-123)
  → Not cached, not in-flight
  → Make HTTP call to EHR
  → Store in _inFlightRequests

Request 2 (100ms later): CheckEligibility(patientId=PAT-123)
  → Not cached, but IN-FLIGHT
  → Wait for Request 1's task
  → Both get same result, only 1 HTTP call

Result: 500 requests → 1 HTTP call!
```

Solution 4: Adaptive Throttling

Automatically reduce load when API struggling

```csharp
public class AdaptiveThrottlePolicy
{
    private int _allowedConcurrent = 100;
    private DateTime _lastErrorTime = DateTime.MinValue;
    
    public async Task<T> ExecuteAsync<T>(Func<Task<T>> action)
    {
        // Check current load
        if (_currentConcurrent >= _allowedConcurrent)
        {
            throw new ServiceUnavailableException(
                $"Throttled: {_currentConcurrent}/{_allowedConcurrent}");
        }
        
        try
        {
            Interlocked.Increment(ref _currentConcurrent);
            return await action();
        }
        catch (Exception ex)
        {
            _lastErrorTime = DateTime.UtcNow;
            
            // Reduce allowed concurrent on error
            if (ex is HttpRequestException)
            {
                _allowedConcurrent = Math.Max(10,  // Never go below 10
                    (int)(_allowedConcurrent * 0.8));  // 20% reduction
                
                _logger.LogWarning(
                    $"Reduced concurrent to {_allowedConcurrent} due to error");
            }
            
            throw;
        }
        finally
        {
            Interlocked.Decrement(ref _currentConcurrent);
            
            // Gradually increase allowed concurrent over time
            if ((DateTime.UtcNow - _lastErrorTime).TotalSeconds > 30)
            {
                _allowedConcurrent = Math.Min(200,  // Never exceed 200
                    (int)(_allowedConcurrent * 1.05));  // 5% increase
            }
        }
    }
}

// Usage:
// After outage: Start 100 concurrent
// See errors: Drop to 80
// See more errors: Drop to 64
// 30 seconds OK: Rise to 67
// Eventually back to 100 as system recovers
```

Best Practice: Combine All

1. Jitter: Spread retry timing
2. Bulkhead: Limit concurrent requests
3. Request coalescing: Cache in-flight requests
4. Adaptive throttling: Back off when struggling
5. Circuit breaker: Stop trying when clearly down

Total impact:
- Retry storms: Eliminated (jitter spreads retries)
- Thundering herd: Prevented (bulkhead + throttle)
- API load: Reduced 5-10x (coalescing)
- Recovery: Faster (adaptive increase when healthy)
```

---

**Q7c: Your retry policy causes cascading failures (each retry makes things worse). How would you detect and prevent this?**

**Sample Answer:**
```
Cascading Failure Scenario:

System: Authorization → Eligibility Service → EHR API

Request comes in:
1. Auth service calls Eligibility
2. Eligibility calls EHR (slow, 5 second timeout)
3. EHR is actually fine but slow (CPU spike)
4. Auth waits 5 seconds, retries
5. Retry hits EHR again (adds more load)
6. EHR now slower (more CPU load)
7. More timeouts, more retries
8. Death spiral: Retries → More load → More failures

Result: One slow service → Entire system fails

Detection:

Monitor these metrics:
- Timeout rate: Increasing over time? (anomaly)
- Retry count: > 10% of requests? (cascading)
- Queue depth: Requests piling up? (overload)
- Error correlation: Multiple services failing together? (cascading)

```python
# Anomaly detection pseudocode

timeout_rate = timeouts_last_minute / total_requests_last_minute

if timeout_rate > baseline_rate * 1.5:  # 50% above normal
    log "Cascading failure detected"
    alert "Auto-throttle enabled"
```

Prevention Strategy 1: Request Timeout < Downstream Timeout

Example:
```
Client call to Auth: 30 second timeout
Auth call to Eligibility: 25 second timeout  
Eligibility call to EHR: 20 second timeout

Result:
- If EHR responds in 18s: All good
- If EHR takes 25s: Eligibility times out, stops hammering
- Auth waits 25s, gets error, fails fast
- Client retry: New request with same timeouts
- Never cascades (each layer times out before retrying)
```

Polly Configuration:
```csharp
// Parent service (Auth)
var authToEligibility = Policy
    .TimeoutAsync(TimeSpan.FromSeconds(25))
    .WrapAsync(retryPolicy);

// Child service (Eligibility)
var eligibilityToEhr = Policy
    .TimeoutAsync(TimeSpan.FromSeconds(20))
    .WrapAsync(retryPolicy);
```

Prevention Strategy 2: Deadline Propagation

Pass deadline down the call chain

```csharp
public class CallContext
{
    public DateTime Deadline { get; set; }
    
    public TimeSpan RemainingTime => 
        Math.Max(TimeSpan.Zero, Deadline - DateTime.UtcNow);
}

// Auth service
var context = new CallContext 
{ 
    Deadline = DateTime.UtcNow.AddSeconds(30) 
};

// Call Eligibility with deadline
var timeout = context.RemainingTime.Subtract(TimeSpan.FromSeconds(2));
var result = await eligibilityClient.CheckAsync(
    patientId, 
    cancellationToken: GetTokenForDeadline(timeout));

// Eligibility service
public async Task<EligibilityResponse> CheckAsync(
    string patientId,
    CancellationToken cancellationToken)
{
    // Cancellation token includes deadline
    // If we get cancelled, pass error back (don't retry)
    
    try
    {
        return await ehrClient.CallAsync(patientId, cancellationToken);
    }
    catch (OperationCanceledException)
    {
        // Time's up, don't retry
        throw;
    }
}
```

Prevention Strategy 3: Adaptive Timeout (Shorter on Retries)

First attempt: Normal timeout
Retries: Shorter timeout (fail faster)

```csharp
var retryPolicy = Policy
    .Handle<HttpRequestException>()
    .Or<TimeoutException>()
    .WaitAndRetryAsync(
        retryCount: 3,
        sleepDurationProvider: attempt => 
            TimeSpan.FromMilliseconds(Math.Pow(2, attempt) * 100),
        onRetry: async (outcome, duration, attempt, context) =>
        {
            // Shorten timeout on retry
            context["timeout"] = attempt switch
            {
                1 => TimeSpan.FromSeconds(5),      // First attempt: 5s
                2 => TimeSpan.FromSeconds(3),      // Retry 1: 3s (40% less)
                3 => TimeSpan.FromSeconds(1),      // Retry 2: 1s (67% less)
                _ => TimeSpan.FromSeconds(0.5)     // Retry 3: 0.5s
            };
        });

// Use context-based timeout
var timeout = (TimeSpan)context["timeout"];
using (var cts = new CancellationTokenSource(timeout))
{
    return await httpClient.GetAsync(url, cts.Token);
}
```

Prevention Strategy 4: Slow Start (Gradual Load Increase)

Don't hammer a recovering service

```csharp
public class SlowStartPolicy
{
    private DateTime _recoveryStartTime = DateTime.MinValue;
    private int _allowedRequests = 10;  // Start low
    private int _currentRequests = 0;
    
    public async Task<T> ExecuteAsync<T>(Func<Task<T>> action)
    {
        // Check if still recovering
        var timeSinceRecovery = DateTime.UtcNow - _recoveryStartTime;
        
        if (timeSinceRecovery.TotalSeconds < 300)  // 5 minute recovery period
        {
            // Gradual ramp up
            if (timeSinceRecovery.TotalSeconds < 60)
                _allowedRequests = 10;
            else if (timeSinceRecovery.TotalSeconds < 120)
                _allowedRequests = 30;
            else if (timeSinceRecovery.TotalSeconds < 180)
                _allowedRequests = 100;
            else if (timeSinceRecovery.TotalSeconds < 300)
                _allowedRequests = 200;
        }
        else
        {
            _allowedRequests = 500;  // Fully recovered
        }
        
        // Check current load
        if (_currentRequests >= _allowedRequests)
        {
            throw new ServiceUnavailableException(
                $"Service recovering: {_currentRequests}/{_allowedRequests}");
        }
        
        Interlocked.Increment(ref _currentRequests);
        
        try
        {
            return await action();
        }
        finally
        {
            Interlocked.Decrement(ref _currentRequests);
        }
    }
    
    public void SignalRecoveryStart()
    {
        _recoveryStartTime = DateTime.UtcNow;
        _allowedRequests = 10;
    }
}

// Usage:
// Circuit breaker opens → Call slowStart.SignalRecoveryStart()
// Over 5 minutes:
//   0-1 min: 10 concurrent
//   1-2 min: 30 concurrent
//   2-3 min: 100 concurrent
//   3-5 min: 200 concurrent
//   > 5 min: 500 concurrent (normal)
```

Monitoring & Alerting for Cascading Failures:

Metrics to track:
```
timeout_rate = timeouts / total_requests
retry_rate = retries / total_requests
error_rate = errors / total_requests

Alert if:
- timeout_rate > 5% (cascading likely)
- retry_rate > 20% (too many retries)
- error_rate > 10% (system degraded)
- error_rate_variance > 50% (correlated failures)

Dashboard:
Service         | Health | Timeout% | Retry% | Cascading?
─────────────────────────────────────────────────────────────
Auth            | 🟢     | 0.1%     | 0.5%   | No
Eligibility     | 🟡     | 3.2%     | 15%    | Monitoring
EHR             | 🔴     | 8.5%     | 35%    | YES - Alert!
Insurance       | 🟡     | 4.1%     | 18%    | At risk
─────────────────────────────────────────────────────────────

If cascading detected:
1. Auto-reduce retry count (from 3 to 1)
2. Reduce timeout (fail faster)
3. Enable slow start (ramp up gradually)
4. Alert on-call engineer
5. Log detailed trace for postmortem
```

Test Case:
Inject slow EHR (5s latency for all requests), verify:
1. No cascading failures ✓
2. Error rate stays < 10% ✓
3. Slow start triggers ✓
4. System recovers in < 5 minutes ✓
```

---

### **8. Cosmos DB Design & Partitioning (3 Questions)**

**Q8a: Design a Cosmos DB container for an event store handling 10k events/second. How would you partition, optimize throughput, and handle hot partitions?**

**Sample Answer:**
```
Event Store Requirements:
- 10,000 events/second (peak)
- 1 year retention (400M+ events)
- Query patterns: By aggregateId (most common), by timestamp, by patient

Partition Key Decision:

Option A: Partition by PatientID
```
{
  "id": "evt-123456",
  "partitionKey": "PAT-789",  // Patient ID
  "eventType": "ReviewDecided",
  "aggregateId": "REV-123",
  "timestamp": "2024-01-15T10:00:00Z",
  "data": {...}
}
```

Pros:
- Natural fit for healthcare (patient privacy)
- Query patient history = single partition
- GDPR compliance (data segregation)

Cons:
- Hot patients (active cases) concentrated
- Uneven load (celebrity patient = hot partition)
- Solution: Synthetic sharding

Option B: Partition by AggregateID (ReviewID)
```
"partitionKey": "REV-123"
```

Pros:
- Even distribution (each review separate)
- Good for "get all events for review" queries

Cons:
- Cross-partition query for "all events by patient"
- More expensive (reads from multiple partitions)
- Doesn't help GDPR (data spread across)

Option C: Partition by Composite (Time-based)
```
"partitionKey": "2024-01-15/REV-123"
```

Pros:
- Partitions fill and close (time-based)
- Good for archival (old partitions → cheap storage)
- Load balanced (new events go to new partition)

Cons:
- Complex queries (need multiple partitions per query)
- Harder to query by patient

Decision: Partition by PatientID + Synthetic Sharding

Partition Key: "PAT-789-shard-{0..9}"

Hot Patient Mitigation:
```
Patient PAT-123: Extremely active (1000 events/second)
├─ Without sharding: 1 partition gets 1000 RU/s
├─ With sharding:
│  ├─ PAT-123-shard-0: 100 RU/s
│  ├─ PAT-123-shard-1: 100 RU/s
│  ├─ PAT-123-shard-2: 100 RU/s
│  ├─ ... (10 shards)
│  └─ Total: 1000 RU/s distributed evenly
```

Cosmos DB Provisioning:

Throughput Calculation:
```
10,000 events/second × 1.5 KB/event = 15 MB/s

RU consumption:
- Write: 1 KB ≈ 6 RU
- 1.5 KB = ~9 RU per write
- 10,000 writes = 90,000 RU/second

Provisioning: 100,000 RU/s (10% headroom)

Cost:
- Provisioned: 100,000 RU/s × 0.012 $/RU/hour = $1,440/month (expensive)
- Serverless: $0.25 per million RUs (cheaper for bursty)
- Decision: Use serverless (bursty event load)
```

Container Configuration:
```csharp
// Create container with synthetic partition key
var container = await database.CreateContainerAsync(
    id: "events",
    partitionKeyPath: "/patientIdWithShard",
    throughputProperties: ThroughputProperties.CreateAutoscaleThroughput(100000));

// Create indexes
var indexingPolicy = new IndexingPolicy
{
    IndexingMode = IndexingMode.Consistent,
    Included = new IncludedPath[]
    {
        new IncludedPath { Path = "/patientIdWithShard" },
        new IncludedPath { Path = "/aggregateId" },
        new IncludedPath { Path = "/timestamp" },
        new IncludedPath { Path = "/eventType" }
    },
    Excluded = new ExcludedPath[]
    {
        new ExcludedPath { Path = "/data/*" }  // Raw data, not indexed
    }
};

container.Descriptor.IndexingPolicy = indexingPolicy;
```

Rehydration (Rebuild Aggregate from Events):
```csharp
public async Task<Review> RehydrateAsync(string reviewId)
{
    var query = @"
        SELECT * FROM c 
        WHERE c.aggregateId = @reviewId 
        ORDER BY c.timestamp ASC";
    
    var iterator = container.GetItemQueryIterator<ReviewEvent>(
        query: query,
        requestOptions: new QueryRequestOptions 
        { 
            MaxItemCount = -1,  // No pagination (all events)
            PartitionKey = new PartitionKey(synthticKey)
        },
        parameters: new[] { new SqlParameter("@reviewId", reviewId) });
    
    var review = new Review { Id = reviewId };
    
    while (iterator.HasMoreResults)
    {
        foreach (var @event in await iterator.ReadNextAsync())
        {
            // Apply event to aggregate
            switch (@event.EventType)
            {
                case "ReviewCreated":
                    review.CreatedAt = @event.Timestamp;
                    break;
                case "ReviewerAssigned":
                    review.AssignedTo = @event.Data["clinicianId"];
                    break;
                case "ReviewCommented":
                    review.Comments.Add(@event.Data["comment"]);
                    break;
                case "ReviewDecided":
                    review.Status = @event.Data["decision"];
                    review.DecidedAt = @event.Timestamp;
                    break;
            }
        }
    }
    
    return review;
}
```

Optimization: Snapshots (Reduce Replay Cost)
```
After 10 events, create snapshot:
{
  "id": "snap-REV-123-v10",
  "aggregateId": "REV-123",
  "version": 10,  // After 10 events
  "state": {
    "status": "IN_REVIEW",
    "assignedTo": "DOC-456",
    "comments": ["...", "..."],
    "createdAt": "..."
  }
}

Rehydration (optimized):
1. Find latest snapshot for REV-123 (version 10)
2. Load snapshot state (current as of event 10)
3. Query events AFTER version 10 (events 11+)
4. Replay only new events
5. Result: 10x faster (1 document load + 0 replays vs 10 replays)
```

Backup & Archival:
```
Events > 1 year old → Archive to Blob Storage (cheap)

Partition Key: 2024-01-01/REV-123
- As partitions age, entire partition → Blob
- Cosmos DB: Keeps only current events
- Cost: $0.0003/hour per partition → $0.0001/hour in Blob

Restore:
- Old query needed? (rare) → Load from Blob on-demand
- New events? Continue with current partition

Example:
Cosmos DB size: 6 months × $1000 = $6,000
Blob archive: 12 months × $100 = $1,200
Savings: $4,800/month by archiving
```

Monitoring:
```
☐ RU consumption: < 100k RU/s (no throttling)
☐ Partition size: < 10 GB each (no splits)
☐ Rehydration latency: p99 < 500ms
☐ Hot partitions: No single partition > 20% of total load
☐ Index size: Monitored (indexes use RU)
☐ Document count: Growing linearly (1M/day expected)
```

Cost Optimization:
```
Current: 100,000 RU/s × $0.012/hour = $8,640/month

Optimization 1: Reduce RU/document
- Compress JSON (remove whitespace)
- Store only deltas (not full state in snapshot)
- Savings: 30% RU reduction

Optimization 2: Archive old data
- Events > 1 year → Blob Storage
- Saves: 50% of Cosmos DB cost (400M events over 2 years)

Optimization 3: Use Serverless
- If bursty: Peak 100k RU/s, average 20k RU/s
- Provisioned: $8,640/month (for 100k)
- Serverless: 20k RU/s avg × $0.0000006 = $1,200/month
- Savings: 86%

Final cost: $8,640 → $400/month (94% reduction via optimization)
```
```

---

**Q8b: Your Cosmos DB partition fills up (>10GB) and splits. How does split impact performance? How would you handle it?**

**Sample Answer:**
```
Partition Split Mechanics:

Cosmos DB limits per logical partition:
- Max size: 10 GB
- Max throughput: Cannot be exceeded

When partition exceeds 10 GB:
1. Physical partition splits into 2
2. Data redistributed (roughly 50/50)
3. Existing queries might reroute

Performance Impact During Split:

Impact 1: Temporary latency increase
- Split operation: < 5 seconds (usually)
- Queries during split: Might wait 100-500ms
- Application impact: Brief slowdown, not outage

Impact 2: Throughput repartitioning
- Before: 10k RU/s on 1 partition
- Split happens: 5k RU/s on partition A, 5k RU/s on partition B
- After stabilization: Both partitions can handle more load

Example (Good split):
Patient with 10k RU/s load
Before split: PAT-789-shard-0 (hot, 10k RU/s)
After split:
  Physical Partition 1: Reviews A-M for PAT-789 (5k RU/s)
  Physical Partition 2: Reviews N-Z for PAT-789 (5k RU/s)

Example (Bad split):
If split uneven:
  Physical Partition 1: Reviews A-M (1k RU/s)
  Physical Partition 2: Reviews N-Z (9k RU/s) ← Still hot!

Prevention Strategy 1: Proactive Partitioning

Don't wait for 10 GB limit, partition earlier:

```csharp
public string GetPartitionKey(string patientId)
{
    // Get patient's current load
    var load = await GetCurrentLoadAsync(patientId);
    
    if (load > 5000)  // Proactive threshold
    {
        // Use synthetic key to pre-split load
        var shardCount = Math.Ceil(load / 2500);
        var shard = GetShardForPatient(patientId, shardCount);
        
        return $"{patientId}-shard-{shard}";
    }
    else
    {
        // Normal partition key
        return patientId;
    }
}
```

Prevention Strategy 2: Monitor and Alert

Track partition health:
```csharp
// Monitor partition size
public async Task MonitorPartitions()
{
    var container = await database.GetContainer("events");
    
    // Query partition metrics
    var query = @"
        SELECT COUNT(1) as eventCount, 
               SUM(LENGTH(JSON_SERIALIZE(c))) as sizeBytes
        FROM c
        GROUP BY c.patitionKey";
    
    // Check for partitions > 8 GB
    if (sizeBytes > 8 * 1024 * 1024 * 1024)
    {
        _alerting.SendAlert($"Partition {partition} approaching limit");
    }
}
```

Prevention Strategy 3: Hot Partition Early Detection

```csharp
// Use application insights to track query latency by partition
public async Task<Review> GetReviewAsync(string reviewId, string patientId)
{
    var startTime = DateTime.UtcNow;
    
    try
    {
        return await container.ReadItemAsync<Review>(
            id: reviewId,
            partitionKey: new PartitionKey(patientId));
    }
    finally
    {
        var duration = DateTime.UtcNow - startTime;
        
        // If consistently > 100ms, probably hot partition
        if (duration.TotalMilliseconds > 100)
        {
            _telemetry.TrackEvent("SlowPartition", new
            {
                patitionKey = patientId,
                latency_ms = duration.TotalMilliseconds
            });
        }
    }
}
```

Handling During Split:

If split causes issues:
```
1. Observe latency increase
2. Application Insights shows temporary latency blip
3. After 5-10 seconds: Latency returns to normal
4. No action needed (automatic)

If split goes wrong (uneven):
1. One physical partition still hot (9k RU/s)
2. Monitor detects continued high latency
3. Manually repartition:
   a. Create new container with better partition key
   b. Bulk copy data with new key
   c. Redirect writes to new container
   d. Delete old container
   
Downtime: < 5 minutes (bulk copy is fast)
```

Cost Impact of Split:

Before split (10 GB, hot):
- Provisioned: 100,000 RU/s = $8,640/month
- Explanation: Hot partition requires high throughput

After split (5 GB each, balanced):
- Provisioned: Can reduce to 50,000 RU/s = $4,320/month
- Explanation: Load now spread across 2 partitions
- Savings: 50%

Monitoring During/After Split:
```
Dashboard showing partition health:

Partition          | Size   | RU/s  | Health
──────────────────────────────────────────────
PAT-789-shard-0    | 7.5 GB | 4500  | 🟢 Good
PAT-789-shard-1    | 7.2 GB | 5200  | 🟡 Warm
PAT-789-shard-2    | 3.1 GB | 800   | 🟢 Good
REV-QUEUE          | 0.8 GB | 100   | 🟢 Good
──────────────────────────────────────────────

Alert if:
- Partition > 9 GB (approaching limit)
- Partition RU/s throttled (sudden drop in write success)
- Latency p99 > 1000ms (split in progress?)
```

Best Practices:
```
✓ Use synthetic partition keys for hot data
✓ Monitor partition size monthly
✓ Provision 30-50% headroom above average
✓ Have runbook for manual repartitioning
✓ Test partition split behavior in staging
✓ Don't panic (Cosmos DB handles splits automatically)
```
```

---

**Q8c: You're storing 5 years of event data (2 billion events). How would you optimize storage and keep query performance good?**

**Sample Answer:**
```
2 Billion Events Analysis:

Scenarios:
- Healthcare system: 5 years of authorizations, reviews, decisions
- 400k authorizations/day × 365 days × 5 years = 730M events
- Plus duplicates, retries, etc. → 2B events

Storage Impact:
- 1 event ≈ 500 bytes (typical)
- 2B events × 500 bytes = 1 TB raw
- With Cosmos DB overhead: ~3-4 TB provisioned

Cost:
- 4 TB @ $0.0003/GB/hour = $28,800/month (very expensive!)

Solution: Tiered Storage Architecture

Tier 1: Hot Data (Current Year - Recent)
├─ Container: "events-hot"
├─ Data: Last 6 months
├─ Provisioning: 50,000 RU/s (active queries)
├─ Size: 150 GB
├─ Cost: $432/month
├─ Queries: Real-time, < 100ms p99

Tier 2: Warm Data (Archive - Sometimes Needed)
├─ Storage: Azure Blob Storage
├─ Data: 6 months - 1 year
├─ Size: 300 GB
├─ Cost: $30/month (blob storage cheap)
├─ Queries: On-demand, accepts 1-5 minute latency

Tier 3: Cold Data (Archive - Rarely Needed)
├─ Storage: Azure Blob Archive tier
├─ Data: 1-5 years
├─ Size: 1.5 TB
├─ Cost: $7.50/month (archive tier super cheap)
├─ Queries: Very rare, 12+ hour rehydration OK

Archival Strategy:

Every 6 months:
1. Identify events to archive (older than 6 months)
2. Query: SELECT * FROM events WHERE timestamp < NOW() - 6 months
3. Stream to Azure Data Lake Gen 2 (or Blob)
4. Compress with Parquet (50% compression)
5. Delete from Cosmos DB
6. Keep pointer table (event range → blob location)

Code:
```csharp
public async Task ArchiveOldEventsAsync()
{
    var cutoffDate = DateTime.UtcNow.AddMonths(-6);
    
    // Find all events to archive
    var query = $@"
        SELECT c.id, c.patientId, c.eventData
        FROM events c
        WHERE c.timestamp < @cutoff";
    
    var iterator = container.GetItemQueryIterator<dynamic>(
        query: query,
        parameters: new[] { new SqlParameter("@cutoff", cutoffDate) });
    
    // Stream to Blob in batches
    var batch = new List<dynamic>();
    
    while (iterator.HasMoreResults)
    {
        var events = await iterator.ReadNextAsync();
        batch.AddRange(events);
        
        if (batch.Count >= 10000)
        {
            // Write batch to blob as Parquet
            await WriteToParquetAsync(batch);
            batch.Clear();
        }
    }
    
    // Delete archived events from Cosmos
    await container.DeleteItemAsync(eventId, new PartitionKey(patientId));
}
```

Query Strategy for Old Data:

User asks: "Show me events from 2022"

Flow:
1. Check if in Cosmos DB (hot data)
   - Query: SELECT * FROM events WHERE timestamp >= 2024-01-01
   - Result: Fast, < 100ms
2. If not, check pointer table
   - Pointer shows: "2022 events in blob-archive-2022-2023.parquet"
   - Return: "Loading archived data, please wait 30 seconds"
3. Load from blob
   - Stream parquet file
   - Filter to requested dates
   - Return to user

Cost Comparison:

Option A: Keep all 2B events in Cosmos DB
├─ Storage: 4 TB
├─ Cost: $28,800/month
├─ Query speed: < 100ms
├─ Affordable for: Fortune 500

Option B: Tiered Storage (Hot + Archive)
├─ Cosmos DB hot: 150 GB = $432/month
├─ Blob warm: 300 GB = $30/month
├─ Blob cold: 1.5 TB = $7.50/month
├─ Total: $469.50/month
├─ Savings: 98%!
├─ Trade-off: Old queries need 30-60 seconds

Best Practice Implementation:

```csharp
public class EventQueryService
{
    public async Task<List<Event>> QueryEventsAsync(
        DateTime startDate, 
        DateTime endDate)
    {
        var now = DateTime.UtcNow;
        var sixMonthsAgo = now.AddMonths(-6);
        
        List<Event> results = new();
        
        // Split into hot and cold
        var hotEnd = sixMonthsAgo;
        var coldStart = startDate;
        
        // Query hot data if in range
        if (endDate >= hotEnd)
        {
            var hotResults = await QueryHotDataAsync(
                startDate, 
                endDate);
            results.AddRange(hotResults);
        }
        
        // Query cold data if in range
        if (startDate < hotEnd)
        {
            var coldResults = await QueryColdDataAsync(
                startDate, 
                Math.Min(endDate, hotEnd));
            results.AddRange(coldResults);
        }
        
        return results;
    }
    
    private async Task<List<Event>> QueryHotDataAsync(
        DateTime start, DateTime end)
    {
        // Cosmos DB query (fast)
        var query = @"
            SELECT * FROM events
            WHERE c.timestamp BETWEEN @start AND @end";
        
        var iterator = container.GetItemQueryIterator<Event>(
            query: query,
            parameters: new[] 
            {
                new SqlParameter("@start", start),
                new SqlParameter("@end", end)
            });
        
        var results = new List<Event>();
        while (iterator.HasMoreResults)
        {
            results.AddRange(await iterator.ReadNextAsync());
        }
        
        return results;
    }
    
    private async Task<List<Event>> QueryColdDataAsync(
        DateTime start, DateTime end)
    {
        // Find relevant archive blobs
        var archiveFiles = await FindArchiveFilesAsync(start, end);
        
        var results = new List<Event>();
        
        foreach (var blobPath in archiveFiles)
        {
            // Load parquet file
            using (var stream = await blobClient
                .OpenReadAsync(blobPath))
            {
                var parquetReader = new ParquetReader(stream);
                
                // Filter to date range
                var table = parquetReader.ReadAsTable();
                var filtered = table.AsEnumerable()
                    .Where(row => 
                        row["timestamp"] >= start && 
                        row["timestamp"] <= end)
                    .Select(row => MapToEvent(row));
                
                results.AddRange(filtered);
            }
        }
        
        return results;
    }
}
```

Archival Schedule:

Monthly maintenance:
```
Day 1:
- Identify events > 6 months old
- Create archive job (runs nightly)

Day 2-5:
- Stream events to Parquet
- Compress and upload to blob
- Validate integrity

Day 6:
- Delete from Cosmos DB
- Test retrieval from archive

Day 7:
- Update pointer table
- Notify teams of old data move
- Log completion
```

Monitoring:
```
☐ Hot data size: < 200 GB (current data only)
☐ Archive cost: < $50/month (cheap!)
☐ Query latency hot data: p99 < 100ms
☐ Query latency cold data: p99 < 60s (accept slowness)
☐ Compression ratio: 50-70% (savings)
☐ Archive restore time: < 30 seconds per archive
```

Data Retention Policy:
```
Current law: Keep 5 years for audit
├─ Year 1: Hot (Cosmos DB, fast, expensive)
├─ Year 2: Warm (Blob, slower, cheap)
├─ Year 3-5: Cold (Archive tier, very cheap, slow)

Future law: Keep 7 years
└─ Just add Year 6-7 to cold archive (minimal cost)
```
```

---

### **9. Data Migration: SQL Server → Kafka (Qlik Replicate) (3 Questions)**

**Q9a: Design a zero-downtime migration from SQL Server to Kafka using CDC. How would you handle initial load + incremental changes?**

**Sample Answer:**
```
Migration Strategy: Dual-Write Pattern with Validation

Phase 1: Initial Snapshot (Weeks 1-2)
├─ Qlik Replicate: CDC enabled on SQL Server
├─ Qlik: Full dump of all tables to Kafka topics
├─ Size: 50 GB (healthcare dataset)
├─ Topics created:
│  ├─ authorization.snapshot (full data)
│  ├─ review.snapshot
│  └─ decision.snapshot
├─ Timeline: 4-6 hours (parallel streams)
└─ Validation: Count match, checksums match

Phase 2: Incremental CDC (Weeks 2-3)
├─ SQL Server: Enable CDC (Change Data Capture)
├─ Qlik Replicate: Configure to capture deltas
├─ Topics:
│  ├─ authorization.changes (INSERT, UPDATE, DELETE)
│  ├─ review.changes
│  └─ decision.changes
├─ Latency: Real-time (< 1 second)
├─ Parallel: Snapshot + incremental for recent changes

Phase 3: Validation (Week 3)
├─ Run reconciliation: SQL Server vs Kafka
├─ Sample 10,000 records, hash comparison
├─ Check for skipped events, duplicates
├─ If mismatch > 0.1%: Investigate & retry
├─ If OK: Proceed to cutover

Phase 4: Cutover (Week 4)
├─ DNS switch: Applications → Kafka consumer (instead of SQL Server)
├─ Dual write: Services write to SQL Server AND Kafka (temporarily)
├─ Verify: Kafka + SQL Server in sync
├─ Timeline: 30 minutes to 2 hours
└─ Rollback plan: Reverse DNS if issues

SQL Server CDC Configuration:
```csharp
// Enable CDC on SQL Server
-- Enable CDC on database
EXEC sys.sp_cdc_enable_db;

-- Enable CDC on specific table
EXEC sys.sp_cdc_enable_table
    @source_schema = 'dbo',
    @source_name = 'Authorization',
    @role_name = NULL,
    @supports_net_changes = 1;

-- Check CDC status
SELECT * FROM sys.cdc_tables WHERE object_id = OBJECT_ID('dbo.Authorization');
```

Qlik Replicate Configuration:
```json
{
  "source": {
    "type": "SqlServer",
    "hostname": "sql-server.database.windows.net",
    "username": "qlik-user",
    "password": "${QLIK_PASSWORD}",
    "database": "HealthcareDB",
    "cdc": {
      "enabled": true,
      "capture_mode": "CDC"  // Use SQL Server CDC
    }
  },
  "target": {
    "type": "Kafka",
    "brokers": ["kafka-1:9092", "kafka-2:9092"],
    "compression": "snappy",
    "batch_size": 10000,
    "batch_timeout_ms": 5000
  },
  "tables": [
    {
      "source_table": "dbo.Authorization",
      "target_topic": "authorization.changes",
      "key_column": "AuthorizationId",
      "include_before_image": true,
      "include_operation_type": true
    },
    {
      "source_table": "dbo.Review",
      "target_topic": "review.changes"
    },
    {
      "source_table": "dbo.Decision",
      "target_topic": "decision.changes"
    }
  ]
}
```

Message Format (Kafka):
```json
{
  "operation": "INSERT",  // INSERT, UPDATE, DELETE
  "table": "Authorization",
  "source_timestamp": "2024-01-15T10:00:00Z",
  "before": null,  // For INSERT: null
  "after": {
    "AuthorizationId": "AUTH-123",
    "PatientId": "PAT-789",
    "Status": "APPROVED",
    "CreatedAt": "2024-01-15T10:00:00Z"
  }
}
```

Handling Deletes (Soft Deletes):
```
SQL Schema:
Authorization {
  AuthorizationId: PK
  PatientId: FK
  Status: string
  IsDeleted: bool  // Soft delete flag
  DeletedAt: DateTime?
}

CDC Event on delete:
{
  "operation": "UPDATE",
  "before": { "IsDeleted": false },
  "after": { "IsDeleted": true, "DeletedAt": "2024-01-15T10:00:00Z" }
}

Consumer sees: Mark as deleted, don't actually remove
```

Data Validation During Migration:
```csharp
public async Task ValidateMigrationAsync()
{
    // Compare SQL Server vs Kafka
    
    // Count check
    var sqlCount = await GetCountFromSqlAsync("Authorization");
    var kafkaCount = await GetCountFromKafkaAsync("authorization.changes");
    
    if (sqlCount != kafkaCount)
    {
        Console.WriteLine($"Mismatch: SQL={sqlCount}, Kafka={kafkaCount}");
        return;
    }
    
    // Hash check (sample 10k records)
    var sqlSample = await GetSampleHashesFromSqlAsync("Authorization", limit: 10000);
    var kafkaSample = await GetSampleHashesFromKafkaAsync("authorization.changes", limit: 10000);
    
    var mismatches = sqlSample.Join(
        kafkaSample,
        sql => sql.Id,
        kafka => kafka.Id,
        (sql, kafka) => new
        {
            Id = sql.Id,
            SqlHash = sql.Hash,
            KafkaHash = kafka.Hash
        })
        .Where(x => x.SqlHash != x.KafkaHash)
        .ToList();
    
    if (mismatches.Count > 0)
    {
        Console.WriteLine($"Mismatches detected: {mismatches.Count}");
        foreach (var m in mismatches)
        {
            Console.WriteLine($"  ID={m.Id}: SQL={m.SqlHash} vs Kafka={m.KafkaHash}");
        }
    }
}
```

Dual-Write During Cutover:
```csharp
// During transition: Write to both SQL Server and Kafka
public async Task CreateAuthorizationAsync(Authorization auth)
{
    // Write to SQL Server (old)
    await _sqlDbContext.Authorizations.AddAsync(auth);
    await _sqlDbContext.SaveChangesAsync();
    
    // Write to Kafka (new)
    var authEvent = new AuthorizationCreatedEvent
    {
        AuthorizationId = auth.Id,
        PatientId = auth.PatientId,
        Status = auth.Status
    };
    
    await _kafkaProducer.ProduceAsync("authorization.changes", 
        new Message<string, AuthorizationCreatedEvent>
        {
            Key = auth.Id,
            Value = authEvent
        });
    
    // Verify consistency
    if (!ConsistencyCheck(auth, authEvent))
    {
        _alerting.SendAlert("Dual-write inconsistency detected");
    }
}
```

Challenges & Solutions:

| Challenge | Solution |
|-----------|----------|
| Data in transit during snapshot | Dual snapshot: Initial + incremental overlap |
| Schema changes | Version events (event_schema_version field) |
| Deletes | Soft deletes (IsDeleted flag) |
| Duplicates | Idempotent key (DB table dedup) |
| Lag between SQL and Kafka | Monitor with maximum lag check |
| Corrupted data | Hash validation + manual review |

Rollback Plan:
```
If Kafka issues detected during cutover:

1. Revert DNS (applications → SQL Server)
2. Stop writing to Kafka
3. Investigate issue
4. Restart from Phase 3 validation

Time to rollback: < 5 minutes
User impact: < 2 minute interruption
```

Monitoring:
```
☐ Snapshot progress: % data replicated
☐ CDC lag: Seconds between SQL change and Kafka event
☐ Replication latency: p99 < 1 second
☐ Error count: 0 errors expected
☐ Message count: Matches expectations
☐ Duplicates: Rate < 0.1%
```

Success Criteria:
```
✓ Snapshot completed (100% data migrated)
✓ CDC running (incremental changes < 1s lag)
✓ Validation passed (hash match, count match)
✓ Dual-write consistent (20+ hours logged)
✓ Rollback tested (practiced with staging)
✓ Monitoring alerts configured
✓ Team trained on new architecture
```
```

---

**Q9b: CDC pipeline lags (5+ minute delay between SQL change and Kafka). How would you diagnose and fix the lag?**

**Sample Answer:**
```
CDC Lag Diagnosis:

Symptoms:
- Patient sees update in SQL Server
- But Kafka consumer reads old data (5 minutes stale)
- Application UI shows outdated info

Root Cause Analysis Checklist:

1. Qlik Replicate Status
   - Is Qlik service running? (RESTART if crashed)
   - Check logs: errors, warnings, pauses
   - Qlik UI: Is replication "Active" or "Paused"?

2. SQL Server CDC Status
   - Is CDC enabled and running?
   - SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'Authorization'
   - Are CDC table captures running?
   - Check: SELECT * FROM sys.cdc_lsn_time_mapping

3. Network Latency
   - Qlik → SQL Server: Ping latency
   - Qlik → Kafka: Ping latency
   - DNS resolution: OK?

4. Qlik Performance
   - CPU: % utilization (if high, bottleneck)
   - Memory: Leaks? (if high, restart)
   - Disk I/O: Slow writes to Kafka?

5. Kafka Performance
   - Broker rebalancing happening? (causes pause)
   - Network saturation? (slow writes)
   - Disk full? (write delays)

6. Batch Configuration
   - Batch size: Too large? (waits longer before send)
   - Batch timeout: Too long? (waits longer before send)

Diagnosis Query (SQL Server):
```sql
-- Check CDC table captures
SELECT 
    name,
    cdc_role,
    captured_column_count
FROM sys.cdc_tables;

-- Check capture process status
EXEC sys.sp_cdc_help_jobs;

-- Recent LSN (Log Sequence Number)
SELECT 
    max_lsn,
    min_lsn,
    begin_lsn,
    seqnum
FROM cdc.lsn_time_mapping
ORDER BY seqnum DESC
LIMIT 100;

-- Estimate lag: Last change capture time
SELECT 
    DATEDIFF(SECOND, MAX(tbl_timestamp), GETUTCDATE()) as lag_seconds
FROM cdc.dbo_Authorization_CT;
```

Fix 1: Increase Batch Size (If Batching is slow)

Current: batch_size=1000, batch_timeout=5000ms
Problem: Waits 5 seconds before sending each batch
Solution: Send smaller batches more frequently

New: batch_size=100, batch_timeout=500ms
├─ Sends every 500ms instead of 5000ms
├─ More Kafka round-trips (more network)
├─ But lower latency (10x improvement)

```json
{
  "qlik_replication": {
    "batch_size": 100,          // Smaller batches
    "batch_timeout_ms": 500,    // Shorter timeout
    "max_in_flight": 10         // Allow 10 batches in-flight
  }
}
```

Trade-off:
├─ Pro: Latency 5s → 500ms (10x better)
├─ Con: 10x more Kafka API calls
└─ Net: Worth it for real-time requirements

Fix 2: Optimize SQL Server CDC

CDC process might be slow (batch capture):

```sql
-- Increase CDC capture job parallelism
EXEC sys.sp_cdc_change_job @job_type = 'capture', @maxtrans = 5000, @maxscans = 100;

-- Check capture latency
EXEC sys.sp_cdc_check_job @job_type = 'capture';

-- If high latency, increase parallel threads
UPDATE cdc.cdc_jobs 
SET job_config = '{"parallel_threads": 5}'
WHERE job_type = 'capture';
```

Fix 3: Upgrade Qlik Instance

If Qlik CPU is high (> 80%), it's the bottleneck:

Current: qlik-vm (4 vCPU, 8 GB RAM)
├─ CPU: 95% (maxed out)
├─ Memory: 6.5 GB used
└─ Cannot process faster

Solution: Upgrade to larger VM
New: qlik-vm-large (16 vCPU, 32 GB RAM)
├─ CPU: 20% (headroom)
├─ Memory: Sufficient for caching
├─ Can handle 10x more changes/second

Downtime: < 2 minutes (Qlik failover to new instance)
Cost: 4x higher, but necessary if bottleneck

Fix 4: Parallel Streams (For Multiple Tables)

Current: Single Qlik instance → All tables sequentially
Problem: If Authorization table changes are high, Review table waits

Solution: Multiple Qlik instances (one per table)

```
Qlik Instance 1 → authorization.changes
Qlik Instance 2 → review.changes
Qlik Instance 3 → decision.changes
```

Latency: 5s → ~2s (3x improvement, parallel processing)
Cost: 3x Qlik cost
Trade-off: Worth if low latency critical

Fix 5: Check Kafka Broker Health

If Kafka is slow, CDC lag increases:

```bash
# Check Kafka metrics
kafka-consumer-groups --bootstrap-server localhost:9092 --group qlik-replicator --describe

# Expected: lag = 0 (consumer keeping up)
# If lag > 1000: Kafka is slow

# Check broker disk
du -sh /var/kafka/data

# If > 90%: Disk full (writes slow)
# Solution: Add disk space or delete old partitions

# Check rebalancing
kafka-topics --bootstrap-server localhost:9092 --describe --under-replicated-partitions

# If results: Rebalancing happening (causes lag spikes)
```

Fix 6: Increase CDC Retention (Prevent Loss)

If Kafka falls far behind, SQL Server CDC can lose changes (retention is 3-7 days):

```sql
-- Increase CDC retention to 14 days
EXEC sys.sp_cdc_change_job @job_type = 'cleanup', @retention = 20160;
-- 20160 minutes = 14 days
```

Monitoring After Fix:

```
Dashboard metrics:

Metric              | Before | After | Target
─────────────────────────────────────────────────
CDC lag             | 5m     | 500ms | < 1s
Kafka Consumer lag  | 5m     | 100ms | < 1s
Batch size          | 1000   | 100   | 50-500
Batch timeout       | 5s     | 500ms | 100-1000ms
Messages/sec        | 200    | 2000  | > 1000
CPU (Qlik)          | 95%    | 25%   | < 70%
─────────────────────────────────────────────────

Alerts:
- CDC lag > 10s: Page engineer
- Kafka consumer lag > 10s: Alert
- Qlik CPU > 80%: Scale up
```

Verification After Fix:
```sql
-- Measure current lag
SELECT 
    DATEDIFF(SECOND, MAX(captured_change_time), GETUTCDATE()) as lag_seconds
FROM cdc.dbo_Authorization_CT;

-- Expected: < 1 second
```
```

---

**Q9c: A Kafka consumer crashes while processing CDC events. How do you prevent data loss and avoid reprocessing duplicates?**

**Sample Answer (already covered in Q6a-c on idempotent consumers, can reference those scenarios)**

---

### **10. JWT-Based Authentication (3 Questions)**

**Q10a: Design a JWT authentication system for both internal clinicians (Azure AD) and external patients (Azure AD B2C). How would you handle token validation, refresh, and security?**

**Sample Answer:**
```
Two-Tenant Architecture:

Tenant 1: Internal Clinicians (Azure AD)
├─ Directory: Company's Azure AD
├─ Users: All clinicians, administrators
├─ Authentication: MFA required
├─ Tokens: Access + Refresh tokens
└─ Duration: 1 hour access, 7 days refresh

Tenant 2: External Patients (Azure AD B2C)
├─ Directory: Customer's own B2C directory
├─ Users: Self-registered patients
├─ Authentication: Email/password or social login
├─ Tokens: ID + Access tokens
└─ Duration: 1 hour access, 90 days refresh

Authentication Flow (Clinician):

1. Clinician visits: app.healthcare.com/login
2. Redirects to: login.microsoftonline.com/{tenant-id}/oauth2/v2.0/authorize
3. User enters: Email + password + MFA code
4. Azure AD returns: Authorization code
5. Backend exchanges: Code for Access Token + Refresh Token
6. Returns to frontend: Tokens in httpOnly secure cookie

Access Token Structure:
```json
{
  "header": {
    "alg": "RS256",           // Signed with Azure AD private key
    "typ": "JWT",
    "kid": "rsa_key_1"        // Key ID for signature validation
  },
  "payload": {
    "aud": "api://app-id",    // Audience (our API)
    "iss": "https://login.microsoftonline.com/{tenant-id}/v2.0",
    "iat": 1705316000,        // Issued at
    "exp": 1705319600,        // Expires in 1 hour
    "sub": "user-123",        // Subject (user ID)
    "oid": "oid-456",         // Object ID (Azure AD)
    "upn": "clinician@company.com",
    "roles": ["reviewer", "approver"],
    "scp": "read write"       // Scopes (permissions)
  },
  "signature": "..."
}
```

Refresh Token Structure:
```json
{
  "header": { "alg": "RS256" },
  "payload": {
    "exp": 1708008000,        // Expires in 30 days (or 7 days)
    "sub": "user-123",
    "iss": "https://login.microsoftonline.com/{tenant-id}/v2.0",
    "refresh_token_ver": 1
  },
  "signature": "..."
}
```

Token Validation at API Gateway (APIM):

```csharp
public class JwtValidationPolicy : IHttpRequestMessage
{
    public async Task OnBeforeRequest(HttpRequestMessage request)
    {
        // Extract JWT from Authorization header
        var authHeader = request.Headers.Authorization?.Parameter;
        if (authHeader == null)
        {
            throw new UnauthorizedAccessException("Missing JWT");
        }
        
        try
        {
            // Parse JWT
            var handler = new JwtSecurityTokenHandler();
            var token = handler.ReadJwtToken(authHeader);
            
            // Validate signature (using Azure AD JWKS)
            var parameters = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKeys = await GetAzureAdKeysAsync(),  // Public keys from JWKS endpoint
                ValidateIssuer = true,
                ValidIssuer = "https://login.microsoftonline.com/{tenant-id}/v2.0",
                ValidateAudience = true,
                ValidAudience = "api://healthcare-api",
                ValidateLifetime = true,
                ClockSkew = TimeSpan.FromSeconds(60)
            };
            
            var principal = handler.ValidateToken(authHeader, parameters, out var validatedToken);
            
            // Extract claims
            var userId = principal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var roles = principal.FindAll(ClaimTypes.Role);
            
            // Attach to context for later use
            request.Context.User = principal;
            request.Context.UserId = userId;
            request.Context.Roles = roles;
            
            return;
        }
        catch (SecurityTokenException ex)
        {
            throw new UnauthorizedAccessException($"Invalid JWT: {ex.Message}");
        }
    }
    
    private async Task<IEnumerable<SecurityKey>> GetAzureAdKeysAsync()
    {
        // Cache Azure AD public keys (change infrequently)
        // JWKS endpoint: https://login.microsoftonline.com/{tenant-id}/discovery/v2.0/keys
        
        var jwksUri = "https://login.microsoftonline.com/{tenant-id}/discovery/v2.0/keys";
        var handler = new HttpClientHandler();
        var httpClient = new HttpClient(handler);
        
        var response = await httpClient.GetAsync(jwksUri);
        var json = await response.Content.ReadAsStringAsync();
        
        var jwks = JsonConvert.DeserializeObject<JsonWebKeySet>(json);
        return jwks.Keys
            .Select(k => new JsonWebKey(json) { Kid = k.Kid })
            .Cast<SecurityKey>()
            .ToList();
    }
}
```

Token Refresh Flow:

Access token expires in 1 hour:
1. Frontend detects: exp claim < now + 5 minutes
2. Frontend calls: POST /auth/refresh
3. Backend reads: Refresh token from httpOnly cookie
4. Validates: Refresh token still valid
5. Calls: Azure AD token endpoint with refresh token
6. Azure AD returns: New access token + new refresh token
7. Sets: httpOnly cookie with new tokens

Code:
```csharp
[HttpPost("auth/refresh")]
public async Task<RefreshTokenResponse> RefreshToken()
{
    // Get refresh token from httpOnly cookie
    var refreshToken = Request.Cookies["refresh_token"];
    
    if (string.IsNullOrEmpty(refreshToken))
    {
        throw new UnauthorizedAccessException("Missing refresh token");
    }
    
    try
    {
        // Exchange refresh token for new access token
        var client = new HttpClient();
        var request = new Dictionary<string, string>
        {
            { "grant_type", "refresh_token" },
            { "client_id", "app-id" },
            { "client_secret", "app-secret" },
            { "refresh_token", refreshToken },
            { "scope", "api://healthcare-api/.default" }
        };
        
        var content = new FormUrlEncodedContent(request);
        var response = await client.PostAsync(
            "https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token",
            content);
        
        if (!response.IsSuccessStatusCode)
        {
            throw new Exception("Token refresh failed");
        }
        
        var json = await response.Content.ReadAsStringAsync();
        var tokenResponse = JsonConvert.DeserializeObject<TokenResponse>(json);
        
        // Return new tokens in httpOnly cookie
        Response.Cookies.Append(
            "access_token",
            tokenResponse.AccessToken,
            new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddHours(1)
            });
        
        Response.Cookies.Append(
            "refresh_token",
            tokenResponse.RefreshToken,
            new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddDays(30)
            });
        
        return new RefreshTokenResponse
        {
            Success = true,
            ExpiresIn = tokenResponse.ExpiresIn
        };
    }
    catch (Exception ex)
    {
        return new RefreshTokenResponse
        {
            Success = false,
            Error = ex.Message
        };
    }
}
```

Security Best Practices:

1. Token Storage:
   ```
   ✗ DO NOT: localStorage (vulnerable to XSS)
   ✗ DO NOT: sessionStorage (vulnerable to XSS)
   ✓ DO: httpOnly cookie (XSS safe)
   ✓ DO: Secure flag (HTTPS only)
   ✓ DO: SameSite=Strict (CSRF safe)
   ```

2. Token Lifetime:
   ```
   Access token: 1 hour (short-lived)
   └─ If compromised, attacker has < 1 hour
   
   Refresh token: 30 days (long-lived)
   └─ Stored server-side (can revoke)
   └─ Rarely sent over network
   ```

3. Signature Validation:
   ```
   ✓ Validate signature (proves token from Azure AD)
   ✓ Validate expiry (prevents replay)
   ✓ Validate audience (prevents use on wrong API)
   ✓ Validate issuer (prevents spoofing)
   ```

4. Token Revocation:
   ```
   When user logs out:
   1. Delete refresh token from server
   2. Clear httpOnly cookie
   3. Frontend discards access token
   
   On next request:
   - Access token still valid (until 1 hour expires)
   - But users can't get new tokens (refresh revoked)
   - After 1 hour: Access denied
   ```

5. CORS Configuration:
   ```
   Allowed origins: Only app.healthcare.com
   Credentials: true (send cookies)
   Methods: GET, POST, PUT, DELETE
   ```

Monitoring & Alerts:
```
☐ Failed JWT validations: Rate < 0.1%
☐ Expired tokens: Monitor refresh success rate
☐ Token issuance: Monitor Azure AD health
☐ JWKS fetch failures: Alert (can't validate tokens)
☐ Refresh token revocation: Log all logouts
```

Test Cases:
```
✓ Valid token: Accepted
✓ Expired token: Rejected
✓ Wrong issuer: Rejected
✓ Wrong audience: Rejected
✓ Invalid signature: Rejected
✓ Refresh token valid: Returns new access token
✓ Refresh token expired: Returns 401
✓ XSS attempt to steal token: httpOnly prevents
```
```

---

### **11. Scalability Concerns (10x Growth)**

**Sample Answer:**
```
Current: 10k auth/day, 500 concurrent, 10GB

At 10x (100k/day, 5000 concurrent):

Breaking Points (Tier 1):
1. Database (DTU limits) → Switch to Hyperscale
2. APIM (throughput) → Premium tier, multi-region
3. AKS (node limits) → Multi-cluster, region distribution

Cost Impact:
- Current: $5k/month
- After 10x: $20-25k/month
- Per-auth cost: Better efficiency

Scaling Strategy:
1. Database: Azure SQL Hyperscale
2. API: APIM Premium (3 units, 3 regions)
3. Compute: AKS multi-cluster (3 regions, 50 nodes)
4. Caching: Azure Cache for Redis
5. Search: Azure Search Index
6. Messaging: Kafka multi-region

Performance Metrics:
- P99 latency: 500ms → 300ms
- Throughput: 100 req/s → 1000 req/s
- Uptime: 99.5% → 99.95%
```

---

### **12. Cost Optimization ($20k → $12k)**

**Sample Answer:**
```
Cost Breakdown:
- AKS: $8k → Switch smaller VMs, use Spot ($3-4k savings)
- Databases: $6k → Hyperscale, serverless ($2-2.5k savings)
- Reserved Instances: 30% discount ($1k savings)
- Networking: $2k → Consolidate, use CDN ($0.5-1k savings)
- APIM: $2k → Shared tier ($0.5-1k savings)

Total Savings: $7-8k/month → $12k achieved

Trade-offs:
- Spot VMs: 2-3 min slower autoscale (acceptable)
- Smaller SKUs: 100ms slower queries (unnoticed)
- 2 replicas: 30s longer failover (still < 1 min)

Monitoring:
- Cost alerts if daily > $600
- Tag resources by team
- Quarterly reviews
```

---

### **13. Architecture Justification (Monolith → Microservices)**

**Sample Answer:**
```
Current Pains (Monolith):
- 1 deployment = entire system down
- Change by Review team breaks Auth (unrelated)
- Hard to scale: Only review bottleneck, scale all
- Database locks on bulk loads
- Weekend-only deployments

Benefits (Microservices):
1. Independence: Deploy separately
2. Scalability: Scale only what's needed ($3k savings)
3. Resilience: One service down ≠ all down
4. Technology flexibility

Risk Mitigation:
- Acknowledge: Harder debugging, more services, network latency
- Phased rollout: Auth service first, then Review
- Timeline: 4 weeks complexity, ROI month 2

Data: Netflix, Uber examples

Decision: Start with 2 services, monitor 4 weeks, expand if good
```

---

### **14. Healthcare Prior Authorization System (100k/month)**

**Sample Answer:**
```
Flow:
Request → Intake → Rules Engine (80% auto) → 
  Manual Queue (20%) → Clinical Review → Decision → Notification

Architecture:
1. Intake Service: Validate, enrich, publish event
2. Rules Engine: Deterministic auto-approval
3. Manual Queue: Prioritize (urgent, high-cost)
4. Review Service: Clinician review, approve/deny
5. Notification: Email, SMS, webhook

Database:
- Authorizations table (status, clinician, reason)
- AuthorizationEvents (audit trail)

Key Features:
- Audit trail (compliance)
- SLA tracking
- Analytics dashboard
- EHR/insurance integrations
- HIPAA encryption, role-based access

Tech Stack:
- Backend: C# microservices
- Database: Azure SQL + Cosmos DB
- Messaging: Kafka + Service Bus
- Frontend: ReactJS
- Cache: Redis
- Search: Azure Search

Scale: 100k/month = 4 req/sec, 80% auto-approve (3ms)
Cost: $50k/month infrastructure
```

---

### **15. Behavioral: Saying "No" to Stakeholder**

**Sample Answer:**
```
Situation:
- VP wanted 15 features, 3 weeks
- Reality: 5 features, 12 weeks with team

Approach:
1. Acknowledged urgency
2. Presented data (timeline, effort, risk)
3. Offered alternatives (MVP + phases)
4. Included VP in prioritization (she chose 5)
5. Gave ownership, not dictate

Delivery:
- Hit 5 features on-time
- Phase 2 accelerated (momentum)
- VP became timeline advocate

Key Insight:
"No with data" > "No without explanation"
Saying "no" = saying "yes" to quality
```

---

## 🎓 Your Professional Brand

**Current Title:** Senior Full-Stack Architect & Technical Lead

**Core Expertise:**
- Healthcare/fintech distributed systems
- Event-driven architecture (Kafka, event sourcing)
- Azure cloud architecture & cost optimization
- Scalability & performance engineering
- Cross-team leadership & delivery under constraints

**Signature Differentiators:**
✔ Design systems for extreme constraints (time, resources)  
✔ Clear thinking under pressure (production crises)  
✔ Cost consciousness (ROI-driven decisions)  
✔ Compliance awareness (healthcare audit trails)  
✔ Business + technical alignment  

**Interview Positioning:**
> *"I design distributed healthcare systems under extreme constraints. I balance technical excellence with business reality, mentor teams, and drive solutions from concept to production—transforming chaotic requirements into scalable, compliant systems."*
---

# 9?? ADVANCED TOPICS (DEPTH COVERAGE)

## **16. ArgoCD & GitOps Deployment Strategy**

**Q: How would you set up GitOps with ArgoCD for microservices deployment?**

**Sample Answer:**
``
GitOps Flow:
1. Developer commits code to main
2. CI builds image, tags with SHA
3. ArgoCD watches git repo
4. On YAML update: Reconcile cluster state
5. Sync automatically (or manual for prod)

Repository Structure:
+-- base/
�   +-- auth-service/
�   +-- review-service/
�   +-- notification-service/
+-- overlays/
�   +-- dev/
�   +-- staging/
�   +-- production/
+-- secrets/ (encrypted)

Benefits:
? Version control for infrastructure
? Audit trail (who changed what, when)
? Reproducible deployments
? Rollback to any commit
? Multi-cluster management
``

---

## **17. Tactical vs Strategic Design Decisions**

**Q: How do you balance tactical (quick) vs strategic (long-term) design?**

**Sample Answer:**
``
TACTICAL (3-week go-live):
- Monolithic backend
- Single SQL Server database
- Manual caching (Redis if needed)
- Feature toggles
- Weekend deployments OK
Cost: \/month

STRATEGIC (Post go-live, 6+ months):
- Microservices extraction
- Multi-region deployment
- Event sourcing
- CQRS for reporting
- Kubernetes management
Cost: \-20k/month

Transition (4-5 months):
- Month 1-2: Run in parallel
- Month 3: Feature parity
- Month 4: Traffic migration
- Month 5: Decomission monolith

Key: Accept debt, pay it back in phases
``

---

## **18. Effort Estimation & Capacity Planning**

**Q: How would you estimate effort for the healthcare project?**

**Sample Answer:**
``
MVP Breakdown (3 weeks):
1. Intake API (40h + 20% = 48h)
2. Rules Engine (50h + 30% = 65h)
3. Clinical Review UI (35h + 25% = 44h)
4. Notification (25h + 15% = 29h)
5. Database & Infra (30h + 20% = 36h)
6. Testing & QA (40h + 30% = 52h)
7. Documentation (20h + 20% = 24h)

Total: 298 hours
Team: 6 people � 40h/week = ~5 weeks
Adjusted: 3 weeks (+ weekend work, - scope)

Rule: If behind, reduce scope, not quality
``

---

## **19. Different Solution Options & Trade-off Analysis**

**Q: Compare 3 architectural options.**

**Sample Answer:**
``
OPTION 1: Serverless (Azure Functions)
Cost: \-2k/mo | Time: 2w | Risk: Medium

OPTION 2: Microservices (AKS)
Cost: \-5k/mo | Time: 5w | Risk: High

OPTION 3: Hybrid (App Service + Service Bus)
Cost: \.5-3k/mo | Time: 3w | Risk: Low-Medium

CHOSEN: Option 3 ?
``

---

## **20. Design Evaluation with Enterprise Architects**

**Q: How do you defend architecture to enterprise architects?**

**Sample Answer:**
``
Presentation (40 mins):
1. Business context (5m)
2. Requirements (5m)
3. Options analyzed (10m)
4. Chosen design (10m)
5. Risk mitigation (5m)
6. Q&A (5m)

Key: Come with data, not opinions
``

---

## **21. Stakeholder Management & Client Appreciation**

**Q: How do you manage stakeholders during chaotic projects?**

**Sample Answer:**
``
Daily Slack standup (async)
Weekly sync (30 mins)
Managing scope creep with options
Managing technical issues with mitigation
Post-launch celebration & feedback loop

Key:
? Over-communicate during crises
? Admit mistakes early
? Celebrate team
``

---

## **22. Micro UI Architecture (Frontend at Scale)**

**Q: Explain Micro UI for clinical review system.**

**Sample Answer:**
``
Monolithic ? Micro UI:
- 1 app ? Independent micro apps
- 500KB each, 2 mins deploy
- Different teams, different tech stacks

Implementation:
1. Module Federation (Webpack 5)
2. Web Components
3. Runtime composition (iframes)

When: Multiple teams (5+ engineers)
``

---

## **23. Automated PR Review (AI-Assisted)**

**Q: Implement automated PR reviews with Copilot?**

**Sample Answer:**
``
Pipeline:
Static Analysis ? AI Review (Copilot) ? Security ? Tests ? Human Review

Copilot checks:
- Null pointer risks
- Unhandled exceptions
- Missing logging
- Security vulnerabilities

Result: 30 mins ? 10 mins per PR (67% faster)
Cost: \/month (SonarQube + Copilot)
``

---

## **24. Production Crisis Management**

**Q: Describe a weekend production incident.**

**Sample Answer:**
``
Scenario: EHR service slow ? Connection pool exhausted ? Cascading failure

Immediate (Friday 6 PM):
- Lower timeout, reduce wait, restart, scale up
- Error rate 10% ? 2% ?

Permanent (Saturday):
- Circuit breaker + cached fallback
- Deploy, verify, ready Monday ?

Incident Protocol:
- Slack alert, page on-call, inform VP
- Mitigation, permanent fix, postmortem

Key:
? Fast detection
? Quick mitigation  
? Root cause fix
? Prevent recurrence
``

---

## ? COMPLETE COVERAGE (All 46 Aspects)

**Architecture & Design:**
? Event-driven, Kafka, AKS, App Service, Subnet, APIM, AppGateway, Microservices
? Orchestrator pattern, Event sourcing, ArgoCD, Tactical vs strategic design

**Technical Patterns:**
? Idempotent consumer, Polly retry, Replay/rehydration, Cosmos DB
? JWT auth, Azure AD B2C, Qlik Replicate, Azure Search, KeyVault

**Frontend:**
? ReactJS, Redux, Micro UI, Automated PR Review

**AI & Emerging Tech:**
? AI assistance, Devin AI, GitHub Copilot, MCP servers POC

**Management:**
? Time-critical delivery, Resource constraints, Tight timelines, Weekend working
? Cost optimization, Scalability, Effort estimation, Stakeholder management
? Client appreciation, Cross-team comms, Healthcare systems, Migration projects
? Production crisis management
