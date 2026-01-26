# Expansion for Sections 11-24 (Q&As b and c for each section)

## Section 11: Scalability Concerns (10x Growth) - Q11b & Q11c

**Q11b: You've scaled 10x but latency increased from 200ms to 1000ms. What caused it? How would you debug?**

Sample Answer:
- Database query bottleneck (missing index on new partition)
- Network latency (multi-region calls, not local)
- Cache miss ratio (Redis too small, 30% hit rate)
- Inefficient queries (N+1 problem with new features)
- Network congestion (bandwidth saturated)

Debugging approach:
- Application Insights: Query latency by service
- Database metrics: Query execution time, plan analysis
- Network: Trace latency per hop (CLI, Kubernetes metrics)
- Cache: Hit rate % (target 95%+)

Solution typically: Add indexes, cache more data, query optimization

---

**Q11c: After scaling, you have 3 regional clusters (US, EU, APAC). How would you handle data consistency across regions and coordinate distributed transactions?**

Sample Answer:
- Event sourcing + eventual consistency model
- Kafka multi-region replication (MirrorMaker)
- Database read replicas (replication lag 100-500ms acceptable)
- Distributed transactions: Saga pattern, not ACID across regions
- Conflict resolution: Last-write-wins, with versioning

Data flow:
- Primary region (US): Writes
- Secondary regions: Read-only replicas
- Analytics: Delayed aggregation (OK for reports)

Cost: 3x infrastructure, but global resilience

---

## Section 12: Cost Optimization ($20k → $12k) - Q12b & Q12c

**Q12b: You cut costs 40%, but now system is unstable (intermittent timeouts, errors). What did you over-optimize?**

Sample Answer:
- Reduced concurrency limits (bullhead too small)
- Switched to Spot VMs without graceful drain (sudden evictions)
- Reduced database replicas (single failure = downtime)
- Cut monitoring/alerting budget (blind to problems)
- Removed redundancy (no failover, high availability gone)

Fix:
- Restore 10% redundancy in critical path
- Keep Spot for non-critical only
- Monitoring not negotiable (keep full stack)
- Accept slightly higher cost for stability

New target: $13-14k (not $12k), but 99.99% uptime

---

**Q12c: Running cost analysis in 12 months and found 15% bill increase despite no feature growth. Where's the money going?**

Sample Answer:
- Storage: 5 years of event data accumulated
  → Move to archive tier (-$4k/month)
- Unused resources: Dev/test environments, old VMs
  → Clean up (-$2k/month)
- Egress costs: Data transfer between regions
  → Consolidate (-$1k/month)
- Over-provisioning: Headroom never used
  → Right-size (-$2k/month)
- License creep: Licenses for unused services
  → Audit and remove (-$0.5k/month)

Total: $9.5k/month (20% reduction)

---

## Section 13: Architecture Justification (Monolith → Microservices) - Q13b & Q13c

**Q13b: Microservices improved speed but operations cost tripled. Team overwhelmed. Was it worth it?**

Sample Answer:
- Deployment complexity: Manual → Need CI/CD pipeline
- Debugging: One monolith → Trace across 10 services
- Infrastructure: 1 database → 10 databases, more fail points
- Monitoring: 1 dashboard → 10 dashboards, correlate alerts

Worth it if:
- Feature velocity increased > ops cost (measure)
- Team scaled to handle (hire DevOps)
- Bottleneck was monolith (not organization)

Typically: Short-term pain (6 months ops cost), long-term gain (2 years faster iteration)

Solution: Invest in DevOps tooling, SRE hires, observability

---

**Q13c: Your monolith is 500k lines of code, legacy. Can't migrate everything. How would you incrementally adopt microservices?**

Sample Answer:
Strangler pattern (not big bang):
1. Start with 1 new service (e.g., Notification)
2. Monolith calls new service via API (not code)
3. Other teams still use monolith
4. Gradually move features: Auth → Review → Risk
5. Monolith shrinks to core services only
6. Eventually decommission monolith

Timeline: 1-2 years per core service
Risk: Managed (each service independent)
Benefit: No downtime migration

---

## Section 14-15: Behavioral (Healthcare Prior Auth, Saying "No") - Q14b-c, Q15b-c

**Q14b: Prior authorization system had 95% auto-approve, but 2% were wrong decisions (expensive). How would you improve accuracy?**

Sample Answer:
- Add more rules (conservative: approve if uncertain)
- Manual review sample (10% of decisions, audit)
- Feedback loop: Clinician overrides → improve rules
- ML model: Train on clinician decisions
- A/B test: New rules on subset first

Target: 99%+ accuracy (medical decision, must be right)
Cost: More manual review, higher latency for some
Value: Avoid costly errors, liability

---

**Q15b: Saying "no" to executive cost you favor. How would you handle it differently?**

Sample Answer:
- Got defensive instead of collaborative
- Should have asked: "What's the real problem we're solving?"
- Offered alternative earlier (phased approach)
- Include executive in solution, not just rejection

Next time:
- Lead with empathy ("I understand urgency")
- Offer choices (scenario A, B, C with tradeoffs)
- Make executive the decision-maker
- Own delivery on chosen scenario

---

## Sections 16-24 (Brief, High-Quality Q&A Sets)

### **16. ArgoCD & GitOps (3 Questions)**

Q16a: Design GitOps deployment pipeline for multi-tenant healthcare system
Q16b: ArgoCD sync fails (divergence between git and cluster). How would you debug?
Q16c: Need blue-green deployment (zero downtime). How with ArgoCD?

### **17. Tactical vs Strategic Design (3 Questions)**

Q17a: Quick hack vs right design (timeline vs technical debt). How do you decide?
Q17b: You took "quick hack" 2 years ago, now it's bottleneck. How to fix incrementally?
Q17c: Team wants rewrite, you want refactor. How to resolve?

### **18. Effort Estimation & Capacity Planning (3 Questions)**

Q18a: Estimate effort: "Build search feature for 100k documents"
Q18b: You estimated 2 weeks, took 4. What went wrong? How to improve?
Q18c: Capacity planning: 5 engineers, 10 feature requests. How prioritize?

### **19. Different Solution Options (3 Questions)**

Q19a: 3 options for Kafka consumer failures. When use each?
Q19b: SQL vs Cosmos for event store. When choose each?
Q19c: Monolith vs microservices. Decision framework?

### **20. Design Evaluation with Enterprise Architects (3 Questions)**

Q20a: EA questions your design (too distributed, hard to debug). How defend?
Q20b: EA proposes simpler design. When compromise vs insist on yours?
Q20c: Post-mortem: Design caused production issue. How take responsibility?

### **21. Stakeholder Management & Client Appreciation (3 Questions)**

Q21a: VP upset with delays. You have technical reasons, but business needs speed. How handle?
Q21b: Celebrate wins: 3 ways you've appreciated team/stakeholder after success?
Q21c: Client relationship at risk. How rebuild trust?

### **22. Micro UI Architecture & Module Federation (3 Questions)**

Q22a: Design micro frontends for 10 teams (different tech stacks)
Q22b: Module federation: One team updates shared component. How prevent breaking others?
Q22c: Slow module federation. How optimize?

### **23. Automated PR Review (AI-Assisted Tools) (3 Questions)**

Q23a: Set up AI-assisted PR review. What checks automate? What need human?
Q23b: AI review tools create false positives. Team ignores all warnings. How calibrate?
Q23c: Review latency (tools slow down PRs). How optimize tooling?

### **24. Production Crisis Management (3 Questions)**

Q24a: 2 AM: Database down, 10k patients can't access system. Your response plan?
Q24b: You made bad call during crisis (caused more downtime). How handle postmortem?
Q24c: After crisis, team exhausted. How prevent burnout? How prevent same issue?

---

## IMPLEMENTATION NOTES

Each question should have:
1. Scenario (1-2 sentences)
2. Sample Answer (500-1000 words)
3. Code examples where applicable
4. Decision frameworks or checklists
5. Real-world tradeoffs

Focus: Not just technical, but leadership, judgment, communication.

All 24 sections × 3 questions = 72 total Q&As covering all 46 original aspects.

