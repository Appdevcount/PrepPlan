# Day 22: Architecture Decision Records (ADRs)

## Master the Art of Technical Decision-Making

As a senior engineer or architect, your ability to make and communicate technical decisions is paramount. Architecture Decision Records (ADRs) are your secret weapon for demonstrating systematic thinking and leadership.

---

## What Are ADRs and Why They Matter

### Definition
Architecture Decision Records document significant architectural decisions made during a project's lifecycle, including the context, options considered, and reasoning behind the final choice.

### Why ADRs Matter in Your Career

**For Your Team:**
- Preserve institutional knowledge
- Onboard new team members faster
- Prevent repeated debates
- Document the "why" behind decisions
- Create accountability and transparency

**For Your Interview:**
- Demonstrate systematic thinking
- Show decision-making maturity
- Prove you consider trade-offs
- Evidence of architectural leadership
- Clear communication of complex topics

### When to Create an ADR

Create an ADR when you make decisions that:
- Are difficult to reverse (high cost of change)
- Significantly impact the system structure
- Affect multiple teams or components
- Involve substantial cost or risk
- Set technical direction or standards
- Resolve significant technical debates

**When NOT to Create an ADR:**
- Trivial implementation details (variable naming, minor refactoring)
- Decisions that are easily reversible
- Team consensus is obvious and immediate
- Temporary workarounds or experiments
- **Balance**: Don't create ADR bureaucracy, but don't skip documenting important decisions

---

## ADR Template and Structure

### The Classic ADR Template

```markdown
# ADR-XXX: [Decision Title]

**Status:** [Proposed | Accepted | Deprecated | Superseded]
**Date:** [YYYY-MM-DD]
**Decision Makers:** [List key stakeholders]
**Consulted:** [Teams or individuals consulted]

## Context and Problem Statement

[Describe the context and the problem that needs solving. What forces are at play?
What are the business or technical drivers? What constraints exist?]

## Decision Drivers

* [Driver 1 - e.g., Performance requirements]
* [Driver 2 - e.g., Team expertise]
* [Driver 3 - e.g., Budget constraints]
* [Driver 4 - e.g., Time to market]

## Considered Options

* [Option 1]
* [Option 2]
* [Option 3]

## Decision Outcome

**Chosen option:** "[Option X]", because [justification].

### Positive Consequences

* [Benefit 1]
* [Benefit 2]
* [Benefit 3]

### Negative Consequences

* [Drawback 1]
* [Drawback 2]
* [Mitigation strategy]

## Pros and Cons of the Options

### [Option 1]

**Description:** [Brief description]

**Pros:**
* [Pro 1]
* [Pro 2]

**Cons:**
* [Con 1]
* [Con 2]

### [Option 2]

**Description:** [Brief description]

**Pros:**
* [Pro 1]
* [Pro 2]

**Cons:**
* [Con 1]
* [Con 2]

## Links and References

* [Link to related ADRs]
* [Technical documentation]
* [Research or blog posts that influenced the decision]
```

---

## Recording Technical Decisions: The Process

### Step 1: Identify the Decision Point
- Recognize when you're at a crossroads
- Articulate the problem clearly
- Understand the urgency and impact

### Step 2: Gather Context
- Business requirements and constraints
- Technical constraints (existing systems, skills, infrastructure)
- Non-functional requirements (performance, security, scalability)
- Stakeholder concerns and priorities

### Step 3: Research Options
- Brainstorm alternatives (aim for 3-5 options)
- Research each option thoroughly
- Consult with experts and stakeholders
- Document assumptions and unknowns

### Step 4: Evaluate Trade-offs
- Use decision matrices or scoring systems
- Consider short-term vs. long-term implications
- Assess risks and mitigation strategies
- Validate against decision drivers

### Step 5: Make and Document the Decision
- Choose the option that best fits the context
- Document the decision using the ADR template
- Explain why rejected options weren't chosen
- Get stakeholder review and sign-off

### Step 6: Communicate and Archive
- Share with relevant teams
- Store in version control with the codebase
- Update as the decision evolves
- Reference in related documentation

---

## Explaining Rejected Options

### Why This Matters
Explaining rejected options shows:
- You considered alternatives (not just your favorite)
- You understand trade-offs
- You respect dissenting opinions
- Your decision-making is defensible

### How to Document Rejected Options

**Be Respectful:**
```markdown
### PostgreSQL (Rejected)

While PostgreSQL offers excellent ACID compliance and is familiar to our team,
we rejected this option because our access patterns are primarily key-value
lookups with extreme read scalability requirements (10M+ reads/sec). The
relational features would go unused while we'd struggle with horizontal
scaling beyond what our projected growth demands.
```

**Be Specific:**
```markdown
### GraphQL API (Rejected)

GraphQL would provide clients flexible querying capabilities. However:
- Our mobile app has well-defined, stable data requirements
- The team lacks GraphQL experience (6-month learning curve estimated)
- Over-fetching isn't a performance issue in our current REST API
- Added complexity outweighs benefits for our use case
```

**Show You Did Your Homework:**
```markdown
### Kubernetes (Rejected)

We extensively evaluated Kubernetes for container orchestration:
- Conducted 2-week POC with sample services
- Consulted with 3 teams already using it
- Estimated 4 months to achieve production readiness

Decision: The operational complexity and required expertise exceed our
team's current capabilities. AWS ECS provides sufficient orchestration
for our scale (20 services) with less operational overhead. We'll
revisit Kubernetes when we reach 50+ services or need advanced features.
```

---

## Context and Consequences

### Capturing Context Effectively

**Good Context Section:**
```markdown
## Context and Problem Statement

Our e-commerce platform currently uses a monolithic Rails application serving
100K daily active users. Recent business growth projections indicate 5x growth
over 18 months. Current pain points:

- Deploy time: 45 minutes (blocks all feature releases)
- Team coordination: 15 engineers stepping on each other
- Scaling: Can't independently scale checkout vs. catalog browsing
- Innovation velocity: New payment providers take 3 months to integrate

We need to improve deployment frequency from weekly to daily while supporting
the engineering team expansion from 15 to 40 people.

Constraints:
- Budget: $200K for migration
- Timeline: MVP in 6 months
- Team: Current team has Ruby expertise, limited microservices experience
- Business: Cannot have downtime during holiday season (Nov-Dec)
```

### Documenting Consequences

**Honest Consequences:**
```markdown
## Decision Outcome

**Chosen option:** "Strangler Fig Pattern migration to microservices"

### Positive Consequences

* Parallel development: Multiple teams can work independently
* Deployment frequency: Can achieve daily deploys for new services
* Technology flexibility: Can use optimal tech stack per service
* Scaling efficiency: Can scale services based on actual load
* Incremental migration: Reduces risk vs. big-bang rewrite

### Negative Consequences

* Increased operational complexity: Now managing 8 services vs. 1 app
  - **Mitigation:** Invest in centralized logging and monitoring upfront

* Distributed debugging challenges: Tracing requests across services
  - **Mitigation:** Implement distributed tracing (Jaeger) from day 1

* Data consistency complexity: Eventual consistency vs. ACID transactions
  - **Mitigation:** Carefully design service boundaries along transactional boundaries

* Team learning curve: Microservices patterns, containers, service mesh
  - **Mitigation:** Dedicated training program + hire 2 senior engineers with experience

* Migration timeline risk: 6 months is aggressive
  - **Mitigation:** Define clear MVP scope (3 services: auth, checkout, inventory)
```

---

## Examples of Good ADRs

### Example 1: Database Selection

```markdown
# ADR-015: Selection of Time-Series Database for IoT Platform

**Status:** Accepted
**Date:** 2025-11-15
**Decision Makers:** Principal Engineer (Data), Engineering Manager, VP Engineering
**Consulted:** DevOps team, Data Analytics team

## Context and Problem Statement

Our IoT platform ingests sensor data from 50,000 devices, generating 500K data
points per second. Current PostgreSQL solution is struggling:

- Write latency: 500ms (SLA is 100ms)
- Query performance: Aggregations take 30+ seconds
- Storage costs: $15K/month for 1 year of data
- Retention: Need 5 years for compliance

We need a purpose-built time-series database that can scale to 1M devices
(projected in 24 months) while reducing costs and improving performance.

## Decision Drivers

* Write throughput: Must handle 1M+ points/second
* Query performance: Aggregations under 1 second
* Cost efficiency: Target 50% cost reduction
* Operational simplicity: Small DevOps team (3 people)
* Data retention: 5 years with automatic downsampling
* Team learning curve: Must be productive within 1 month

## Considered Options

* TimescaleDB (PostgreSQL extension)
* InfluxDB Enterprise
* Amazon Timestream
* Apache Cassandra + custom time-series layer

## Decision Outcome

**Chosen option:** "TimescaleDB", because it provides the best balance of
performance, PostgreSQL compatibility, and team familiarity.

### Positive Consequences

* Leverages existing PostgreSQL expertise (team knows SQL)
* Native compression reduces storage costs by 60%
* Continuous aggregates eliminate long-running queries
* Can use existing PostgreSQL tools (pgAdmin, backup tools)
* Excellent documentation and community support
* Easy integration with existing dashboards (Grafana)

### Negative Consequences

* Still requires PostgreSQL operational knowledge at scale
  - **Mitigation:** Training on TimescaleDB-specific tuning

* Limited managed service options vs. InfluxDB Cloud
  - **Mitigation:** Use AWS RDS for PostgreSQL with TimescaleDB extension

* Requires migration from existing PostgreSQL schema
  - **Mitigation:** 3-phase migration plan with parallel write period

## Pros and Cons of the Options

### TimescaleDB

**Description:** PostgreSQL extension optimized for time-series data

**Pros:**
* Team already knows PostgreSQL/SQL
* Automatic partitioning by time
* Native compression (90% space savings)
* Continuous aggregates for fast queries
* Can use standard PostgreSQL tools
* Active development and community

**Cons:**
* PostgreSQL operational complexity at scale
* Not as purpose-built as dedicated TS databases
* Requires careful tuning for optimal performance

### InfluxDB Enterprise

**Description:** Purpose-built time-series database

**Pros:**
* Excellent write performance (1M+ points/sec)
* Purpose-built for time-series workloads
* Flux query language optimized for time-series
* Built-in downsampling and retention policies
* Lower resource usage for pure time-series

**Cons:**
* Team needs to learn InfluxQL/Flux (new query language)
* Enterprise license costs ($12K/year)
* Less mature ecosystem vs. PostgreSQL
* Limited JOIN capabilities for relational data
* Separate database from our existing PostgreSQL

### Amazon Timestream

**Description:** Fully managed AWS time-series database

**Pros:**
* Fully managed (minimal operational overhead)
* Automatic scaling
* Integrated with AWS ecosystem
* Pay-per-query pricing model

**Cons:**
* Vendor lock-in to AWS
* Newer service with less community knowledge
* Query language learning curve
* Costs hard to predict with pay-per-query model
* Limited tuning options (managed service trade-off)

### Apache Cassandra

**Description:** Distributed database with custom time-series modeling

**Pros:**
* Proven at massive scale
* Excellent write performance
* Multi-datacenter replication

**Cons:**
* Requires extensive custom application code
* Team has no Cassandra experience (6+ month ramp)
* Complex operational requirements
* Over-engineered for current 50K device scale
* Time-series queries require careful data modeling

## Implementation Plan

**Phase 1 (Weeks 1-2):**
- Set up TimescaleDB on staging environment
- Migrate schema with hypertables
- Benchmark performance with production-like data

**Phase 2 (Weeks 3-4):**
- Implement parallel writes (PostgreSQL + TimescaleDB)
- Backfill historical data (30 days)
- Validate data consistency

**Phase 3 (Weeks 5-6):**
- Switch reads to TimescaleDB
- Monitor performance for 1 week
- Decommission old tables

## Links and References

* [TimescaleDB Benchmark Results](internal-wiki/timescale-benchmark)
* [Cost Analysis Spreadsheet](drive/timeseries-cost-analysis)
* [Migration Runbook](confluence/timescale-migration)
* [Related: ADR-012 IoT Data Retention Policy]
```

---

### Example 2: Architecture Pattern Choice

```markdown
# ADR-008: Event-Driven Architecture for Order Processing

**Status:** Accepted
**Date:** 2025-09-22
**Decision Makers:** Staff Engineer, Engineering Manager (Checkout), CTO
**Consulted:** Platform team, Product team, Customer Support

## Context and Problem Statement

Our order processing system currently uses synchronous REST APIs for workflow:
1. Order created → REST call → Inventory service
2. Inventory reserved → REST call → Payment service
3. Payment processed → REST call → Fulfillment service
4. Fulfillment confirmed → REST call → Notification service

Problems with current approach:
- **Tight coupling:** Failure in any downstream service blocks the entire order
- **Timeout issues:** End-to-end order creation takes 8-12 seconds (p95)
- **Poor user experience:** Customers wait for all steps before confirmation
- **Retry complexity:** Manual retry logic in each service
- **No audit trail:** Hard to reconstruct order state changes

Business impact:
- 3% cart abandonment due to slow checkout
- $450K annual revenue loss
- Customer support spends 15 hours/week on "where's my order?"

## Decision Drivers

* User experience: Order confirmation under 2 seconds
* Reliability: Single service failure shouldn't block orders
* Scalability: Handle Black Friday traffic (10x normal load)
* Auditability: Complete history of order state changes
* Team autonomy: Services can deploy independently
* Cost: Minimize infrastructure costs

## Considered Options

* Event-Driven Architecture with message queue
* Saga pattern with orchestration
* Continue with synchronous REST + improvements
* Hybrid: Async for non-critical, sync for critical

## Decision Outcome

**Chosen option:** "Event-Driven Architecture with RabbitMQ", because it
provides the best balance of decoupling, reliability, and team familiarity.

### Positive Consequences

* Fast user feedback: Orders confirmed in <1 second
* Service independence: Each service processes events at its own pace
* Natural retry mechanism: Failed events reprocessed automatically
* Complete audit trail: Every event stored in order history
* Scalability: Can add consumers to handle load spikes
* Team autonomy: Services subscribe to events they care about

### Negative Consequences

* Eventual consistency: Order state not immediately consistent
  - **Mitigation:** Clear user messaging about processing stages
  - **Mitigation:** Status page for customers to track orders

* Debugging complexity: Tracing events across services
  - **Mitigation:** Correlation IDs in every event
  - **Mitigation:** Centralized logging with event flow visualization

* Message queue operational overhead: New infrastructure to manage
  - **Mitigation:** Use AWS managed RabbitMQ (Amazon MQ)

* Duplicate event handling: Need idempotency
  - **Mitigation:** Idempotency keys in all event handlers

* Learning curve: Team new to event-driven patterns
  - **Mitigation:** 2-week training program + event-driven playbook

## Pros and Cons of the Options

### Event-Driven Architecture (RabbitMQ)

**Description:** Services publish events to message broker, consumers process asynchronously

**Pros:**
* Services completely decoupled
* Natural async processing
* Built-in retry with dead-letter queues
* Team has some RabbitMQ experience
* Message persistence ensures no data loss
* Can replay events for debugging

**Cons:**
* Eventual consistency challenges
* New operational complexity (message broker)
* Requires idempotent event handlers
* Debugging distributed flows is harder

### Saga Pattern with Orchestration

**Description:** Central orchestrator manages order workflow with compensating transactions

**Pros:**
* Clear workflow visibility (one place to see all steps)
* Easy to implement complex business logic
* Transaction-like behavior with compensations
* Consistent error handling

**Cons:**
* Orchestrator becomes single point of failure
* Orchestrator can become complex (God service)
* Still requires async communication
* Less service autonomy (orchestrator controls workflow)
* Team unfamiliar with saga patterns

### Synchronous REST + Improvements

**Description:** Keep current architecture but optimize with caching, circuit breakers, faster APIs

**Pros:**
* No architectural change (low risk)
* Team already familiar
* Debugging easier (synchronous flow)
* Consistent state (no eventual consistency)

**Cons:**
* Doesn't solve fundamental coupling issues
* Still blocked by downstream failures
* Hard to achieve <2 second order creation
* Limited scalability improvements
* Doesn't address audit trail needs

### Hybrid Approach

**Description:** Sync for critical path (payment), async for non-critical (notifications)

**Pros:**
* Incremental adoption of async patterns
* Lower risk than full architectural change
* Faster user feedback for non-critical steps

**Cons:**
* Two patterns to maintain (complexity)
* Still has coupling for critical path
* Partial solution to the problem
* Team manages both patterns

## Implementation Plan

**Phase 1 - Foundation (Month 1):**
- Set up Amazon MQ (managed RabbitMQ)
- Define event schemas and versioning strategy
- Build shared event library
- Create monitoring dashboards

**Phase 2 - Pilot Service (Month 2):**
- Migrate notification service to events (lowest risk)
- Validate event flow and monitoring
- Refine patterns and best practices
- Team training based on real implementation

**Phase 3 - Core Services (Months 3-4):**
- Migrate inventory service
- Migrate fulfillment service
- Parallel run with existing REST calls
- Validate data consistency

**Phase 4 - Complete Migration (Month 5):**
- Migrate payment service
- Remove old REST endpoints
- Full event-driven order processing
- Performance validation

## Success Metrics

* Order confirmation time: <2 seconds (p95)
* Order completion rate: >99.5%
* Customer support inquiries: Reduce by 50%
* Service independence: Each service can deploy without coordination

## Links and References

* [Event Schema Repository](github/order-events)
* [RabbitMQ Architecture Diagram](miro/event-driven-architecture)
* [Event-Driven Best Practices Playbook](confluence/event-driven-playbook)
* [Related: ADR-006 API Gateway Pattern]
* [Related: ADR-010 Service Mesh Evaluation]
```

---

### Example 3: Technology Stack Decision

```markdown
# ADR-021: Frontend Framework Selection for Dashboard Rewrite

**Status:** Accepted
**Date:** 2025-12-01
**Decision Makers:** Frontend Lead, Product Manager, Engineering Director
**Consulted:** Frontend team (8 engineers), UX team, Platform team

## Context and Problem Statement

Our analytics dashboard is built with AngularJS (v1.6), which reached end-of-life
in 2021. Current problems:

- **Maintenance burden:** Finding AngularJS developers is increasingly difficult
- **Performance:** Dashboard is slow with large datasets (10K+ rows)
- **Modern features:** Can't use modern browser APIs and tooling
- **Technical debt:** 4 years of patches on unmaintained framework
- **Recruitment:** New hires resist working with legacy stack

Business context:
- Dashboard is critical product (used by 90% of customers daily)
- Competitive pressure to add real-time features
- Product roadmap includes mobile version in 12 months

We need to rewrite the dashboard with a modern framework that will serve us
for the next 5+ years while minimizing rewrite time (target: 6 months).

## Decision Drivers

* Developer productivity: Fast iteration on new features
* Recruitment: Attract and retain frontend talent
* Performance: Handle 50K+ row datasets smoothly
* Ecosystem: Rich component libraries and tooling
* Learning curve: Team can become productive quickly
* Community: Active community and long-term viability
* TypeScript support: Type safety is non-negotiable
* Testing: Comprehensive testing tools
* Mobile: Can reuse code for mobile version

## Considered Options

* React with TypeScript
* Vue 3 with TypeScript
* Angular (modern, v17+)
* Svelte with TypeScript

## Decision Outcome

**Chosen option:** "React with TypeScript", because it offers the best
combination of team familiarity, ecosystem maturity, and recruitment advantages.

### Positive Consequences

* Huge ecosystem: Vast component libraries and tooling
* Team familiarity: 4/8 frontend engineers have React experience
* Recruitment: Largest talent pool of any framework
* Mobile reuse: Can use React Native for mobile app
* Performance: Virtual DOM + optimization tools handle large datasets
* Community: Largest community, most Stack Overflow answers
* Corporate backing: Meta's continued investment provides stability
* TypeScript integration: Excellent TypeScript support

### Negative Consequences

* Frequent updates: React ecosystem changes rapidly
  - **Mitigation:** Lock dependency versions, quarterly update cycles
  - **Mitigation:** Comprehensive test suite to catch regressions

* Decision fatigue: Many ways to solve the same problem
  - **Mitigation:** Create frontend architecture playbook
  - **Mitigation:** Define opinionated starter template

* Bundle size: Can become large without careful management
  - **Mitigation:** Use code splitting from day 1
  - **Mitigation:** Bundle size budgets in CI pipeline

* Learning curve: Hooks, context, patterns take time
  - **Mitigation:** 2-week React training for all engineers
  - **Mitigation:** Pair programming for first month

## Pros and Cons of the Options

### React with TypeScript

**Description:** JavaScript library for building UIs, backed by Meta

**Pros:**
* Largest ecosystem and community
* 4/8 team members have experience
* Excellent TypeScript support
* React Native for mobile reuse
* Mature tooling (Create React App, Next.js)
* Virtual DOM performance optimizations
* Huge component library ecosystem (MUI, Ant Design)
* Best recruitment prospects

**Cons:**
* Rapid ecosystem changes
* Many competing patterns and libraries
* Requires decisions on state management, routing, etc.
* Bundle sizes can be large

**Team Vote:** 6/8 preferred React

### Vue 3 with TypeScript

**Description:** Progressive JavaScript framework for building UIs

**Pros:**
* Excellent documentation
* Gentle learning curve
* Built-in state management (Pinia)
* Good TypeScript support in Vue 3
* Composition API similar to React Hooks
* Smaller bundle sizes than React
* Official router and state management

**Cons:**
* Smaller ecosystem than React
* Harder recruitment (smaller talent pool)
* 1/8 team members have experience
* Less mature mobile story (Vue Native experimental)
* Smaller community than React

**Team Vote:** 1/8 preferred Vue

### Angular (v17+)

**Description:** Full-featured TypeScript framework from Google

**Pros:**
* TypeScript-first (built with TypeScript)
* Comprehensive (everything built-in)
* Strong opinions reduce decisions
* Excellent for large teams
* Best CLI tooling
* Familiar to AngularJS team (similar concepts)
* Strong enterprise adoption

**Cons:**
* Steepest learning curve
* Most verbose code
* Heaviest framework
* Team has AngularJS fatigue
* No mobile reuse story
* Harder recruitment than React

**Team Vote:** 1/8 preferred Angular

### Svelte with TypeScript

**Description:** Compiler-based framework that shifts work to build time

**Pros:**
* Smallest bundle sizes
* Fastest runtime performance
* Simplest code (least boilerplate)
* True reactivity (no virtual DOM)
* Growing community
* TypeScript support improving

**Cons:**
* Smallest ecosystem (fewest libraries)
* Newest framework (least mature)
* No team experience
* Hardest recruitment
* No clear mobile story
* Fewer learning resources

**Team Vote:** 0/8 preferred Svelte

## Technology Stack Details

**Core Stack:**
- React 18 with TypeScript
- Vite (build tool)
- React Router v6
- TanStack Query (data fetching)
- Zustand (state management)
- MUI (component library)
- Vitest + React Testing Library

**Rationale:**
- **Vite over Create React App:** 10x faster builds, better DX
- **TanStack Query:** Best data fetching/caching library
- **Zustand over Redux:** Simpler API, less boilerplate
- **MUI:** Mature, accessible, customizable components
- **Vitest:** Faster than Jest, better Vite integration

## Migration Strategy

**Strangler Fig Pattern:** Incremental rewrite alongside AngularJS app

**Phase 1 (Months 1-2): Foundation**
- Set up React app with routing
- Create shared component library
- Build authentication integration
- Deploy empty shell to production (behind feature flag)

**Phase 2 (Months 3-4): Core Features**
- Migrate 3 most-used dashboard pages
- Run A/B test with 10% of users
- Gather performance metrics and feedback
- Iterate based on learnings

**Phase 3 (Months 5-6): Complete Migration**
- Migrate remaining pages
- Deprecate AngularJS app
- Full rollout to all users
- Remove AngularJS code

## Success Metrics

* Development velocity: Ship features 2x faster
* Performance: Dashboard load time under 2 seconds
* Bundle size: Under 200KB gzipped
* Test coverage: >80% coverage
* Recruitment: Reduce time-to-hire by 30%
* Developer satisfaction: Team NPS >8/10

## Links and References

* [React Architecture Playbook](confluence/react-playbook)
* [Component Library Storybook](storybook-url)
* [Performance Benchmarks](internal-wiki/framework-benchmarks)
* [Migration Plan Details](miro/dashboard-migration)
* [Team Survey Results](drive/framework-survey)
```

---

### Example 4: Migration Strategy Decision

```markdown
# ADR-018: Cloud Migration Strategy - Lift-and-Shift vs. Refactor

**Status:** Accepted
**Date:** 2025-10-10
**Decision Makers:** Cloud Architect, VP Engineering, CTO, CFO
**Consulted:** DevOps team, Security team, Finance, all engineering teams

## Context and Problem Statement

Our on-premise datacenter contract expires in 18 months. We must migrate 45
applications to AWS. Current infrastructure:

- 120 VMs across 3 datacenters
- 30TB of data across various databases
- Mix of technologies: Java, .NET, Python, legacy Perl
- Some applications 10+ years old with no original developers
- Compliance requirements: HIPAA, SOC2

Business drivers:
- Datacenter costs: $850K/year
- Scalability limitations: Can't handle traffic spikes
- Disaster recovery: Current RPO is 24 hours (target: 1 hour)
- Innovation: Limited ability to adopt modern cloud services

We need to decide: Fast migration (lift-and-shift) or optimal migration (refactor)?

## Decision Drivers

* Timeline: Must complete before datacenter contract expires
* Cost: Migration budget is $2M
* Risk: Cannot disrupt business operations
* Technical debt: Opportunity to address vs. carry forward
* Team capacity: 20 engineers, other work can't stop
* Skills: Team has limited AWS experience
* Compliance: Must maintain certifications throughout

## Considered Options

* Pure lift-and-shift (rehost all to EC2)
* Pure refactor (cloud-native rewrite)
* Hybrid approach (lift-and-shift with selective refactor)
* Phased approach (lift-and-shift now, refactor later)

## Decision Outcome

**Chosen option:** "Hybrid approach - lift-and-shift with selective refactor",
because it balances timeline constraints with strategic modernization.

### Strategy:

**Lift-and-Shift (30 applications):**
- Legacy apps with low change frequency
- Applications with no original developers
- Simple apps without cloud-native needs
- Target: 6 months, minimal changes

**Refactor (10 applications):**
- Customer-facing apps (high business value)
- Apps with known scalability issues
- Apps with active development
- Target: 12 months, cloud-native patterns

**Retire (5 applications):**
- Redundant or unused applications
- Replace with SaaS alternatives

### Positive Consequences

* Meet timeline: Can complete before datacenter contract expires
* Risk management: Most apps use low-risk lift-and-shift
* Strategic value: Modernize most important applications
* Cost optimization: Focus refactoring budget where it matters
* Learning opportunity: Team learns cloud-native on high-value apps
* Quick wins: Early migrations build momentum and confidence

### Negative Consequences

* Technical debt carried forward: 30 apps not optimized for cloud
  - **Mitigation:** Create 24-month roadmap for future optimization
  - **Mitigation:** Use auto-scaling groups even for lifted apps

* Two migration patterns: Team must learn both approaches
  - **Mitigation:** Dedicated playbooks for each pattern
  - **Mitigation:** Specialized sub-teams for each approach

* Refactored apps take longer: May delay some migrations
  - **Mitigation:** Start refactoring early (month 1)
  - **Mitigation:** Lift-and-shift as fallback if refactor at risk

* Cloud costs: Won't achieve full cloud cost optimization
  - **Mitigation:** Right-size all VMs during migration
  - **Mitigation:** Use reserved instances for predictable workloads

## Detailed Analysis: Lift-and-Shift Applications (30)

**Criteria for lift-and-shift:**
- Low business criticality
- Infrequent code changes (<1 deploy/quarter)
- No scalability requirements
- No original developers available
- Simple architecture (monolith or simple n-tier)

**Examples:**
- Internal HR portal (Java monolith)
- Finance reporting tool (legacy .NET)
- Archive document system (read-only)

**Migration approach:**
1. Create AWS account structure
2. Set up networking (VPC, subnets, VPN)
3. Use AWS Application Migration Service (MGN)
4. Test in staging environment
5. Migrate during maintenance window
6. Run in parallel for 1 week
7. Cutover DNS

**Timeline:** 2 applications per month = 15 months

**Cost:** ~$1.2M (tooling, team time, initial AWS costs)

## Detailed Analysis: Refactor Applications (10)

**Criteria for refactoring:**
- Customer-facing (revenue-generating)
- Active development (>2 deploys/week)
- Known scalability or performance issues
- Security or compliance enhancements needed
- Team available with application knowledge

**Examples:**
- E-commerce platform (monolith → microservices)
- Mobile API gateway (EC2 → Lambda + API Gateway)
- Analytics pipeline (cron jobs → Step Functions)

**Refactoring patterns:**
- Containerize with ECS/EKS
- Serverless where appropriate (Lambda, DynamoDB)
- Managed databases (RDS, Aurora, DocumentDB)
- S3 for static assets
- CloudFront for CDN

**Timeline:** Start month 1, complete by month 12

**Cost:** ~$800K (larger team effort, more testing, training)

## Detailed Analysis: Retire Applications (5)

**Criteria for retirement:**
- <100 active users
- Functionality available in other systems
- Cheaper SaaS alternatives exist

**Examples:**
- Legacy wiki → Confluence
- Custom chat tool → Slack
- Old monitoring → Datadog

**Timeline:** Month 1-3 (early wins)

**Cost savings:** ~$120K/year operational savings

## Pros and Cons of the Options

### Pure Lift-and-Shift

**Description:** Migrate all apps to EC2 with minimal changes

**Pros:**
* Fastest migration (12 months total)
* Lowest risk (minimal application changes)
* Team can execute with limited AWS knowledge
* Lower upfront cost ($1.5M)

**Cons:**
* Carries all technical debt to cloud
* Doesn't leverage cloud-native benefits
* Higher long-term costs (inefficient resource usage)
* Missed opportunity for modernization
* Team doesn't learn cloud-native patterns

### Pure Refactor

**Description:** Rewrite all apps as cloud-native

**Pros:**
* Optimal cloud architecture
* Maximum cost efficiency long-term
* Best performance and scalability
* Addresses all technical debt
* Modern development practices

**Cons:**
* Can't meet 18-month deadline (estimated 36+ months)
* Highest risk (all apps changing)
* Highest cost ($4M+)
* Requires extensive cloud-native expertise
* Business disruption during rewrites

### Hybrid Approach (CHOSEN)

**Description:** Strategic mix of lift-and-shift and refactor

**Pros:**
* Meets timeline (18 months)
* Balances risk and reward
* Focuses modernization on high-value apps
* Team learns cloud-native on manageable scope
* Reasonable budget ($2M)

**Cons:**
* Some technical debt carried forward
* Two migration patterns to manage
* Requires prioritization decisions

### Phased Approach

**Description:** Lift-and-shift everything now, refactor later

**Pros:**
* Fastest datacenter exit
* Clear separation of concerns
* Simplest execution

**Cons:**
* Double migration cost for refactored apps
* Team loses momentum after lift-and-shift
* Harder to justify refactoring later
* Opportunity cost of delayed modernization

## Application Categorization

| Category | Count | Strategy | Timeline | Priority |
|----------|-------|----------|----------|----------|
| Customer-facing, high-traffic | 5 | Refactor | Months 1-12 | P0 |
| Internal, business-critical | 10 | Lift-and-shift | Months 3-10 | P0 |
| Customer-facing, low-traffic | 5 | Refactor | Months 6-12 | P1 |
| Internal, legacy | 20 | Lift-and-shift | Months 6-15 | P1 |
| Retire/replace | 5 | Retire | Months 1-3 | P2 |

## Risk Mitigation

**Risk: Timeline slippage**
- Mitigation: Start high-risk refactoring in month 1
- Mitigation: Fallback to lift-and-shift if refactoring behind schedule
- Mitigation: Monthly steering committee reviews

**Risk: Cost overruns**
- Mitigation: Monthly cost tracking vs. budget
- Mitigation: Reserved instances for predictable workloads
- Mitigation: Auto-scaling to prevent over-provisioning

**Risk: Compliance violations**
- Mitigation: AWS compliance frameworks (HIPAA, SOC2)
- Mitigation: Security review before each migration
- Mitigation: Continuous compliance monitoring

**Risk: Data loss during migration**
- Mitigation: Replicate data before cutover
- Mitigation: Run in parallel for validation period
- Mitigation: Keep on-premise backups for 90 days

**Risk: Team knowledge gaps**
- Mitigation: AWS training for all engineers (months 1-2)
- Mitigation: Bring in AWS consultant for first 3 months
- Mitigation: Create migration playbooks and runbooks

## Success Metrics

* Timeline: Complete by month 18 (before datacenter contract end)
* Budget: Stay within $2M
* Uptime: <4 hours total downtime across all migrations
* Cost reduction: Achieve 20% infrastructure cost reduction year 1
* Compliance: Maintain HIPAA and SOC2 throughout
* Team satisfaction: >7/10 NPS on migration experience

## Links and References

* [Application Inventory](spreadsheet/app-inventory)
* [Migration Playbook - Lift-and-Shift](confluence/lift-and-shift-playbook)
* [Migration Playbook - Refactor](confluence/refactor-playbook)
* [AWS Landing Zone Architecture](diagram/aws-landing-zone)
* [Cost Model](spreadsheet/cloud-cost-model)
* [Related: ADR-016 AWS Account Structure]
* [Related: ADR-019 Disaster Recovery Strategy]
```

---

## How to Present ADRs in Interviews

### The STAR Format for ADRs

**Situation:**
"At my previous company, we were scaling rapidly and our monolith deployment was taking 45 minutes, blocking all releases."

**Task:**
"As the lead architect, I needed to decide on an architecture that would enable daily deployments for our growing team of 40 engineers."

**Action:**
"I created an ADR to evaluate our options. I researched microservices, modular monolith, and improved CI/CD. I consulted with 5 teams, created a decision matrix based on our constraints—budget, timeline, team expertise—and documented trade-offs for each option."

**Result:**
"We chose a strangler fig pattern to gradually extract microservices. The ADR helped align stakeholders and serves as onboarding material. Six months in, we've achieved daily deployments and reduced coordination overhead by 60%."

### Interview Questions You Can Answer with ADRs

**"Tell me about a time you made a difficult technical decision."**
- Walk through a specific ADR
- Emphasize the decision process, not just the outcome
- Show how you considered multiple perspectives

**"How do you handle technical disagreements?"**
- Describe using ADRs to create objective evaluation criteria
- Show how documenting options defuses emotional debates
- Explain how stakeholders were consulted and aligned

**"Describe your decision-making process."**
- Use your ADR template as your framework
- Emphasize systematic evaluation over gut feelings
- Show you balance analysis with action

**"Give an example of a decision you made that didn't work out."**
- Show an ADR where assumptions proved wrong
- Explain how you updated the ADR (superseded status)
- Demonstrate learning and adaptation

### Key Phrases That Demonstrate Maturity

- "I documented the decision in an ADR to preserve the context..."
- "We evaluated three options against our decision drivers..."
- "I consulted with stakeholders from security, DevOps, and product..."
- "We explicitly called out the negative consequences and mitigation strategies..."
- "The ADR helped onboard new team members who joined six months later..."
- "When requirements changed, we created a new ADR that superseded the original..."

---

## Decision-Making Frameworks

### Framework 1: Decision Matrix

Use when you have multiple options and clear evaluation criteria.

**Example:**

| Criteria (Weight) | React (Option A) | Vue (Option B) | Angular (Option C) |
|-------------------|------------------|----------------|-------------------|
| Team familiarity (20%) | 8 (1.6) | 3 (0.6) | 4 (0.8) |
| Ecosystem (15%) | 10 (1.5) | 7 (1.05) | 8 (1.2) |
| Performance (15%) | 8 (1.2) | 9 (1.35) | 7 (1.05) |
| Recruitment (20%) | 10 (2.0) | 5 (1.0) | 6 (1.2) |
| Learning curve (10%) | 6 (0.6) | 9 (0.9) | 4 (0.4) |
| TypeScript support (10%) | 8 (0.8) | 8 (0.8) | 10 (1.0) |
| Mobile reuse (10%) | 10 (1.0) | 3 (0.3) | 2 (0.2) |
| **Total** | **8.7** | **5.0** | **5.85** |

**Winner:** React (8.7)

**How to use in interview:**
"I created a decision matrix with weighted criteria. Team familiarity and recruitment were weighted at 20% each because we needed to move fast and hire. React scored highest at 8.7, primarily due to our team's existing knowledge and the large talent pool."

---

### Framework 2: Trade-off Sliders

Use when you need to visualize competing priorities.

```
Fast Delivery <-----------|----------> Perfect Architecture
                          ^
                     Our position

Low Cost <------------------|--------> High Quality
                                ^
                          Our position

Proven Tech <------|-------------------> Innovative Tech
                   ^
              Our position
```

**How to use in interview:**
"I used trade-off sliders to align stakeholders on priorities. Given our 6-month deadline and limited budget, we positioned toward 'Fast Delivery' and 'Proven Tech', which led us to choose managed services over building custom solutions."

---

### Framework 3: Pre-mortem Analysis

Imagine the decision failed spectacularly. Work backwards to identify risks.

**Template:**
```markdown
## Pre-mortem: Choosing Microservices

"It's 18 months from now. Our microservices migration was a disaster. What went wrong?"

**Scenario 1: Distributed monolith**
- Cause: Poor service boundaries
- Prevention: Domain-driven design workshops before splitting

**Scenario 2: Team overwhelmed**
- Cause: Operational complexity too high
- Prevention: Invest in observability and automation upfront

**Scenario 3: Performance degradation**
- Cause: Network latency between services
- Prevention: Performance testing early, colocate chatty services

**Scenario 4: Data consistency issues**
- Cause: Distributed transactions not handled
- Prevention: Design service boundaries along transactional boundaries
```

**How to use in interview:**
"Before committing to microservices, I ran a pre-mortem exercise with the team. We identified 'distributed monolith' as our biggest risk, which led us to invest in domain-driven design workshops before splitting any services. This prevented the most common microservices pitfall."

---

### Framework 4: Cost-Benefit Analysis

Quantify the impact when possible.

**Template:**
```markdown
## Cost-Benefit: Migrating to TimescaleDB

### Costs
**One-time:**
- Migration effort: 300 engineer-hours = $60K
- Training: $15K
- Consultant: $30K
- **Total one-time: $105K**

**Recurring:**
- Licensing: $0 (open source)
- Infrastructure: +$5K/year (better compression = less storage)
- **Total recurring: +$5K/year**

### Benefits
**One-time:**
- None

**Recurring:**
- Storage cost savings: $90K/year (60% reduction)
- Query performance: 30x faster = $40K/year (reduced compute)
- Developer productivity: 20% faster = $50K/year
- **Total recurring: $180K/year**

### ROI
- Payback period: 7 months ($105K / $15K per month)
- 3-year NPV: $435K
- **Decision: Strong financial case**
```

**How to use in interview:**
"I built a cost-benefit analysis showing a 7-month payback period and $435K three-year NPV. This made the decision clear and helped secure budget approval from the CFO."

---

### Framework 5: Reversibility Assessment

Evaluate how easy it is to change your mind.

**Questions:**
- Can we reverse this decision? At what cost?
- What's locked in (vendor, contracts, training)?
- Can we run both options in parallel?
- What's the switching cost in 1 year? 3 years?

**Categories:**
- **One-way door:** Irreversible or expensive to reverse → Analyze deeply
- **Two-way door:** Easy to reverse → Decide quickly and learn

**Example:**
```markdown
## Reversibility: Choosing AWS vs. Azure

**Switching cost (1 year):** Low
- Infrastructure as code (Terraform) supports both
- Minimal proprietary service usage
- Team knows both platforms

**Switching cost (3 years):** Medium
- Likely using AWS-specific services (SageMaker, etc.)
- Team expertise concentrated in AWS
- Estimated 6 months + $500K to switch

**Assessment:** This is a "becoming one-way door" decision
**Implication:** Must choose carefully but not perfectly
**Strategy:** Use multi-cloud abstractions for critical services
```

**How to use in interview:**
"I assessed reversibility before choosing AWS. While it started as a two-way door, I knew it would become one-way as we adopted more proprietary services. This led us to use Terraform and multi-cloud abstractions for critical components, reducing future lock-in."

---

## Trade-off Analysis Templates

### Template 1: Three-Column Trade-off

Simple template for quick decisions:

```markdown
| Option | Pros | Cons |
|--------|------|------|
| Option A | • Pro 1<br>• Pro 2<br>• Pro 3 | • Con 1<br>• Con 2 |
| Option B | • Pro 1<br>• Pro 2 | • Con 1<br>• Con 2<br>• Con 3 |
```

---

### Template 2: SWOT Analysis

Good for strategic decisions:

```markdown
## Option: Microservices

**Strengths:**
- Independent deployments
- Technology diversity
- Team autonomy

**Weaknesses:**
- Operational complexity
- Distributed debugging
- Eventual consistency

**Opportunities:**
- Scale teams independently
- Adopt new technologies gradually
- Improve deployment frequency

**Threats:**
- Team lacks microservices experience
- Distributed monolith risk
- Increased infrastructure costs
```

---

### Template 3: Now/Next/Later Framework

Good for phased decision-making:

```markdown
## Cloud Migration Strategy

**Now (0-6 months):**
- Decision: Lift-and-shift critical apps
- Why: Meet datacenter exit deadline
- Accept: Carry forward technical debt

**Next (6-18 months):**
- Decision: Refactor customer-facing apps
- Why: Optimize most valuable applications
- Accept: Running two patterns temporarily

**Later (18+ months):**
- Decision: Optimize remaining apps or replatform
- Why: Complete cloud-native transformation
- Accept: Extended timeline for full benefits
```

---

## Action Items for Today

### 1. Create Your Personal ADR Portfolio
Document 3-5 significant decisions you've made:
- Choose decisions with interesting trade-offs
- Use the standard ADR template
- Include context, options, and outcomes
- Update if decisions were later changed

### 2. Practice Presenting an ADR
Pick your best ADR and practice telling the story in 3 minutes:
- 30 seconds: Context and problem
- 90 seconds: Options and trade-offs
- 60 seconds: Decision and outcomes

### 3. Review Your Past Decisions
Reflect on a decision that didn't work out:
- What would you document differently?
- What did you learn?
- How would you present this in an interview?

### 4. Build Your Decision-Making Vocabulary
Memorize these phrases:
- "I documented this decision in an ADR..."
- "We evaluated options against these decision drivers..."
- "I consulted with these stakeholders..."
- "We explicitly called out these negative consequences..."
- "The pre-mortem helped us identify this risk..."

### 5. Create a Decision-Making Cheat Sheet
One page with:
- Your preferred ADR template
- Decision matrix example
- Trade-off analysis framework
- Key phrases for interviews

---

## Interview Scenarios to Practice

### Scenario 1: The Regretted Decision
**Question:** "Tell me about a technical decision you made that you later regretted."

**Good Answer Using ADR Approach:**
"I chose MongoDB for a financial transaction system. I created an ADR documenting why: flexible schema, fast writes, team familiarity. However, I underweighted ACID transaction requirements in my decision drivers. Six months in, we struggled with data consistency.

I documented this as a superseded ADR and created a new one for migrating to PostgreSQL. The original ADR became valuable—it showed new team members why MongoDB seemed right at the time and what we learned. In interviews, I now emphasize validating assumptions and weighting non-functional requirements properly."

---

### Scenario 2: The Stakeholder Alignment
**Question:** "How do you get buy-in for architectural decisions?"

**Good Answer Using ADR Approach:**
"I use Architecture Decision Records to create transparent, objective evaluation. For example, when choosing between microservices and modular monolith, I:

1. Consulted stakeholders early to identify decision drivers
2. Documented multiple options objectively
3. Created a decision matrix with weighted criteria
4. Ran a pre-mortem to identify risks
5. Shared the ADR for feedback before deciding

This process transformed a contentious debate into a collaborative decision. The ADR became our shared understanding, which we referenced during implementation when questions arose."

---

### Scenario 3: The Time Pressure
**Question:** "How do you make decisions when you don't have time for extensive analysis?"

**Good Answer Using ADR Approach:**
"I use the reversibility framework. I categorize decisions as one-way or two-way doors.

For two-way doors—like trying a new monitoring tool—I decide quickly with a lightweight ADR: context, options, quick evaluation, decision. I bias toward action and learning.

For one-way doors—like choosing a cloud provider—I invest in thorough ADRs even under time pressure. I timebox the analysis, focus on the most critical decision drivers, and document assumptions we're making due to time constraints.

Example: We had 2 weeks to choose a database. I created a decision matrix with 3 key criteria instead of 10, ran focused POCs, and documented our assumptions. The ADR included a 'Review in 3 months' note to validate our assumptions."

---

## Final Thoughts

ADRs are more than documentation—they're a reflection of your decision-making maturity. In interviews:

**Junior engineers** describe what they built.

**Senior engineers** describe why they made specific choices.

**Staff/Principal engineers** describe how they enabled good decision-making across teams.

By mastering ADRs, you demonstrate:
- Systematic thinking
- Stakeholder management
- Trade-off analysis
- Long-term thinking
- Communication clarity
- Leadership and ownership

Your ADR portfolio is evidence of your growth from implementer to architect to leader.

---

## Tomorrow's Preview: Day 23 - Production Failures & Postmortems

Tomorrow we'll cover how to discuss failures professionally, conduct root cause analysis, and turn disasters into growth stories. You'll learn to present production incidents as evidence of your resilience and learning ability.

**You've got this. Thoughtful decisions, clearly communicated, are your ticket to senior roles.**
