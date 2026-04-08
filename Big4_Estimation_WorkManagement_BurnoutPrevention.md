# Estimation, Work Management & Burnout Prevention
## Big 4 Consulting — Individual Contributor & Tech Lead Playbook

---

## Mind Map — Full Guide at a Glance

```
                         ┌──────────────────────────────────────────────────┐
                         │   ESTIMATION · WORK MANAGEMENT · BURNOUT         │
                         │   Big 4 · IC · Tech Lead · Technical Architect   │
                         └────────────────────┬─────────────────────────────┘
                                              │
          ┌───────────────────┬───────────────┼───────────────────┬──────────────────────┐
          │                   │               │                   │                      │
          ▼                   ▼               ▼                   ▼                      ▼
   ┌─────────────┐   ┌──────────────┐  ┌───────────────┐  ┌───────────────┐   ┌────────────────┐
   │  UNDERSTAND │   │   ESTIMATE   │  │  SAY NO       │  │  MANAGE WORK  │   │  PREVENT       │
   │  THE SYSTEM │   │  CORRECTLY   │  │  WITHOUT      │  │  & PRESSURE   │   │  BURNOUT       │
   └──────┬──────┘   └──────┬───────┘  │  SAYING NO    │  └───────┬───────┘   └───────┬────────┘
          │                 │          └───────┬───────┘          │                   │
          │                 │                  │                   │                   │
   ┌──────┴──────┐   ┌──────┴────────────┐    │           ┌───────┴────────┐   ┌──────┴──────────┐
   │ Big 4       │   │ IC Framework      │    │           │ Visibility      │   │ 5-Rung Burnout  │
   │ Pressure    │   │ ─────────────     │    │           │ System          │   │ Ladder          │
   │ Triangle    │   │ · Decompose 1st   │    │           │ ─────────────── │   │ ──────────────  │
   │ ─────────── │   │ · 3-Point PERT    │    │           │ · Weekly status │   │ Stretched       │
   │ Partner     │   │ · Explicit        │    │           │   email (IC)    │   │ Compressed      │
   │  ↓          │   │   assumptions     │    │           │ · Sprint wall   │   │ Fragile         │
   │ Manager     │   │ · Transparent     │    │           │   (TL)          │   │ Depleted        │
   │  ↓          │   │   buffer table    │    │           │                 │   │ Breaking        │
   │ You (IC/TA) │   │                   │    │           │ Urgency vs      │   │                 │
   │             │   │ TL Framework      │    │           │ Impact Matrix   │   │ Weekly          │
   │ 3 Lies of   │   │ ─────────────     │    │           │ ─────────────── │   │ Self-Check      │
   │ Big 4       │   │ · Capacity-first  │    │           │ Do Now          │   │ ──────────────  │
   │ ─────────── │   │ · Team calibr.    │    │           │ Delegate        │   │ 4 questions     │
   │ "Just       │   │ · Trade-off not   │    │           │ Schedule        │   │ every Friday    │
   │  ballpark"  │   │   refusal         │    │           │ Drop            │   │                 │
   │ "We'll      │   │ · Absorb          │    │           │                 │   │ 3 Warning       │
   │  revisit"   │   │   pressure,       │    │           │ Two-List Daily  │   │ Signs           │
   │ "Just this  │   │   don't transmit  │    │           │ · Committed     │   │ ──────────────  │
   │  phase"     │   │                   │    │           │ · Targeted      │   │ Scope drift     │
   └─────────────┘   └──────────────────┘    │           │                 │   │ Permanent       │
                                              │           │ Focus Block     │   │ catch-up        │
                                              │           │ Protection      │   │ Estimating      │
                                              │           │ 90 min min      │   │ to please       │
                                              │           └─────────────────┘   │                 │
                                              │                                 │ Recovery        │
                                              │                                 │ Protocol        │
                                    ┌─────────┴────────────┐                   │ 5 steps         │
                                    │ 6 Script Scenarios   │                   └─────────────────┘
                                    │ ─────────────────    │
                                    │ · Unrealistic DL     │
                                    │ · Mid-sprint scope   │
                                    │ · Parallel requests  │
                                    │ · "Quick question"   │
                                    │ · Underestimated     │
                                    │ · Pressure in mtg    │
                                    │                      │
                                    │ Executive Defence    │
                                    │ ─────────────────    │
                                    │ · Trade-off offer    │
                                    │ · Assumption reversal│
                                    └──────────────────────┘


                    ┌──────────────────────────────────────────────────────────────────────┐
                    │                    TECHNICAL ARCHITECT GUIDE                         │
                    │              Azure · Microservices · EDA · API · AKS · React         │
                    └────────────────────────────────┬─────────────────────────────────────┘
                                                     │
          ┌──────────────────────┬───────────────────┼───────────────────┬─────────────────────┐
          │                      │                   │                   │                     │
          ▼                      ▼                   ▼                   ▼                     ▼
   ┌─────────────┐     ┌─────────────────┐  ┌──────────────┐  ┌───────────────────┐  ┌─────────────────┐
   │  TA ROLE &  │     │  6 DELIVERY     │  │  INVISIBLE   │  │  PRESENTING       │  │  PRE-SUBMIT     │
   │  TIME MODEL │     │  SCENARIOS      │  │  COST LIST   │  │  THE ESTIMATE     │  │  CHECKLIST      │
   └──────┬──────┘     └──────┬──────────┘  └──────┬───────┘  └────────┬──────────┘  └────────┬────────┘
          │                   │                    │                    │                      │
   ┌──────┴──────────┐        │             ┌──────┴──────────┐ ┌──────┴──────────┐   ┌───────┴────────┐
   │ TA Responsibilities      │             │ ADRs            │ │ 5-Section       │   │ Architecture   │
   │ ─────────────── │        │             │ Env parity      │ │ Structure       │   │ Scope          │
   │ · Landscape def.│        │             │ Secret wiring   │ │ ─────────────── │   │ Effort         │
   │ · Work pkg design        │             │ Data migration  │ │ Scope boundary  │   │ Risk/Assumpt.  │
   │ · Hidden cost   │        │             │ Runbooks        │ │ Assumptions     │   │ Communication  │
   │   revelation    │        │             │ Hypercare       │ │ 3 Scenarios     │   │ Sign-off       │
   │                 │        │             │ API contracts   │ │ Open items      │   │                │
   │ TA Time Model   │        │             │ Soft-delete     │ │ Recommendation  │   │ 20-point       │
   │ ─────────────── │        │             │ Cross-browser   │ │                 │   │ checklist      │
   │ Discovery: 60%  │        │             └─────────────────┘ │ 1-Page Exec     │   │ before every   │
   │ Design:    50%  │        │                                  │ Summary Template│   │ submission     │
   │ Build:     25%  │        │                                  └─────────────────┘   └────────────────┘
   │ Stabilise: 10%  │        │
   │                 │        │
   │ Complexity      │   ┌────┴──────────────────────────────────────────────────────────┐
   │ Multipliers     │   │                  6 DELIVERY SCENARIOS                         │
   │ ─────────────── │   └──┬──────────┬──────────┬──────────┬──────────┬───────────────┘
   │ Brownfield ×1.2 │      │          │          │          │          │
   │ Legacy     ×1.4 │      ▼          ▼          ▼          ▼          ▼
   │ New tech   ×1.3 │  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌──────────┐ ┌───────┐
   │ 3rd party  ×1.2 │  │Green- │ │Mono→  │ │  EDA  │ │ APIM  │ │React+BFF │ │  AKS  │
   │ Compliance ×1.2 │  │field  │ │Micro  │ │       │ │Platf. │ │          │ │Prod   │
   │ Multi-rgn  ×1.3 │  │ AKS   │ │ Migr. │ │Svc Bus│ │       │ │MSAL Auth │ │Cluster│
   └─────────────────┘  │       │ │       │ │       │ │       │ │RTK Query │ │       │
                         │Ph 0-4 │ │Strangl│ │Prod'r │ │API    │ │Screen    │ │Netw.  │
                         │228-   │ │er Fig │ │9P/D   │ │design │ │rates     │ │Sec    │
                         │440 PD │ │22-32  │ │Consmr │ │APIM   │ │BFF       │ │KEDA   │
                         │       │ │per svc│ │12P/D  │ │config │ │11P/D     │ │GitOps │
                         │16-22  │ │       │ │172P/D │ │52P/D  │ │          │ │77P/D  │
                         │sprints│ │       │ │total  │ │total  │ │          │ │       │
                         └───────┘ └───────┘ └───────┘ └───────┘ └──────────┘ └───────┘


   ┌─────────────────────────────────────────────────────────────────────────────────────┐
   │  5 NON-NEGOTIABLE HABITS                                                            │
   │  ① Decompose before estimating  ② Assumptions in writing  ③ Capacity visible first │
   │  ④ Force the trade-off conversation  ⑤ Weekly self-check every Friday              │
   └─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Mental Model: You Are a Finite Resource, Not a Rubber Band

> A rubber band stretches further every time you pull it — until it snaps.
> A professional has a capacity ceiling. The job is not to stretch to the ceiling every week.
> The job is to make the ceiling **visible** so that work is allocated, not dumped.

Big 4 culture defaults to treating you as elastic. Every "yes" trains the system to expect more elasticity next time.
Every "here's what I can commit to" trains the system to plan around your actual capacity.

The difference between burning out in 18 months and sustaining for 10 years is not talent.
It is the habit of making your capacity visible before commitments are made, not after you've missed them.

---

## Part 1 — The Big 4 Pressure Machine: What You Are Actually Dealing With

```
// ── Why Big 4 specifically creates overcommitment ──────────────────────────
```

Understanding the structure prevents you from personalising the pressure.

### The Triangle That Creates the Problem

```
         Partner / Director
              (sells the deal — optimistic scope, tight timeline)
                    |
                    |  "The client expects delivery by Q2"
                    |
         Engagement Manager
              (owns the P&L — wants to minimise cost overruns)
                    |
                    | "Can your team absorb the extra scope?"
                    |
         You (IC or Tech Lead)
              (closest to the actual work — knows the real effort)
```

Each layer above you has an incentive to compress your estimate:
- Partner: won the deal on a timeline. Changing it is a client relationship problem.
- Manager: if you need more time, it costs more. That comes out of their margin.
- You: if you say no, you appear to lack commitment or be not a "team player."

None of this is malicious. It is structural. Knowing this protects you from internalising the pressure as a personal failing.

### The Three Lies of Big 4 Estimation Culture

| Lie | What it sounds like | What it actually means |
|-----|--------------------|-----------------------|
| "Just ballpark it" | "Give me a rough number" | The rough number becomes the commitment |
| "We'll revisit scope once we start" | "Stay flexible" | Scope creep will never be formally acknowledged |
| "Everyone works hard in the first phase" | "Temporary crunch" | Phase 1 crunch becomes the new normal |

Knowing these patterns means you can pre-empt them, not just survive them.

---

## Part 2 — Why Smart Engineers Burn Out in Big 4

```
// ── The burnout mechanism — not about hours, about unacknowledged scope ────
```

Burnout in Big 4 is rarely caused by hard work alone. It is caused by a specific combination:

```
High effort  +  Unclear expectations  +  No control over scope  +  No recovery time
     = Burnout
```

Each factor amplifies the others. You can work long hours if the scope is clear.
You can manage unclear scope if you have recovery time. But all four together is unsustainable.

### The Burnout Ladder (recognise which rung you are on)

```
Rung 1 — Stretched:    Occasional late nights, manageable, recovers on weekends
Rung 2 — Compressed:   Consistent 10+ hr days, weekends absorbed, "catching up" feeling
Rung 3 — Fragile:      Cannot estimate accurately, small requests feel overwhelming
Rung 4 — Depleted:     Cynicism about work, cognitive fog, no satisfaction from delivery
Rung 5 — Breaking:     Physical symptoms, inability to focus, reactive to everything
```

Prevention works at Rung 1–2. Recovery is required from Rung 3 onward. This guide keeps you at Rung 1.

---

## Part 3 — The IC Estimation Framework

```
// ── How to estimate as an Individual Contributor without being overridden ──
```

### Mental Model: Estimate Like a Contractor, Not a Volunteer

A contractor quotes based on scope. A volunteer says "I'll do what it takes."
In Big 4, you are employed as a contractor. Estimate accordingly.

### Step 1 — Decompose Before You Respond

Never give a number the moment a request lands. Use the decomposition pause:

> "Let me break this down properly before I give you a number. I'll come back to you by [time]."

This is not stalling. This is professional practice. An architect who answers in 30 seconds is guessing.

**Decomposition checklist (ask yourself for every task):**

```
[ ] What is the full scope? (not just what was said — what is implied)
[ ] Which systems does this touch?
[ ] What do I need from other people before I can start?
[ ] What can go wrong? (integration, data, environment, approval)
[ ] How long did similar tasks actually take last time?
[ ] What is NOT in scope? (state it explicitly)
```

### Step 2 — Use Three-Point Estimation, Not a Single Number

Single numbers feel confident but collapse under scrutiny.
Three-point estimates are honest and harder to attack.

```
Best case (everything goes right)       = O  (Optimistic)
Most likely (normal friction)           = M  (Most Likely)
Worst case (dependencies fail, rework)  = P  (Pessimistic)

PERT formula: E = (O + 4M + P) / 6
```

**Example:**

| Scenario | Days |
|----------|------|
| Optimistic (API docs ready, no blockers) | 3 |
| Most Likely (one dependency delay, one rework cycle) | 6 |
| Pessimistic (integration issues, schema change needed) | 12 |
| **PERT estimate** | **(3 + 24 + 12) / 6 = 6.5 days** |

Present: **"My estimate is 6–7 days. Here is what it assumes."**

Not: "It will take a week." (which gets heard as "5 days max.")

### Step 3 — Surface Assumptions Explicitly

Every estimate is valid only under certain conditions. State those conditions.

**Template:**
> "My estimate of [X] assumes:
> - [dependency 1] is ready by [date]
> - [person/team] reviews [artifact] within [timeframe]
> - Scope does not include [specific item]
> If any of these change, the estimate changes."

Writing this down — even in a quick email — protects you.
If a dependency slips and your estimate becomes invalid, you have documentation.

### Step 4 — Add Buffer Transparently, Not Secretly

Hidden padding looks like dishonesty if discovered. Transparent buffer looks like professional risk management.

| Risk Factor | Buffer to Add | Rationale |
|-------------|--------------|-----------|
| External team dependency | +15% | They have their own priorities |
| New technology/framework | +20% | Learning curve + unexpected edges |
| Unclear/evolving requirements | +20% | Rework is guaranteed |
| Legacy system integration | +25% | Undocumented behaviour, no tests |
| Regulatory/compliance requirement | +15% | Sign-off cycles add elapsed time |
| No prior similar work in this codebase | +20% | Discovery overhead is real |

Say: "I'm adding 20% for the third-party API dependency — based on our last two integrations with external systems, the documented behaviour and actual behaviour differ."

This is not pessimism. It is accuracy based on evidence.

---

## Part 4 — The Tech Lead Estimation Framework

```
// ── Additional layer: estimating for a team, not just yourself ─────────────
```

As a Tech Lead, you own the team's aggregate commitment. This is a different skill from IC estimation.

### Mental Model: You Are the Air Traffic Controller

An IC estimates one flight. You estimate the runway.
You must know:
- How many planes are trying to land at once
- Which ones have fuel (capacity) and which are running low
- Which ones are carrying hazardous cargo (dependencies that block others)
- When the runway needs maintenance (team learning, tech debt)

### The Capacity-First Rule

Never estimate a sprint or a milestone before you know team capacity.

**Capacity calculation:**

```
Team size:                    N people
Working days in period:       D days
Meeting overhead per person:  ~20% (standups, refinements, 1:1s, reviews)
Effective capacity:           N × D × 0.8 person-days

Then subtract:
- Planned leave / holidays
- Onboarding overhead (new joiners: -50% first 2 weeks)
- On-call / production support rotation

Actual available capacity = number you plan into
```

If the requested work exceeds available capacity, **this is the data you present, not a complaint.**

### How to Present a Capacity Shortfall

Weak (sounds like a refusal):
> "We can't take on all of that this sprint."

Strong (sounds like risk management):
> "Current sprint capacity is 42 story points across the team. The requested scope is 67 points. That is a 60% overload. Here are the three options: (1) defer items 4–7 to next sprint, (2) reduce scope on items 2 and 3, (3) add one more resource. Which do you prefer?"

You are not blocking delivery. You are forcing a decision that belongs to the stakeholder, not to you.

### Estimating Across the Team: The Calibration Session

Never let a Tech Lead estimate for individual contributors without them.
Run a quick estimation session:

```
1. Present the work item (2 min)
2. Each person privately writes their estimate
3. Reveal simultaneously (prevents anchoring)
4. If estimates differ by more than 2x, discuss — don't average
5. The discussion surfaces assumptions and risks, not just numbers
```

The discussion is the point. The number is the output.

### Protecting Your Team's Estimates Under Pressure

When a manager says "can't we just do it in half the time?":

**Do not defend the number alone. Defend the decomposition.**

> "The 8-day estimate covers: API build (2 days), database migration (1 day), integration with the auth service (2 days), testing and regression (2 days), deployment and smoke testing (1 day). If you want to reduce to 4 days, here is what we would skip: testing and regression. I want to make sure you're aware of that trade-off before we commit."

Make the trade-off visible. Let them decide. Document their decision.

---

## Part 5 — How to Say No Without Saying No

```
// ── Practical scripts for the actual conversations ──────────────────────────
```

### Mental Model: You Are Not Refusing Work. You Are Clarifying Constraints.

"No" is a relationship problem in Big 4 culture. "Here is what I can commit to and what I cannot" is a professional service.
The second phrasing is both honest and politically survivable.

---

### Script Bank — Situations You Will Actually Face

#### Situation 1: Unrealistic deadline given to you, not negotiated with you

**What you hear:**
> "The client needs this by Friday. Make it happen."

**What not to say:**
> "That's impossible." (closed, no path forward)

**What to say:**
> "I want to make sure we hit Friday without a quality risk. The work involves [X, Y, Z]. That's realistically [N] days of effort. To hit Friday, I'd need [specific thing — e.g., the API spec today, a decision on authentication by EOD tomorrow, and someone else to own the testing piece]. If those are in place, I can commit to Friday. If not, I can give you a realistic date after I see the spec. Which path works better?"

Key: give them a Yes path. Make the conditions explicit. If conditions aren't met, the Friday date is their call, not your failure.

---

#### Situation 2: Scope added mid-sprint with no trade-off offered

**What you hear:**
> "Can you also add the export feature? It shouldn't take long."

**What not to say:**
> "Fine, I'll try." (absorbs scope silently — this is how weekends disappear)

**What to say:**
> "I can add the export feature. To keep the sprint commitment, something else needs to come out — or the sprint extends. What would you like to drop: the reporting dashboard or the admin screen? Or should we push the export to next sprint and keep the current plan?"

You are not saying no to the export feature. You are saying no to invisible scope expansion.

---

#### Situation 3: Parallel requests from multiple stakeholders

**What you hear (from two different people the same day):**
> Person A: "Can you look at the performance issue today?"
> Person B: "Can you review my architecture proposal today?"

**What not to say:**
> "Sure" to both (and then fail both by end of day)

**What to say:**
> "I have two requests today that I can't both complete at the same depth. [Person A]'s performance issue looks production-risk — I'll prioritise that. [Person B], I can give your proposal a quick read today and a proper review tomorrow morning. Does that work, or should we check with [manager/lead] on the priority?"

You are managing priorities, not refusing work. And you are flagging the conflict to the right person.

---

#### Situation 4: "Just a quick question" that is not quick

**What happens:**
> Someone stops by (or Slack messages) for "a quick question" that turns into 45 minutes of ad-hoc consulting.

**Prevention:**
> "I'm in deep focus mode right now — can I get back to you at 3 PM when I surface?"

Most "quick questions" have a non-urgent answer. Batching them protects your focus blocks without being unhelpful.

**If it truly is urgent:**
> "Let me spend 5 minutes with you now to understand the problem. If it needs more than that, let's book 30 minutes this afternoon."

---

#### Situation 5: Committed to something you now realise was underestimated

**What not to do:** stay silent and try to brute-force it with overtime.

**What to say (as early as possible — not the day before):**
> "I need to flag a risk on [task]. When I committed to [date], I assumed [X]. [X] has turned out to be [more complex / not available / different than spec]. My revised estimate is [N] days. I'm flagging this now so we can adjust the plan — I didn't want to surface it at the last minute. Here's what I can deliver by the original date: [partial scope]."

Early re-estimation is professional. Last-minute surprises are not. The culture rewards transparency, even when the news is bad.

---

#### Situation 6: Pressure to say yes in a meeting (no time to think)

**What happens:**
> You're in a meeting. Someone says "Can we commit to [X] by [date]?" and everyone looks at you.

**What not to do:** say yes to avoid the awkward silence.

**What to say:**
> "I want to give you a real answer, not a fast one. Let me check capacity and dependencies and come back to you by [time today / tomorrow morning]. That gives me a number I can actually stand behind."

This works. It reads as professional rigor, not hesitation.

---

## Part 6 — Managing Multiple Stakeholders: The Visibility System

```
// ── Making your work visible prevents scope dumping and priority conflicts ──
```

### The Core Problem: Invisible Work Gets Added To

If your manager cannot see what you are working on, they assume you have capacity.
The solution is not working harder. It is making the work visible.

### The Weekly Status Email (IC version — 5 minutes to write, 40 minutes of protection)

Send this every Friday at end of day or Monday morning:

```
Subject: Work Status — Week of [date]

Completed this week:
- [Task 1] — [outcome/what it enables]
- [Task 2] — [outcome/what it enables]

In progress (carrying into next week):
- [Task] — [% complete, expected completion]
- [Task] — [blocker, if any]

Planned for next week:
- [Task] — [estimated effort]
- [Task] — [estimated effort]

Current capacity: [available / at capacity / over capacity — be honest]

Blockers / risks I need help with:
- [item, if any]
```

**Why this works:**
- Your manager knows what you are doing before they assign more
- If they add something, they must acknowledge what moves out
- It creates a paper trail of your output (useful for performance reviews)
- "At capacity" or "over capacity" stated weekly is data, not complaining

### Tech Lead: The Sprint Commitment Wall

Make team commitments visible before the sprint starts, not during.

```
Sprint Capacity:    [N] story points
Sprint Commitment:  [N] story points
Outstanding asks:   [N] story points (these are in backlog, not this sprint)
```

When a new request arrives mid-sprint:
> "This sprint's wall is at capacity. This item is [N] points. To add it, we park [existing item] — or we revisit at sprint review. Which would you like?"

The wall makes the trade-off concrete and visible. Decisions get made, not deferred onto you.

---

## Part 7 — Work Management Under Pressure

```
// ── How to stay productive when everything feels urgent ────────────────────
```

### Mental Model: Triage, Not Priority Queue

In a hospital ER, not every patient gets seen in arrival order.
They are triaged by urgency and impact.
In Big 4, not every request is equally urgent. Your job is triage, not a first-in-first-out queue.

### The Urgency vs Impact Matrix (apply daily)

```
                    HIGH IMPACT          LOW IMPACT
                 ┌──────────────────┬──────────────────┐
  HIGH URGENCY  │  DO NOW           │  DELEGATE or      │
                │  (production down │  DEFER            │
                │   client blocked) │  (someone else's  │
                │                  │   urgent = not     │
                │                  │   yours)           │
                ├──────────────────┼──────────────────┤
  LOW URGENCY   │  SCHEDULE IT     │  DROP or          │
                │  (important work  │  BATCH            │
                │   with a window)  │  (noise, admin,   │
                │                  │   low-value asks) │
                └──────────────────┴──────────────────┘
```

Most "urgent" requests from stakeholders are High Urgency / Low Impact — someone else's deadline, not a client blocker.
Most burnout comes from treating that cell the same as the top-left cell.

### The Two-List Daily System

At the start of each day, write two lists:

```
COMMITTED (must be done today — I have told someone):
1. [item]
2. [item]

TARGETED (I want to do today if capacity allows):
1. [item]
2. [item]
```

Only the Committed list creates obligation. The Targeted list is intention, not promise.
When something new arrives, it goes on the Targeted list unless it is genuinely urgent.
If it displaces a Committed item, tell the person who owns that commitment.

### Focus Protection (the mechanism that enables deep work)

Big 4 offices and Slack/Teams are interrupt-heavy. Deep technical work requires at minimum 90-minute uninterrupted blocks.

**Protect at least one block per day:**
- Block 90 minutes in your calendar as "Focus: [task name]" — named, not generic
- Status: Do Not Disturb on messaging tools during this block
- Tell your team: "I'm heads-down on [X] until [time] — ping after that"

**What to do with interruptions during focus blocks:**
> "I'm in the middle of something until [time]. I'll get back to you by [time + 30 min]. Is that OK, or is it blocking you right now?"

90% of the time: "That works." The interrupt was not actually blocking.

---

## Part 8 — Protecting Your Estimate Under Executive Pressure

```
// ── The boardroom challenge — when the numbers get questioned at seniority ──
```

### The Three Responses That Fail

| Response | Why it fails |
|----------|-------------|
| "The team needs the time they need." | Sounds defensive, no data |
| "I can try to do it faster." | You just surrendered your estimate |
| "It's not possible." | Closed. Creates conflict. No path forward. |

### The Response That Works: The Trade-off Offer

When an executive says "this timeline is too long":

> "I understand the timeline pressure. There are three levers: scope, time, and quality. I can give you a faster date if we scope down or accept higher technical risk. Here is what each looks like:
>
> Option A — Original timeline, full scope, production quality: [original date]
> Option B — Compressed timeline, reduced scope (drop [specific items]): [faster date]
> Option C — Compressed timeline, full scope, deferred testing: [fastest date] — with a known quality risk I'd want documented
>
> Which option fits the business need best?"

You are not defending your estimate. You are making the trade-off explicit.
The decision now belongs to the executive, not to you. Document which option they chose.

### The Assumption Reversal Technique

If the pressure continues, reverse the burden:

> "I'm open to adjusting the estimate. Can you walk me through which part of the work you think is overestimated? I want to understand if I'm missing something."

Most executives cannot answer this question. The decomposition was your protection all along.
If they can answer it — listen. They may know something you don't. That is a good outcome.

---

## Part 9 — The Burnout Prevention System

```
// ── Proactive signals and weekly hygiene — catch Rung 1-2 before Rung 3+ ──
```

### Weekly Check-In With Yourself (5 minutes, Friday)

Answer these four questions honestly:

```
1. Cognitive load this week:     Low / Medium / High / Unsustainable
2. Hours beyond contract:        0 / 1-5 / 5-10 / 10+
3. Recovery quality (evenings/weekends this week):  Good / Partial / None
4. Did I do work that wasn't mine to do?   No / 1-2 times / Often
```

If two or more answers are in the "warning" category in the same week: flag it.
If it happens two consecutive weeks: this is a pattern, not a bad week. Act.

### The Three Warning Signs That Precede Burnout (not the symptoms — the causes)

**Warning Sign 1: Scope Drift Without Documentation**
You are doing work that was never agreed on, never tracked, and never acknowledged.
If you cannot answer "who asked for this and when?", the work may be invisible scope.
Fix: Add it to your status email. Make it visible. Every time.

**Warning Sign 2: The Permanent Catch-Up State**
You started the week planning to catch up on last week's backlog.
You end the week with more backlog than you started.
This is not a capacity problem you can work your way out of. It is a scope problem.
Fix: The catch-up state means commitments exceed capacity. Surface the gap. Don't absorb it.

**Warning Sign 3: Estimating to Please, Not to Inform**
You are giving numbers that sound acceptable, not numbers you believe.
You already know the estimate is wrong but feel you cannot say so.
This is the most dangerous sign — it means the protection mechanism is already broken.
Fix: One honest estimate. In writing. With assumptions. This week.

### Recovery Protocol (if you are already at Rung 3+)

This is not weakness. It is maintenance.

```
Step 1 — Stop adding to the load.
         Decline or defer everything non-committed for one week.
         No new estimates. No new commitments. Clear the queue.

Step 2 — Audit current commitments.
         List everything you have said yes to.
         Identify which ones are actually yours.
         For ones that are not yours: hand them back formally.

Step 3 — Sleep before strategy.
         Recovery starts with sleep. Nothing strategic happens at Rung 4-5.
         Two nights of full sleep before re-engaging with the backlog.

Step 4 — Re-negotiate one thing.
         Pick the single most over-committed item.
         Go to the owner and renegotiate scope or date.
         The act of renegotiating restores agency.

Step 5 — Protect one recovery window per week.
         Non-negotiable. No work. No email. No Slack.
         The system does not get to use your recovery window.
```

---

## Part 10 — IC vs Tech Lead: Key Differences in Practice

```
// ── Same principles, different application based on role ───────────────────
```

| Situation | IC Approach | Tech Lead Approach |
|-----------|------------|-------------------|
| Unrealistic deadline arrives | "Here is what I can deliver by [date] and what I need" | "Here is team capacity, here is the shortfall, here are 3 options" |
| Scope added mid-work | "What moves out if this moves in?" | "Sprint wall is full — present the trade-off to the team and stakeholder jointly" |
| Estimate challenged | Defend your decomposition, not the number | Make the team's decomposition visible; let the data speak |
| Someone is burning out (self) | Surface it early — to manager — before quality suffers | Detect it in the team — adjust workload before it becomes a conversation about performance |
| New request arrives via Slack | "Is this a priority over [current committed task]?" | "Which team member should pick this up? What comes off their plate?" |
| You realise you underestimated | Tell your manager immediately, with revised date | Tell your manager and the team; re-plan the sprint with honesty |

### The Tech Lead's Additional Responsibility: Absorbing Pressure, Not Transmitting It

The single most important skill of a Tech Lead in Big 4 is **pressure buffering**.

Executive pressure flows down. Your job is to translate it before it hits your team.

**What this means in practice:**
- Your team hears: "We have a challenging deadline — here is the plan and what we are not doing."
- Not: "Leadership is unhappy — we need to work faster."
- The first gives people a concrete direction. The second creates anxiety without actionability.

If you transmit pressure without translation, you get a team that works longer hours, makes more mistakes, and burns out faster — while not actually delivering faster.

---

## Part 11 — Quick Reference: The Sentences That Change Outcomes

```
// ── Say these out loud until they are natural ───────────────────────────────
```

### When Asked to Estimate on the Spot
> "Let me decompose this properly — I'll have a number for you by [time]."

### When Given a Deadline That Doesn't Fit the Work
> "To hit [date], here is what would need to be true: [conditions]. Are those conditions in place?"

### When Scope Is Added Without a Trade-off
> "I can add that. What comes out to make room, or does the date move?"

### When Pressed to Commit Faster in a Meeting
> "I want to give you a number I can stand behind. Let me confirm [capacity/dependency] and come back to you by [today/tomorrow]."

### When Your Estimate Is Challenged
> "The estimate covers [A, B, C, D]. Which part do you think is overestimated? I'm open to looking at it together."

### When You Are Already Overloaded
> "I'm at capacity on committed items through [date]. I can pick this up after that, or we can talk about what to deprioritise."

### When You Realise You Are Behind
> "I need to flag a risk. I committed to [X] by [date]. My revised estimate is [Y]. I'm telling you now so we can plan — not at the last minute."

### When Someone Says "Just This Once, Work the Weekend"
> "I can work this weekend if this is a genuine exception. Before I commit, I want to understand what we are doing differently so this doesn't become the pattern."

---

## Summary: The Five Non-Negotiable Habits

```
// ── These are the load-bearing habits. Everything else is variation. ────────
```

1. **Never give an estimate without decomposing first.**
   A number without a breakdown is a guess with a deadline attached.

2. **State assumptions in writing every time.**
   If an assumption breaks, the estimate is invalid — and you have proof it was conditional.

3. **Make capacity visible before accepting work.**
   "I can take this on" is only a valid statement after you know what else is in flight.

4. **Force the trade-off conversation, don't absorb it.**
   When scope grows or deadlines compress, the trade-off decision belongs to the stakeholder.
   Your job is to present the options clearly, not to silently absorb the cost.

5. **Weekly self-check — before Friday ends.**
   Four questions. Five minutes. The discipline that catches Rung 1 before it becomes Rung 4.

---

---

# Part 12 — Technical Architect Estimation Guide
## Azure · Microservices · EDA · API · ReactJS · AKS

```
// ── Effort allocation for a TA across real engagement scenarios ─────────────
```

---

## Mental Model: You Are the Cartographer, Not the Explorer

> The team navigates the terrain. You draw the map before the journey begins.
> Your estimation job is not to size every task — it is to reveal the landscape:
> what exists, what must be built, where the cliffs are, and how long each path takes.
> An explorer who walks into unknown terrain without a map burns twice the calories.
> A TA who estimates without decomposing the architecture creates exactly that situation for the team.

---

## 12.1 — The Architect's Estimation Responsibilities (Different From IC / TL)

As a Technical Architect, estimation has three distinct responsibilities that IC and TL roles do not carry:

| Responsibility | What it means in practice |
|---------------|--------------------------|
| **Landscape definition** | Identify all layers the solution touches — before anyone writes a line of code |
| **Work package design** | Decompose the architecture into estimable chunks the team can own |
| **Hidden cost revelation** | Surface the infrastructure, security, observability, and NFR work that never appears in functional requirements |

You are not estimating tasks. You are estimating the **system effort surface** — everything that must exist for the solution to run in production.

---

## 12.2 — Architect's Own Time Allocation

Before estimating the team's effort, be explicit about your own time.
A TA who is fully booked on delivery cannot also be doing architecture.

### TA Time Allocation Model (Typical Engagement)

```
// WHY: Architects routinely underestimate their own overhead, then either
//      deliver poor architecture or burn out trying to do both.

Phase              | Architecture | Delivery Support | Governance | Comms/Stakeholder
───────────────────┼──────────────┼──────────────────┼────────────┼──────────────────
Discovery (Wk 1-2) | 60%          | 0%               | 20%        | 20%
Design (Wk 3-5)    | 50%          | 10%              | 20%        | 20%
Build (ongoing)    | 25%          | 40%              | 15%        | 20%
Stabilise / UAT    | 10%          | 50%              | 20%        | 20%
Go-Live / Hyper    | 5%           | 60%              | 10%        | 25%
```

**Key insight:** During Build phase, a TA at 25% architecture + 40% delivery support is already at 65% utilisation before governance and stakeholder work. There is no capacity left for new design requests without displacing something.

When a manager asks "can you also design the [new service] this sprint?" — reference this model.

---

## 12.3 — Estimation Units Reference

Use consistent units across all scenarios. Mix of person-days (P/D) and story points creates confusion in multi-team engagements.

```
// WHY: Big 4 engagements often mix teams from different disciplines.
//      Architect estimates in person-days; team works in story points.
//      Establish a conversion before estimation begins, not during it.

1 Story Point      ≈ 0.5 person-days (for experienced team)
1 Sprint (2 weeks) ≈ 8-9 productive person-days per developer (after overhead)
T-shirt size → points:  XS=1, S=2, M=3, L=5, XL=8, XXL=13, Epic=split it

Calendar time ≠ effort time. A 10-day task with 3 dependencies may take 20 calendar days.
Always state BOTH: "10 person-days effort, 18 calendar days elapsed."
```

---

## 12.4 — Complexity Multipliers (Applied to Base Estimates)

These are applied to the raw feature effort. Document which multipliers you applied and why.

| Factor | Multiplier | When it applies |
|--------|-----------|----------------|
| Greenfield (no existing codebase) | ×1.0 base | Starting from scratch |
| Brownfield — known codebase | ×1.2 | Reading + understanding existing code before changing it |
| Brownfield — unknown/undocumented codebase | ×1.5 | Discovery overhead is significant |
| Third-party API integration | ×1.2 per integration | Sandbox issues, undocumented behaviour, rate limits |
| Legacy system integration | ×1.4 | Undocumented contracts, no automated tests, no rollback |
| Compliance / regulatory requirement | ×1.2 | Sign-off cycles, audit logging, pen testing |
| Multi-region / HA requirement | ×1.3 | Deployment topology, data replication, failover logic |
| New-to-team technology | ×1.3 | Upskilling time embedded in delivery |
| Distributed team (time-zone gap > 4 hrs) | ×1.15 | Async coordination, meeting overhead, PR review delays |

**Usage:** Base estimate × relevant multipliers.
Example: A feature estimated at 10 P/D with a third-party API + brownfield codebase = 10 × 1.2 × 1.2 = 14.4 P/D. Round to 15 P/D and state assumptions.

---

## Scenario 1 — Greenfield Cloud-Native System on AKS

```
// ── Full new build: Azure infra + AKS + microservices + ReactJS frontend ────
// ── Typical engagement: 4–8 developers, 6–9 month delivery ──────────────────
```

### Context
A new enterprise system built from scratch. Stack: .NET microservices on AKS, Azure Service Bus, Cosmos DB / SQL, ReactJS frontend, Azure API Management, Key Vault, Application Insights.

### Phase Breakdown — Effort in Person-Days (P/D)

#### Phase 0 — Architecture & Discovery (Weeks 1–3)

| Activity | Owner | P/D | Notes |
|----------|-------|-----|-------|
| Requirements workshop facilitation | TA | 3 | Domain discovery, bounded context mapping |
| Architecture design (HLD) | TA | 5 | ADRs, component diagram, integration map |
| Technology decision records | TA | 2 | Justify each stack choice with trade-offs |
| Infrastructure design (Bicep / Terraform) | TA + DevOps | 4 | AKS sizing, networking, SKU choices |
| Security design (identity, secrets, RBAC) | TA | 2 | Workload Identity, Key Vault, APIM policies |
| Estimation & delivery roadmap | TA | 2 | Team sizing, sprint plan, milestone map |
| **Phase 0 Total** | | **18 P/D** | |

> **Commonly missed:** ADRs (Architecture Decision Records). Without them, every decision gets re-litigated in sprint review. Budget 1–2 days explicitly.

#### Phase 1 — Foundation & Platform (Weeks 3–7)

| Activity | Owner | P/D | Notes |
|----------|-------|-----|-------|
| AKS cluster provisioning (Bicep/Terraform) | DevOps + TA | 5 | Node pools, CNI, ingress, private cluster |
| Azure networking (VNet, NSG, private endpoints) | DevOps | 4 | Required before any service deployment |
| Azure APIM setup + base policies | DevOps + TA | 3 | Auth, rate limit, CORS, logging policies |
| Key Vault + Managed Identity wiring | DevOps | 2 | Must be done before secrets are needed |
| CI/CD pipeline scaffolding (all services) | DevOps | 5 | Build, test, push, deploy per service |
| Microservice project templates (.NET) | TA + Lead Dev | 4 | Shared logging, health checks, auth middleware |
| ReactJS project scaffold + build pipeline | Lead FE | 3 | Vite/CRA, ESLint, test config, Dockerfile |
| Base observability (App Insights, dashboards) | DevOps + TA | 3 | Structured logging, baseline alerts |
| **Phase 1 Total** | | **29 P/D** | |

> **Commonly missed:** CI/CD takes 5 P/D minimum for a multi-service system. Teams estimate 2 days and spend 2 weeks.

#### Phase 2 — Feature Build (per service, per sprint)

Use this unit template per microservice:

| Layer | Activity | P/D (Simple) | P/D (Complex) |
|-------|----------|-------------|--------------|
| API | Endpoints, DTO, validation, versioning | 2 | 5 |
| Domain | Business logic, domain events, rules | 3 | 8 |
| Data | EF Core model, migrations, repository | 2 | 4 |
| Integration | Service Bus producer/consumer | 2 | 5 |
| Security | RBAC, token validation, audit | 1 | 3 |
| Testing | Unit + integration tests | 2 | 4 |
| Observability | Structured logs, metrics, traces | 1 | 2 |
| **Service total** | | **13 P/D** | **31 P/D** |

For a system with 6 microservices, simple: 78 P/D. Complex: 186 P/D. The range is the honest answer.

#### Phase 3 — ReactJS Frontend

| Activity | P/D |
|----------|-----|
| Component library / design system setup | 4 |
| Routing, auth integration (MSAL/OIDC) | 3 |
| Per screen (average, CRUD with table + form) | 3–5 |
| API service layer (RTK Query / Axios) | 2 |
| State management (Redux Toolkit / Zustand) | 2 |
| Error boundaries + loading states (all screens) | 2 |
| Responsive layout + accessibility baseline | 3 |
| E2E test setup (Cypress / Playwright) | 3 |

> **Rule of thumb:** Budget 1 P/D per screen for simple read-only views. 3–5 P/D for screens with forms, validation, and async state.

#### Phase 4 — NFR & Production Readiness

| Activity | P/D | Why often missed |
|----------|-----|-----------------|
| HPA + KEDA autoscaling config | 3 | "We'll do it after go-live" — then never do |
| AKS network policies (pod-to-pod security) | 2 | Skipped until a security review flags it |
| Disaster recovery runbook + test | 3 | Not on the feature backlog |
| Performance testing (k6 / Azure Load Testing) | 4 | Added last-minute, no time to fix findings |
| Security review + pen test remediation | 5 | Always longer than expected |
| Documentation (architecture + runbook) | 4 | Never estimated — always done in personal time |
| Hypercare window | 5 | Two weeks post go-live — always underestimated |
| **Phase 4 Total** | | **26 P/D** | |

### Greenfield Total Estimate Summary

```
Phase 0 — Architecture & Discovery:     18 P/D
Phase 1 — Platform & Foundation:        29 P/D
Phase 2 — Feature Build (6 services):  100–190 P/D  (scenario-dependent)
Phase 3 — ReactJS Frontend (12 screens): 55 P/D
Phase 4 — NFR & Production Readiness:   26 P/D
───────────────────────────────────────────────
Base Total:                            228–318 P/D

Complexity multiplier (brownfield integrations ×1.2):  275–382 P/D
Buffer (15% for requirement volatility):               317–440 P/D

Team of 5 developers at 8 P/D/sprint:  40 P/D/sprint
Duration: 8–11 sprints (16–22 weeks)
```

---

## Scenario 2 — Monolith to Microservices Migration

```
// ── Incrementally decomposing an existing monolith using Strangler Fig ───────
// ── Highest-risk scenario — the existing system must keep running ─────────────
```

### What Makes This Harder Than Greenfield

```
Greenfield:   You design the seams.
Migration:    You discover seams that were never designed — in undocumented code,
              shared databases, and implicit coupling you will only find by running it.
```

Multiply all feature estimates by 1.4–1.5 for this reason alone.

### Phase Breakdown

#### Phase 0 — Domain Analysis & Decomposition Design

| Activity | Owner | P/D |
|----------|-------|-----|
| Codebase archaeology (reading + mapping existing system) | TA + Lead Dev | 8 |
| Event storming / domain model workshop | TA + Business | 4 |
| Bounded context identification | TA | 3 |
| Data ownership mapping (which table belongs to which domain) | TA + DBA | 4 |
| Strangler Fig migration sequence design | TA | 3 |
| Risk register for shared database coupling | TA | 2 |
| **Phase 0 Total** | | **24 P/D** |

> **Critical:** The migration sequence matters enormously. Extract the wrong service first and you create a distributed monolith. Budget the design time — it prevents months of rework.

#### Per Service Extraction (Strangler Fig Pattern)

| Step | Activity | P/D |
|------|----------|-----|
| 1 | Define service boundary + API contract | 2 |
| 2 | Build new service alongside monolith | 8–15 |
| 3 | Route traffic via facade (APIM / reverse proxy) | 2 |
| 4 | Migrate data ownership (schema separation) | 5–10 |
| 5 | Cut over traffic + shadow mode testing | 3 |
| 6 | Remove dead code from monolith | 2 |
| **Per service total** | | **22–32 P/D** |

For 8 services extracted: 176–256 P/D. This is not a 3-month project.

#### What Cannot Be Estimated Until You Start (state this explicitly)

| Unknown | How to handle it in estimation |
|---------|-------------------------------|
| Depth of shared database coupling | Estimate discovery only; re-estimate per service after data mapping |
| Number of undocumented API consumers | Add 10 P/D discovery buffer; downstream consumers always surface late |
| Legacy auth mechanism | Add 5 P/D — re-auth across service boundaries is rarely simple |
| Implicit transaction boundaries | Add 5–10 P/D per service for saga/compensating transaction design |

Present these as **open items**, not as padding. The client signs off on the open items being unresolved at estimate time.

### Architect's Specific Warning for This Scenario

The most dangerous moment in a migration: when someone says "can we just move faster and share the database for now?"

Shared database between new microservices and the monolith eliminates the independence you are trying to create. The coupling moves from code to schema — invisible and harder to undo.

> Response: "We can do that and it will accelerate the first month. It will add 3–4 months to the full migration because we will have to undo the shared schema. Which timeline are we optimising for?"

---

## Scenario 3 — Event-Driven Architecture (EDA) Implementation

```
// ── Azure Service Bus + Event Grid as the backbone ───────────────────────────
// ── Standalone EDA build or being added to an existing system ────────────────
```

### EDA-Specific Estimation Complexity

EDA has hidden coordination costs that synchronous systems do not:
- Event schema design affects every producer and consumer
- Schema changes are breaking changes without a registry
- Dead letter handling requires explicit design, not an afterthought
- Replay and idempotency are not optional in production

### Architecture Design Phase (Always Do This First)

| Activity | Owner | P/D |
|----------|-------|-----|
| Event storming workshop (identify all events) | TA + Domain experts | 3 |
| Event schema design (CloudEvents / custom) | TA | 2 |
| Topic / queue topology design (Service Bus namespaces, topics, subscriptions) | TA + DevOps | 2 |
| Dead letter strategy + alerting design | TA | 1 |
| Idempotency strategy design (outbox pattern / deduplication) | TA | 2 |
| Event versioning strategy | TA | 1 |
| Schema registry decision (Azure Schema Registry / custom) | TA | 1 |
| **Design Total** | | **12 P/D** |

> **Most common EDA mistake:** Skipping event schema design. The first producer-consumer pair works fine. The fourth integration breaks because schemas evolved independently. Budget the design phase — it is cheaper than schema migration later.

### Per Producer Service

| Activity | P/D |
|----------|-----|
| Domain event definition + C# record types | 1 |
| Outbox pattern implementation (EF Core + background worker) | 3 |
| Service Bus publisher integration + retry policy (Polly) | 2 |
| Structured logging of published events | 1 |
| Unit + integration tests (Testcontainers for Service Bus emulator) | 2 |
| **Per producer** | **9 P/D** |

### Per Consumer Service

| Activity | P/D |
|----------|-----|
| Service Bus consumer registration (IHostedService / Azure Functions) | 2 |
| Idempotency check (deduplication ID / processed event log) | 2 |
| Dead letter handling + alerting | 2 |
| Compensating transaction / saga step (if transactional) | 3–6 |
| Error classification (retry vs dead-letter vs discard) | 2 |
| Unit + integration tests | 2 |
| **Per consumer** | **11–14 P/D** |

### EDA Platform Infrastructure

| Activity | P/D |
|----------|-----|
| Service Bus namespace provisioning (Bicep) | 1 |
| Topic / subscription setup with filters | 2 |
| RBAC for producer/consumer managed identities | 1 |
| Dead letter queue monitoring dashboard | 2 |
| Message replay tooling (for ops team) | 3 |
| Schema Registry setup (if used) | 2 |
| **Platform Total** | | **11 P/D** |

### EDA Estimate: 5 Producer + 8 Consumer System

```
Design & architecture:       12 P/D
5 producers × 9 P/D:         45 P/D
8 consumers × 12 P/D:        96 P/D
Platform infrastructure:     11 P/D
Testing & chaos scenarios:    8 P/D
─────────────────────────────────────
Base Total:                 172 P/D

Buffer for schema change cycles (+20%): 207 P/D
```

---

## Scenario 4 — API Platform / Azure APIM Implementation

```
// ── Designing and delivering an enterprise API layer with APIM ───────────────
// ── Covers: API design, gateway, auth, versioning, developer portal ───────────
```

### Architect's Role Here Is Heaviest

API platform work is uniquely architect-heavy. The design decisions (versioning strategy, auth mechanism, rate limit tiers, policy inheritance) have long tails. Getting them wrong costs months to undo.

### Phase Breakdown

#### API Design Phase

| Activity | Owner | P/D |
|----------|-------|-----|
| OpenAPI specification (per service) | TA + Dev | 2–4 per service |
| Versioning strategy definition (URI / header / media type) | TA | 1 |
| Error response standard (RFC 7807 Problem Details) | TA | 1 |
| Auth strategy (OAuth2 scopes, API keys, managed identity) | TA | 2 |
| Rate limiting tier design (per consumer type) | TA | 1 |
| API naming + resource model standards | TA | 1 |

#### APIM Configuration

| Activity | P/D | Notes |
|----------|-----|-------|
| APIM instance provisioning (Bicep) | 2 | SKU choice has cost implications — document the decision |
| Base policy set (auth, CORS, rate limit, logging) | 3 | Reusable policy fragments per policy type |
| Per-API import + configuration | 1.5 per API | Higher for APIs with complex transformation logic |
| Product + subscription model setup | 2 | Defines how consumers onboard |
| Developer portal customisation | 3 | Branding, documentation, try-it experience |
| Backend wiring (private endpoints / VNet integration) | 3 | Routing to AKS services or function backends |
| JWT validation + claims transformation policies | 3 | Often underestimated — policy language has a learning curve |
| Monitoring: APIM + Application Insights integration | 2 | Request tracing, latency dashboards |

#### Per API Onboarding (recurring cost — add per new API)

```
OpenAPI spec review + import:    0.5 P/D
Policy application:              0.5 P/D
Subscription / product setup:    0.5 P/D
Documentation + portal update:   0.5 P/D
──────────────────────────────────────────
Per API:                         2 P/D
```

#### API Platform — 10-API Engagement Estimate

```
Architecture & standards design:   11 P/D
APIM provisioning + base:          13 P/D
10 APIs × 2 P/D onboarding:        20 P/D
Developer portal:                   3 P/D
Testing (contract tests, APIM policies): 5 P/D
──────────────────────────────────────────────
Base Total:                        52 P/D

Note: Does not include the backend APIs themselves — only the gateway layer.
```

---

## Scenario 5 — ReactJS Frontend With Microservices Backend (BFF Pattern)

```
// ── Frontend-heavy engagement: React + Backend-for-Frontend + Azure AD auth ──
```

### Why BFF Changes the Estimate

Without BFF: React calls microservices directly. Each microservice exposes its own auth, CORS, and response shape. The frontend becomes a distributed systems coordinator.

With BFF: A single backend aggregates calls, handles auth, and returns client-optimised payloads. Frontend is clean. BFF is an additional service to build and maintain.

Always recommend BFF for enterprise frontends. Budget it explicitly.

### BFF Service Estimate

| Activity | P/D |
|----------|-----|
| BFF project setup (.NET Minimal API) | 1 |
| Auth integration (Azure AD / MSAL, token forwarding) | 3 |
| Aggregation endpoints (1–1.5 P/D each) | varies |
| Response shaping + caching (IMemoryCache / Redis) | 2 |
| Error normalisation (translate microservice errors to client-friendly) | 1 |
| Health check + observability | 1 |
| Unit + integration tests | 3 |
| **BFF Base** | **11 P/D + aggregation endpoints** |

### ReactJS Frontend Effort Table

| Component | P/D | Assumptions |
|-----------|-----|------------|
| Project scaffold (Vite, TypeScript, ESLint, Prettier) | 1 | |
| Design system / component library setup (MUI / custom) | 3 | |
| Routing setup (React Router v6, protected routes) | 2 | |
| Azure AD auth integration (MSAL React) | 3 | |
| API layer (RTK Query or React Query + Axios) | 2 | |
| Global error boundary + toast notifications | 1 | |
| Simple read-only screen (list + detail) | 1.5 per screen | |
| CRUD screen (list + form + validation) | 3–4 per screen | |
| Dashboard with charts | 4–6 | |
| Search with filters + pagination | 3 | |
| File upload screen | 3 | |
| Multi-step wizard / complex form | 5–8 | |
| Role-based UI rendering | 2 | Add once; scales across screens |
| Responsive layout audit | 2 | Per pass across full app |
| Accessibility baseline (WCAG 2.1 AA) | 3 | Often contractually required |
| E2E test suite (Playwright) | 5 | Core happy paths per feature |
| Performance audit + code splitting | 3 | Do once before go-live |

### Architect's Input on ReactJS Estimation

The most common miss: **state management scope**.

If the frontend has < 5 screens: local state + React Query is sufficient. No Redux.
If 5–15 screens with shared state: Zustand or Redux Toolkit slice.
If 15+ screens with complex cross-feature state: RTK + middleware.

Each step up adds 3–5 P/D for setup and ~20% overhead per feature. Decide the state model in Phase 0 and lock it. Changing state strategy mid-project is expensive.

---

## Scenario 6 — AKS Production Cluster Setup

```
// ── Standing up an enterprise-grade AKS cluster: not just az aks create ──────
// ── Networking, security, observability, GitOps, autoscaling — all required ───
```

### What "Production-Grade" Actually Means

A dev cluster and a production cluster are not the same infrastructure.
Teams routinely estimate the time to run `az aks create` and forget everything else.

### AKS Setup — Full Effort Breakdown

#### Networking & Access

| Activity | P/D |
|----------|-----|
| VNet design + subnet allocation (AKS, ingress, app gateway) | 2 |
| Private cluster setup (no public API server) | 2 |
| Azure CNI / Overlay networking decision + config | 1 |
| NGINX / AGIC ingress controller + TLS (cert-manager) | 3 |
| DNS integration (Azure Private DNS / custom) | 2 |
| **Networking Total** | **10 P/D** |

#### Security

| Activity | P/D |
|----------|-----|
| Azure AD integration + RBAC (cluster + namespace level) | 2 |
| Workload Identity setup (per service managed identity) | 3 |
| Key Vault CSI driver (secrets into pods without env vars) | 2 |
| Network policies (Calico — deny-all default, allow per service) | 3 |
| Pod Security Standards (restricted profile per namespace) | 2 |
| Defender for Containers / image scanning integration | 1 |
| **Security Total** | **13 P/D** |

#### Autoscaling

| Activity | P/D |
|----------|-----|
| HPA setup per deployment (CPU + memory thresholds) | 2 |
| KEDA installation + ScaledObject per Service Bus consumer | 3 |
| Cluster Autoscaler configuration + node pool sizing | 2 |
| VPA (Vertical Pod Autoscaler) — optional, document decision | 1 |
| **Autoscaling Total** | **8 P/D** |

#### Observability

| Activity | P/D |
|----------|-----|
| Azure Monitor Container Insights + log analytics workspace | 2 |
| Prometheus + Grafana stack (kube-prometheus-stack Helm) | 3 |
| Custom dashboards (cluster health, pod saturation, latency) | 3 |
| Alerting rules (pod restarts, node pressure, memory OOM) | 2 |
| Distributed tracing (OpenTelemetry collector on cluster) | 3 |
| **Observability Total** | **13 P/D** |

#### GitOps & CI/CD

| Activity | P/D |
|----------|-----|
| Helm chart per service (templated, reusable) | 2 per service |
| ArgoCD or Flux installation + repo sync setup | 3 |
| Application sets / kustomize overlays per environment | 3 |
| GitHub Actions / Azure DevOps pipeline per service | 2 per service |
| Image promotion workflow (dev → staging → prod) | 3 |
| **GitOps Base (excluding per-service)** | **9 P/D** |

#### AKS Total Estimate (Cluster Only, 6-Service System)

```
Networking:                  10 P/D
Security:                    13 P/D
Autoscaling:                  8 P/D
Observability:               13 P/D
GitOps base:                  9 P/D
Helm charts (6 × 2):         12 P/D
Pipelines (6 × 2):           12 P/D
──────────────────────────────────
Base Total:                  77 P/D

Buffer for environment parity issues (+15%): 89 P/D

Note: This is platform work only. Application code is separate.
```

---

## 12.5 — What Architects Consistently Miss Across All Scenarios

```
// ── The invisible cost list — add these to every estimate, always ────────────
```

| Item | Typical P/D | Why it gets missed |
|------|------------|-------------------|
| Architecture Decision Records (ADRs) | 2–4 | "We'll document later" — never happens |
| Local developer environment setup guide | 1 | Assumed to be trivial; costs 0.5 P/D per developer |
| Secrets management wiring (Key Vault → app) | 2–4 | Often treated as config, not as a deliverable |
| Environment parity issues (dev ≠ staging ≠ prod) | 3–8 | Always surfaces during staging deploy, never estimated |
| Data migration / seed scripts | 3–10 | Rarely on the functional backlog |
| API contract test suite (consumer-driven) | 3–5 | Skipped in favour of integration tests |
| Operational runbook for each service | 1–2 per service | "Not a feature" — but required for handover |
| Hypercare / post-go-live support window | 5–10 | "The project ends at go-live" — no it does not |
| Third-party SDK upgrade issues | 2–5 | A dependency had a breaking change nobody knew about |
| Cross-browser / cross-device testing | 2–3 | Frontend teams test one browser |
| Soft-delete / audit trail for regulated data | 3–5 | Added after the data model is built, requires rework |

---

## 12.6 — Presenting the Estimate: Architect-Level Communication

```
// ── The format that gets sign-off without endless revision cycles ────────────
```

### Structure Every Estimate With These Five Sections

```
1. SCOPE BOUNDARY
   In scope:  [explicit list]
   Out of scope: [explicit list — as important as in scope]

2. ASSUMPTIONS
   [numbered list — anything that, if wrong, changes the estimate]

3. ESTIMATE (three scenarios)
   Optimistic:  [P/D] — [calendar weeks] — assumes [key condition]
   Realistic:   [P/D] — [calendar weeks] — standard friction + 1 dependency delay
   Conservative:[P/D] — [calendar weeks] — one major dependency fails or scope grows

4. OPEN ITEMS (unknowns that are not yet estimable)
   [list each one with: what we need to know, who provides it, by when]

5. RECOMMENDATION
   "We recommend the Realistic scenario. We will flag a re-estimate trigger if
    [specific condition] occurs — e.g., if the data migration scope expands
    beyond [X] tables, or if the external API provider changes their contract."
```

### The One-Page Estimate Summary (for executive review)

```
┌──────────────────────────────────────────────────────────────────────┐
│  PROJECT: [name]         ESTIMATE DATE: [date]    VERSION: [n]       │
│  ARCHITECT: [name]       TEAM SIZE: [n]            SPRINT: 2 weeks   │
├──────────────────────────────────────────────────────────────────────┤
│  SCOPE SUMMARY                                                        │
│  [2-3 sentences: what is being built, what is not]                   │
├──────────────────────────────────────────────────────────────────────┤
│  ESTIMATE                                                             │
│  Optimistic:    [N] P/D  |  [X] sprints  |  [date]                  │
│  Realistic:     [N] P/D  |  [X] sprints  |  [date]  ← RECOMMENDED   │
│  Conservative:  [N] P/D  |  [X] sprints  |  [date]                  │
├──────────────────────────────────────────────────────────────────────┤
│  KEY ASSUMPTIONS (if these break, estimate changes)                  │
│  1. [assumption]                                                      │
│  2. [assumption]                                                      │
│  3. [assumption]                                                      │
├──────────────────────────────────────────────────────────────────────┤
│  TOP 3 RISKS                                                          │
│  1. [risk] — [mitigation]                                            │
│  2. [risk] — [mitigation]                                            │
│  3. [risk] — [mitigation]                                            │
├──────────────────────────────────────────────────────────────────────┤
│  OPEN ITEMS (unresolved — needed before final commitment)            │
│  1. [item] — needed from [person] by [date]                          │
│  2. [item] — needed from [person] by [date]                          │
├──────────────────────────────────────────────────────────────────────┤
│  SIGN-OFF                                                             │
│  Architect: ____________   Manager: ____________   Date: ___________  │
└──────────────────────────────────────────────────────────────────────┘
```

This format does three things: it makes scope explicit (preventing scope creep), it forces stakeholders to acknowledge assumptions (providing cover when assumptions break), and it frames open items as their action items (not your problem to absorb).

---

## 12.7 — Architect's Estimation Checklist (Run Before Every Estimate)

```
// ── Use this before submitting any estimate to a stakeholder ────────────────
```

```
Architecture & Scope
[ ] Have I drawn the component diagram — even a rough one?
[ ] Have I listed every system this solution integrates with?
[ ] Have I defined what is OUT of scope explicitly?
[ ] Have I identified the data stores (new + existing) the solution touches?

Effort
[ ] Have I decomposed to capability level — not just feature level?
[ ] Have I included: infrastructure, security, observability, testing, documentation?
[ ] Have I applied the right complexity multipliers (brownfield, legacy, new tech)?
[ ] Have I stated BOTH effort (P/D) AND elapsed time (calendar weeks)?
[ ] Have I accounted for my own TA time separately from the team's time?

Risk & Assumptions
[ ] Have I listed every assumption the estimate rests on?
[ ] Have I listed the open items that are not yet estimable?
[ ] Have I identified the top 3 risks with mitigations?

Communication
[ ] Have I prepared three scenarios (Optimistic / Realistic / Conservative)?
[ ] Is the one-page summary complete and ready for executive review?
[ ] Do I have a re-estimate trigger defined ("we will revisit if X happens")?

Sign-off
[ ] Has the scope been signed off before I finalise the estimate?
[ ] Are the assumptions acknowledged in writing by the relevant stakeholders?
```

An estimate submitted without this checklist complete is a guess with a professional wrapper.
