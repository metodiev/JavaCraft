-- V34 — Engineering craft and leadership.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('reading-code-effectively', 'Reading Code Effectively', 'Learn unfamiliar code by tracing entry points, reading history, and verifying understanding with small changes.', 'Junior', 25, true, 1),
    ('asking-better-technical-questions', 'Asking Better Technical Questions', 'Ask questions that give context, show what you tried, and respect the time of the people who answer.', 'Junior', 18, true, 1),
    ('writing-engineering-proposals', 'Writing Engineering Proposals', 'Write proposals that state the problem, compare options honestly, and record the decision before building.', 'Mid', 35, true, 1),
    ('estimating-work-realistically', 'Estimating Work Realistically', 'Estimate with ranges, separate effort from duration, and timebox spikes for the unknown parts.', 'Mid', 30, true, 1),
    ('code-review-culture', 'Code Review Culture', 'Treat review as shared ownership with small diffs, precise feedback, and clear blocking criteria.', 'Junior', 22, true, 1),
    ('mentoring-junior-engineers', 'Mentoring Junior Engineers', 'Grow junior engineers with deliberate pairing, stretch tasks, and feedback that is specific enough to act on.', 'Lead', 35, true, 1),
    ('on-call-healthy-practices', 'Healthy On-Call Practices', 'Design rotations that stay sustainable through actionable alerts, honest handoffs, and blameless learning.', 'Lead', 32, true, 1),
    ('blameless-incident-reviews', 'Blameless Incident Reviews', 'Run incident reviews that build shared timelines, find contributing factors, and produce verifiable actions.', 'Lead', 38, true, 1),
    ('runbooks-and-operational-readiness', 'Runbooks and Operational Readiness', 'Prepare services for operation with usable runbooks, readiness gates, and explicit ownership.', 'Mid', 30, true, 1),
    ('technical-interview-preparation', 'Technical Interview Preparation', 'Prepare for Java interviews with a structured plan covering fundamentals, coding, design, and communication.', 'Junior', 40, true, 1),
    ('writing-a-strong-cv', 'Writing a Strong CV', 'Write CV bullets that show impact with honest numbers and tailor each application without inventing facts.', 'Junior', 25, true, 1),
    ('growing-from-junior-to-senior', 'Growing from Junior to Senior', 'Widen your scope from tasks to outcomes and build feedback loops that keep your growth deliberate.', 'Junior', 28, true, 1),
    ('engineering-metrics-that-help', 'Engineering Metrics That Help', 'Use delivery metrics such as lead time and change failure rate to improve the system, not to rank people.', 'Mid', 32, true, 1),
    ('stakeholder-communication', 'Stakeholder Communication', 'Translate engineering reality into business terms, set expectations early, and decline requests constructively.', 'Mid', 28, true, 1),
    ('documentation-and-knowledge-sharing', 'Documentation and Knowledge Sharing', 'Keep documentation and shared sessions alive through ownership, decision logs, and a real onboarding path.', 'Junior', 26, true, 1),
    ('career-ladders-and-growth-plans', 'Career Ladders and Growth Plans', 'Use competency frameworks to assess evidence, close gaps, and choose your next role deliberately.', 'Mid', 30, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('reading-code-effectively', 1, 'Start from an entry point', $body$Unfamiliar code is easier to learn by following execution than by reading files in directory order. Find a real entry point: an HTTP controller method, a scheduled job, a message listener, or the main method. Trace one concrete request or job through the layers it touches, writing down the classes you meet and what each one decides. This builds a causal map of the system instead of a pile of unrelated impressions. The main pitfall is starting with the largest or most central-looking class, which usually belongs to framework plumbing or shared utilities and answers no question on its own. Rule of thumb: begin from behavior you can describe in one sentence.$body$, $code$- Pick one real entry point: controller, job, listener, or main.
- Follow one request until it leaves the codebase.
- Write down each class and the decision it owns.
- Mark the seams: database calls, HTTP clients, queues.
- List questions you cannot answer yet.
- Only then open shared utilities.$code$),
    ('reading-code-effectively', 2, 'Use version history as context', $body$Version history explains decisions that the code cannot. A strange null check, a retry loop, or a duplicated branch usually traces to a past incident, a migration, or a constraint that still exists. Use `git log` and `git blame` on the lines you are questioning, and read the commit message and any linked issue. This turns guessing into evidence and stops you from deleting protection that someone added deliberately. The pitfall is treating history as absolute truth: old workarounds may be obsolete after the dependency or platform changed. Rule of thumb: verify the constraint still holds before you simplify anything.$body$, $code$# Trace why a line exists before deciding it is wrong.
git log --follow -- src/main/java/.../PaymentService.java
git blame -L 40,55 src/main/java/.../PaymentService.java
# Read the linked issue or pull request for that commit.
# Confirm the constraint still applies before removing protection.
# Record what you learn in the pull request description.$code$),
    ('reading-code-effectively', 3, 'Verify understanding by changing something', $body$Reading creates the feeling of understanding long before it creates real understanding. Test yours with a small, reversible change: add a log line, rename a poorly named method, or write a test that pins current behavior. Running the system or the test suite surfaces assumptions you did not know you had. Explaining the flow to a teammate, or writing a short summary for the next reader, exposes gaps just as effectively. The pitfall is making a large change in the middle of exploring, which mixes learning with risk. Rule of thumb: convert one uncertain area into a test or a written note before touching behavior.$body$, $code$// Pin current behavior in a test before you change anything.
@Test
void refundAboveCapturedAmountIsRejected() {
    // Arrange a captured payment, then attempt an oversized refund.
    // Assert the exact exception and message the code throws today.
}$code$),
    ('asking-better-technical-questions', 1, 'State the goal and the obstacle', $body$A good question lets someone help without reconstructing your situation. State the goal, the observed behavior, the expected behavior, and the smallest input that shows the difference. Include versions, exact commands, and full error text rather than your interpretation of it. Say what you already ruled out and why. This respects the time of the person answering and often reveals the answer while you write. The common pitfall is pasting an entire file or a vague symptom such as does not work, which forces a long back-and-forth before real diagnosis can start. Rule of thumb: if a careful reader cannot reproduce your problem in a few minutes, add detail.$body$, $code$Goal: import a CSV of orders without duplicate rows.
Observed: the second import inserts duplicates; no error is logged.
Expected: duplicate order ids are skipped or reported.
Environment: Java 21, PostgreSQL 16, app version 2.4.0.
Tried: checked the unique index, added logging around the insert.
Minimal repro: attached 6-row CSV and the exact command used.$code$),
    ('asking-better-technical-questions', 2, 'Show what you tried and ruled out', $body$Listing what you already tried saves your helper from suggesting the same steps and shows the reasoning you have built. Group attempts as hypotheses: you suspected a stale cache, you cleared it, and the behavior did not change. Paste actual command output and stack traces, not a summary, because small details such as one warning line are often the clue. If you found a workaround, describe it and why it is not acceptable as the real fix. The pitfall is presenting a single symptom with no evidence trail, which turns debugging into guessing. Rule of thumb: every question includes at least one hypothesis and the evidence that supports or rejects it.$body$, $code$Hypothesis: a stale connection pool causes the timeouts.
Test: restarted the app; the first requests still timeout.
Evidence: pool metrics show every connection idle.
Hypothesis: DNS resolves inconsistently inside the cluster.
Test: ran dig and curl against the same host from the pod.
Evidence: one host resolves, the other times out.$code$),
    ('asking-better-technical-questions', 3, 'Choose the right channel and timing', $body$Where you ask matters as much as what you ask. Team channels and issue trackers create a searchable record that helps the next person with the same problem, while private messages create knowledge that disappears. Reserve direct messages for sensitive matters or for people who have explicitly offered to be interrupted. Batch non-urgent questions instead of sending them one at a time, and include enough detail that someone can answer asynchronously in another time zone. The pitfall is opening with a bare greeting and waiting for a reply before stating the question, which costs a full round trip. Rule of thumb: ask in the most public place that is still appropriate.$body$, $code$1. Post in the team channel by default; use DMs only for sensitive topics.
2. One message with complete context, no "can I ask a question?" preamble.
3. Tag the code owner only when the channel is quiet or the issue is urgent.
4. Batch follow-ups instead of pinging every few minutes.
5. When you solve it yourself, post the answer in the same thread.
6. Move resolved questions into the docs or a pinned note.$code$),
    ('writing-engineering-proposals', 1, 'Frame the problem before the solution', $body$A proposal starts with the problem, not the technology. Describe the current situation, who is affected, and what a successful outcome looks like in observable terms. List explicit non-goals to bound the discussion, because most stalled proposals argue about scope rather than design. Quantify constraints where you can: traffic, data volume, budget ceiling, compliance deadlines, team capacity. The pitfall is presenting a solution first and backfilling justification, which hides alternatives and makes reviewers defensive. Rule of thumb: if the problem statement still makes sense after you remove every technology name, it is specific enough to evaluate.$body$, $code$# Proposal: Introduce a read replica for reporting queries
## Problem
Monthly reports lock tables and slow the checkout path.
## Goals
- Reporting reads must not delay checkout writes.
- Report p95 completes within the previous business-day window.
## Non-goals
- Real-time reporting and warehouse replacement are out of scope.
## Constraints
- No new vendor; the existing operations team must support it.$code$),
    ('writing-engineering-proposals', 2, 'Present options with honest trade-offs', $body$Reviewers cannot choose between one option and nothing. Present two or three credible approaches, including doing nothing or the smallest possible change, and compare them on criteria that matter: cost, complexity, operational load, reversibility, and time to first value. Write the strongest honest case for each option, including the one you do not recommend. State your assumptions and the evidence behind them, and note what would change your mind. The pitfall is making alternatives deliberately weak, which experienced readers notice and which weakens trust in the whole document. Rule of thumb: a good comparison lets a skeptical reader explain why someone reasonable might choose differently.$body$, $code$| Option | Cost | Risk | Reversibility | Time to value |
|--------|------|------|---------------|---------------|
| A. Read replica | Medium | Replication lag | High | 3 weeks |
| B. Async report jobs | Low | Stale data | High | 2 weeks |
| C. Do nothing | None | Contention grows | n/a | n/a |
Assumption: report volume doubles next year.
Evidence: peak lock waits measured during month-end close.$code$),
    ('writing-engineering-proposals', 3, 'Record the decision and get alignment', $body$A proposal becomes useful when it turns into a decision with a name, a date, and an owner. Record which option was chosen, why, who approved it, and what would trigger a revisit. Circulate the draft before writing production code so affected people can object while changing course is still cheap. Include the teams that will operate, fund, or depend on the result, because approval from one architect is not alignment. The pitfall is treating the document as paperwork after implementation has started, which turns review into notification. Rule of thumb: no large build begins before the decision record and its open questions are visible to everyone involved.$body$, $code$## Decision
Adopt option B: scheduled read-only jobs against a replica.
## Status
Accepted on 2026-09-14. Owner: platform team.
## Consequences
- Reports may lag by up to 15 minutes.
- Analytics needs a documented freshness note.
## Revisit trigger
Replica lag exceeds 5 minutes during month-end close.$code$),
    ('estimating-work-realistically', 1, 'Separate effort from duration', $body$Effort is the work a task requires in focused person-days; duration is the calendar time until it ships, including code review, deployment windows, dependencies, and interruption. Confusing the two produces plans that assume one engineer works on one thing and nothing queues behind it. When you give an estimate, say which one you mean and what it assumes: reviewer availability, environments, access to systems, and the size of the change. The pitfall is quoting a single number with no units or assumptions, which invites later disagreement about what you promised. Rule of thumb: every estimate names its unit, its assumptions, and its biggest source of uncertainty.$body$, $code$Task: migrate order search to the new index.
Effort: 4 to 6 focused person-days.
Duration: 2 to 3 calendar weeks.
Assumes: reviewer availability within one day, staging index built.
Largest uncertainty: backfill duration at production scale.$code$),
    ('estimating-work-realistically', 2, 'Use ranges and spike unknowns', $body$Give ranges and explain what they mean: the low end assumes nothing surprising, the high end accounts for realistic friction. Precision such as three and a half days is false comfort when key facts are missing. When the range is wide because of one unknown, propose a timeboxed spike: a small, fixed investigation that answers a specific question and produces a written finding. After the spike, re-estimate with evidence. The pitfall is guessing through a genuine unknown and discovering the surprise late, when schedule pressure is highest. Rule of thumb: if the range spans more than double, stop estimating and name the spike that would narrow it.$body$, $code$Spike: can the current index support 5M-row backfills?
Timebox: one day.
Question: measure backfill throughput with production-like data.
Deliverable: numbers plus a go or no-go recommendation.
Out of scope: building the migration itself.
Follow-up: re-estimate the migration afterwards.$code$),
    ('estimating-work-realistically', 3, 'Update estimates with evidence', $body$An estimate is a forecast, not a commitment carved in stone. Revisit it at natural checkpoints such as the end of a spike, the first merged change, or a dependency slip, and publish the revised number with the reason. Stakeholders can absorb bad news early and adjust scope, sequence, or staffing; they cannot absorb it the day before a release. Track how your estimates compare with actuals over time so you learn your own correction factor. The pitfall is staying silent while the forecast decays, which destroys trust faster than the slip itself. Rule of thumb: update the estimate in the same channel where you first published it.$body$, $code$Original: phase two done by October 17.
Update: October 31 after the schema review found two legacy writers.
Change since last update: backfill depends on the writer cleanup ticket.
Options: ship search only, or keep both paths until cleanup lands.
Decision needed by: October 10 to protect the release train.
Confidence now: medium, based on the spike and two similar migrations.$code$),
    ('code-review-culture', 1, 'Review as shared ownership', $body$Code review is how a team keeps shared ownership of the codebase, not a grading ritual for individuals. The reviewer checks correctness, clarity, and risk; the author keeps responsibility for the result. Keep changes small enough to review carefully in one sitting, because large diffs get superficial approval and hide real defects. Distinguish questions from required changes, and explain the reasoning behind a request instead of asserting authority. The pitfall is treating review as a style tribunal, which trains people to defend code rather than examine it. Rule of thumb: every comment should help the author ship a better change or learn something specific.$body$, $code$Required: this null check is unreachable; the request contract rejects null earlier.
Question: does the retry re-send the idempotency key? I could not tell from the diff.
Suggestion (optional): extracting the mapping would make this test easier to read.
Praise: the migration test with legacy rows is exactly what we needed.
Nit: prefer Locale.ROOT here to avoid locale-dependent casing.
Take your pick on naming; this is not blocking.$code$),
    ('code-review-culture', 2, 'Separate taste from correctness', $body$Not every review comment deserves the same weight. Label them: correctness problems such as data loss, security gaps, or broken behavior must block; questions ask for understanding; preferences about naming or structure are optional and should say so. Without labels a reader cannot tell whether a suggestion requires rework or is a passing thought. When you disagree on taste and both options work, the author decides, because they own the change and its maintenance. The pitfall is spending review energy on formatting while missing logic errors, or blocking delivery over style. Rule of thumb: state which comments are blocking and which the author may decline.$body$, $code$Blocking:
- The update path can overwrite a concurrent edit; needs a version check.
Non-blocking:
- Consider a named constant for the 30-second window.
- Optional: split the 120-line test into two focused cases.$code$),
    ('code-review-culture', 3, 'Keep feedback kind and precise', $body$Review feedback lands when it is specific, observational, and about the code. Instead of asking why it was written a certain way, describe the risk you see and suggest a concrete alternative. Avoid sarcasm and absolutes such as always and never; they turn a technical point into a personal one. As a reviewer, respond promptly, even if only to say when you will get to it, because the author is blocked. As an author, treat comments as questions about the change rather than judgments of your ability. The pitfall is letting tone drift under deadline pressure. Rule of thumb: write the comment you would want to receive on your own change.$body$, $code$Instead of: "Why did you do it this way?"
Try: "If two requests arrive together, both read the same version and one
update is lost. A version check in the WHERE clause would prevent that."
Instead of: "This will never work."
Try: "This fails when the list is empty; see the failing case on line 42."$code$),
    ('mentoring-junior-engineers', 1, 'Pair with clear driver and navigator', $body$In a pairing session the driver writes code while the navigator thinks ahead about tests, edge cases, and design, and the two swap roles on a timer so both stay engaged. Let the junior drive often, even when it is slower, because producing your own solution is how practical fluency forms. Narrate your reasoning when you do take the keyboard, especially at decision points that are invisible in the finished diff. Silence from a mentor reads as judgment, so ask questions instead of issuing verdicts. The pitfall is grabbing the keyboard the moment progress slows, which teaches the junior to wait for rescue rather than think aloud. Rule of thumb: the junior should explain the next step before you do.$body$, $code$Pairing session agenda, 90 minutes:
- 10 min: agree on one small, verifiable goal.
- 60 min: junior drives; mentor navigates and asks questions.
- Swap roles every 20 minutes; both talk through decisions.
- 10 min: run the tests together, fix what fails.
- 10 min: write down what was learned and open questions.
Mentor rule: do not take the keyboard unless invited.$code$),
    ('mentoring-junior-engineers', 2, 'Scaffold tasks at the edge of ability', $body$Growth happens when a task stretches someone slightly beyond comfortable ground but still has a safety net. Choose work that carries real value and a bounded blast radius: a well-tested component, a change behind a flag, or a fix with clear acceptance criteria. Write down the definition of done, the support available, and the checkpoints where you will review progress together. Resist handing over only low-value chores, and equally resist dropping a junior alone into a production incident. The pitfall is a task so vague or so large that the junior cannot tell whether they are on track until it is too late. Rule of thumb: pick work the junior can finish with one or two focused questions.$body$, $code$Task: add pagination to the audit log endpoint.
Definition of done: contract tests pass; existing callers unaffected.
Safety net: feature flag, review before merge, no schema changes.
Support: mentor available 30 minutes daily; runbook linked.
Checkpoints: day 1 design sketch, day 3 draft pull request.
Stretch element: choose the default page size with a short rationale.$code$),
    ('mentoring-junior-engineers', 3, 'Give feedback that lands', $body$Useful feedback is specific, timely, and about observable behavior rather than personality. Describe the situation, what you observed, the impact it had, and what you would like instead. Ask the person to assess their own work first; they often name the same issue, which makes the conversation collaborative instead of corrective. Give constructive feedback privately and credit publicly. Avoid saving a list of complaints for an annual review, when the moment to adjust has long passed. The pitfall is vague guidance such as be more proactive, which gives no behavior to change. Rule of thumb: one behavior, one impact, one concrete request, delivered close to the event.$body$, $code$Situation: yesterday incident, payment timeouts.
Observation: the first customer update went out two hours after detection.
Impact: support answered questions with no information.
Request: send a short holding update within 30 minutes, even without a cause.
Ask first: how did the communication feel from your side?
Close: agree on a specific next time and follow up later.$code$),
    ('on-call-healthy-practices', 1, 'Design a sustainable rotation', $body$A sustainable rotation gives enough people that no individual is paged every night, defines clear primary and secondary roles, and publishes an escalation path that does not depend on one hero. Keep rotation length long enough to let people rest between shifts and short enough that skills stay fresh, and make sure everyone has runbook access, dashboards, and the authority to mitigate. Handoffs should transfer open incidents, known risks, and recent changes, not just a pager. The pitfall is a rotation of one or two volunteers who absorb every page until they burn out and quit. Rule of thumb: if a rotation cannot survive one person taking leave, it is not sustainable.$body$, $code$Rotation checklist:
- At least six engineers eligible; two per shift (primary and secondary).
- One-week shifts with automatic calendar handoff notes.
- Documented escalation path with named backups.
- Same runbook and alert access for everyone on call.
- Post-shift review: page count, sleep interruptions, false alarms.
- Time off in the following days after a severe incident night.$code$),
    ('on-call-healthy-practices', 2, 'Make every alert actionable', $body$A page should mean a user is being harmed or will be soon, and it should require a human decision that cannot wait. Each alert needs a clear owner, a symptom-based signal tied to user impact, and a runbook that starts with what the responder sees and what to do first. Route everything else to tickets or dashboards. Review pages after every shift and delete or retune alerts that never require action, because noise trains people to ignore real signals. The pitfall is paging on causes such as CPU usage instead of effects such as failed checkouts, which wakes people for conditions that may be harmless. Rule of thumb: if no human action is needed right now, it belongs in a ticket.$body$, $code$Alert: checkout error ratio above 2 percent for 5 minutes.
Why paged: users cannot complete purchases; target is under 1 percent.
Owner: payments team.
Runbook: link in the alert description, first section lists first checks.
Action expected: inspect recent deploys, then drain or roll back.
Not paged: CPU above 70 percent, disk usage, single retry failures.
Those become dashboard panels or weekly tickets.$code$),
    ('on-call-healthy-practices', 3, 'Hand off and learn without blame', $body$Shift handoffs should be explicit: summarize open incidents, changes made, risky deploys, and anything that nearly failed. After a page or an incident, capture what made it hard to diagnose and feed that back into alerts, runbooks, and tests. Nobody should be blamed for a page they received, because the conditions that caused it were built into the system long before. Managers track page load, after-hours interruptions, and toil, and fund fixes for the top recurring causes. The pitfall is measuring on-call health by how calmly people endure chaos instead of by how much chaos remains. Rule of thumb: every painful page should produce one lasting improvement.$body$, $code$Handoff note template:
- Open incidents and their current mitigation state.
- Changes deployed during the shift and expected effects.
- Alerts that fired but were not actionable; suspected noise.
- Approaching risk: expiring certificates, low capacity, pending migrations.
- One improvement proposed from this shift, with a ticket link.
Next responder acknowledges by replying in the handoff thread.$code$),
    ('blameless-incident-reviews', 1, 'Build a shared timeline first', $body$Before anyone analyzes causes, assemble a common timeline from alerts, deploy logs, tickets, dashboards, and chat messages, and mark the moments when responders noticed, decided, and acted. Multiple people remember different parts, so a joint reconstruction corrects gaps and assumptions. Write the timeline without adjectives or judgments: what happened, at what time, and what information was available then. Only after the facts are agreed should the group move to why the system made the outcome likely. The pitfall is jumping straight to root cause and to a name, which stops the investigation and teaches people to hide information next time. Rule of thumb: agree on what happened before debating why it happened.$body$, $code$Timeline excerpts:
14:02 deploy of order-service 2.4.1 completes.
14:09 first alert: checkout error ratio above threshold.
14:11 on-call acknowledges, checks dashboards, sees DB connection errors.
14:18 rollback decision made; rollback begins.
14:26 error ratio returns to baseline.
14:30 incident channel closed; follow-up review scheduled.
Source for each line: alert history, deploy log, chat export.$code$),
    ('blameless-incident-reviews', 2, 'Find contributing factors, not culprits', $body$Real incidents usually emerge from several reinforcing conditions: a fragile dependency, a missing guardrail, a busy period, unclear documentation, and a reasonable decision made with incomplete information. Assume people acted sensibly given what they could see at the time, and ask what made the wrong action seem correct. Map technical, process, and organizational contributors instead of stopping at the first plausible cause. A review that names a person as the root cause ends learning and encourages silence. The pitfall is treating one operator error as the whole story when the system allowed a single mistake to reach users. Rule of thumb: for every human action, ask what system condition made it reasonable and what guardrail would have contained it.$body$, $code$Contributing factors for the checkout incident:
- Deploy included a migration without a compatibility check.
- Staging dataset did not exercise the new connection path.
- Runbook described the old pool settings.
- Deploy window overlapped month-end traffic peak.
- Rollback had never been rehearsed under load.
Each factor gets an owner and a candidate countermeasure, not a name.$code$),
    ('blameless-incident-reviews', 3, 'Write actions that reduce recurrence', $body$Each review should end with a small set of actions that are specific, owned, dated, and verifiable. Prefer fixes that change the system: add the missing test, automate the guardrail, adjust the alert, rehearse the rollback. Distinguish detection improvements from prevention and mitigation, because faster detection and safer recovery often matter more than finding an exotic cause. Track actions to completion in the normal planning process, and revisit whether they actually reduced recurrence. The pitfall is a long list of vague intentions such as be more careful, which cannot be checked and quietly disappears. Rule of thumb: every action must state the evidence that will prove it is done.$body$, $code$Action: add a migration compatibility test to the deploy pipeline.
Owner: platform team. Due: 2026-10-20.
Evidence: pipeline fails when a new column breaks the old reader.
Action: update the connection pool section of the checkout runbook.
Owner: payments team. Due: 2026-10-13.
Evidence: reviewer signs off after a failed-over drill.
Maximum five actions per review; the rest become backlog candidates.$code$),
    ('runbooks-and-operational-readiness', 1, 'What a usable runbook contains', $body$A runbook is written for a tired responder who has never seen this service. It starts with the symptoms that lead here, then links the dashboards and logs needed to confirm the problem, then lists diagnosis steps and safe mitigations with exact commands. It names the escalation path, explains how to roll back, and records the last time someone verified it. Keep it short enough to scan under pressure and store it where the alert links. The pitfall is writing a runbook as architecture prose that never gets tested until an incident, when its gaps are discovered the hard way. Rule of thumb: a responder unfamiliar with the service should be able to follow it at 3 a.m.$body$, $code$Runbook sections:
1. Symptoms: what alerts or reports bring you here.
2. Confirm: dashboards and queries that verify the condition.
3. Diagnose: ordered checks, each with expected healthy output.
4. Mitigate: exact commands, risks, and when to escalate instead.
5. Roll back: last known good version and verification steps.
6. Escalate: names, channels, and response expectations.
7. Last verified: date and who tested it.
$code$),
    ('runbooks-and-operational-readiness', 2, 'Run a readiness checklist before launch', $body$Before a service takes real traffic, confirm the operational basics: service-level objectives, dashboards, actionable alerts, a tested runbook, load test results, rollback procedure, capacity headroom, and a named owner. Check dependencies too, including quotas, certificates, and third-party limits that expire silently. Review the checklist with the team that will answer the pager, not only the team that wrote the code. The pitfall is launching while dashboards and alert ownership are still future work, so the first real incident is also the first time anyone observes the system. Rule of thumb: no launch without an owner, a runbook, and someone who has watched the metrics under load.$body$, $code$Launch readiness checklist:
- [ ] SLIs and alert thresholds agreed with the owning team.
- [ ] Dashboards exist for traffic, errors, latency, saturation.
- [ ] Runbook written and exercised in a game day or drill.
- [ ] Load test at expected peak plus 50 percent headroom.
- [ ] Rollback rehearsed; previous version still deployable.
- [ ] Dependency quotas, certificates, and limits checked.
- [ ] Named owner and escalation path recorded.
- [ ] Post-launch review scheduled for day 7.$code$),
    ('runbooks-and-operational-readiness', 3, 'Assign ownership after launch', $body$Operational readiness is not a one-time gate. Every service needs a named owning team, a stated maintenance expectation, and a review cadence for alerts, runbooks, and dependencies. When ownership changes, hand over dashboards, runbooks, and on-call expectations explicitly rather than assuming the new team will discover them. Retire services deliberately: decide when something is deprecated, announce it, and remove it. The pitfall is orphaned services that everyone assumes someone else watches, which fail quietly and surprise the organization. Rule of thumb: if nobody can say who owns a service and when it was last reviewed, treat that as an incident waiting to happen.$body$, $code$Service ownership record:
- Service: checkout-api
- Owner team: payments
- On-call: rotation link; escalation in the runbook
- Review cadence: alerts monthly, runbook quarterly, dependencies quarterly
- Last review: 2026-09-30; next: 2026-12-31
- Deprecation: not planned; revisit when the new checkout ships$code$),
    ('technical-interview-preparation', 1, 'Plan around Java fundamentals', $body$Interviews reward depth in a few areas more than shallow recall of everything. Build a plan around core topics for production Java roles: collections and their costs, exceptions and resource handling, generics, the memory model and garbage collection basics, concurrency primitives, and common JVM tooling. Study a small set deeply enough to explain trade-offs and failure modes, and practice explaining each topic aloud in two minutes. Space the practice across weeks and revisit weak areas instead of rereading what you already know. The pitfall is memorizing trivia lists, which collapse under the first follow-up question. Rule of thumb: for every topic, be ready to say when you would choose it and when you would not.$body$, $code$Six-week study plan, 5 hours per week:
- Week 1: collections, complexity, and iteration pitfalls.
- Week 2: exceptions, try-with-resources, and error contracts.
- Week 3: generics, wildcards, and type erasure basics.
- Week 4: threads, executors, and synchronization.
- Week 5: JVM memory, GC pauses, and profiling basics.
- Week 6: mock interviews and weak-area review.
Each week ends with a two-minute spoken summary per topic.$code$),
    ('technical-interview-preparation', 2, 'Practice coding and explanation together', $body$Interview coding is a communication exercise as much as a problem-solving one. Practice the full loop: restate the problem, ask clarifying questions, work through a small example, describe a simple approach, improve it, then test it against edge cases. Talk while you type or write, because a silent candidate gives the interviewer nothing to evaluate. Use a timer and mixed problem sets, and review each attempt for the reasoning you skipped rather than only the final answer. The pitfall is rehearsing alone in silence, which builds habits that fall apart the moment someone watches. Rule of thumb: rehearse explaining each decision as you make it.$body$, $code$Problem-solving script to practice aloud:
1. Restate the problem in your own words; confirm inputs and outputs.
2. Ask about size, ranges, duplicates, and error expectations.
3. Trace one small example by hand before coding.
4. State a brute-force approach, then the intended one and its complexity.
5. Code with meaningful names; keep talking at each decision.
6. Test normal, empty, single-element, and boundary cases.
7. Summarize trade-offs and what you would change with more time.$code$),
    ('technical-interview-preparation', 3, 'Prepare design answers and stories', $body$System design interviews test structured thinking, not memorized architectures. Practice a repeatable frame: clarify requirements and scale, sketch the core data flow, choose storage and interfaces, then dive into the parts the interviewer cares about while stating trade-offs and failure behavior. Behavioral questions deserve the same preparation; collect real stories about conflict, failure, and leadership, and practice telling them concisely with situation, action, and result. Admit what you do not know instead of bluffing, and reason from principles. The pitfall is presenting a solution before understanding the constraints, or recycling a story that does not answer the question. Rule of thumb: spend the first minutes asking, the middle minutes designing, and the last minutes examining trade-offs.$body$, $code$Story bank for behavioral questions:
- A production incident I helped resolve, and what I changed after.
- A disagreement with a teammate and how we reached a decision.
- A project I estimated wrong and how I corrected course.
- A time I mentored someone and what they shipped.
- A trade-off I made between speed and quality, with the outcome.
For each: 90 seconds, concrete facts, one lesson learned.$code$),
    ('writing-a-strong-cv', 1, 'Write bullets that show impact', $body$Recruiters scan for outcomes, not duties. Write each bullet as a short statement of what you did, the scope or scale you did it at, and the result it produced. Start with a strong verb, keep one idea per bullet, and prefer concrete technology names over vague phrases when they are relevant to the role. Replace descriptions of responsibilities with evidence of results: a service shipped, a failure reduced, a process simplified. The pitfall is listing everything you were nominally responsible for, which forces the reader to guess what you actually contributed. Rule of thumb: for every bullet, ask so what changed because you did this.$body$, $code$Weak: Responsible for maintaining the internal billing service.
Strong: Reduced billing job failures by adding idempotent retries and
alerting; duplicate charges dropped from weekly to near zero.
Weak: Worked on API performance.
Strong: Cut order API p95 latency by introducing a covering index and
removing an N+1 query path used on the checkout page.
Each bullet: action, scope, measurable result.$code$),
    ('writing-a-strong-cv', 2, 'Quantify outcomes honestly', $body$Numbers make impact legible: latency reduced, incidents prevented, hours saved, revenue or cost affected, users served. Use the real measurements you already track, and when you only have approximations, say so with a range and a qualifier such as about or roughly. Never inflate a title, a team size, or a result, because interviewers probe the numbers you present and a single exaggeration can end the process. Keep a private brag document throughout the year so you have facts when you need them. The pitfall is inventing a precise percentage to sound impressive, which is both dishonest and easy to disprove. Rule of thumb: if you cannot describe how you measured it, rewrite the bullet without the number.$body$, $code$Keep a running evidence file:
- 2026-03: cut nightly batch window from 6h to 90m (measured in job logs).
- 2026-05: led migration of 40 services to the new config store (team list).
- 2026-08: on-call pages for my service fell about 60 percent quarter over quarter.
- 2026-09: mentored two interns; both returned offers accepted.
Numbers you cannot measure: describe the change and scope plainly instead.$code$),
    ('writing-a-strong-cv', 3, 'Tailor without inventing experience', $body$Tailoring means choosing which true facts to emphasize, reordering bullets so the most relevant work comes first, and mirroring the vocabulary of the job description when it accurately describes what you did. It never means claiming skills you lack or rewording duties into fabricated achievements. Read each posting carefully, map your real experience to its stated needs, and drop material that adds no signal for that role. Keep the format simple and parseable: standard headings, no tables or graphics, consistent dates. The pitfall is sending one generic version everywhere, which reads as uninterested, or padding to look senior. Rule of thumb: change emphasis freely, never change facts.$body$, $code$Tailoring pass for a platform engineering role:
1. Move infrastructure, reliability, and automation work to the top.
2. Mirror the posting terms you can honestly claim: Kubernetes, Terraform, SLOs.
3. Drop unrelated frontend detail to a single line or remove it.
4. Add one line connecting recent work to their stated platform goals.
5. Check dates, titles, and team sizes against your records.
6. Export a plain text version and verify it parses cleanly.$code$),
    ('growing-from-junior-to-senior', 1, 'Widen scope from tasks to outcomes', $body$A junior career is built on completing well-defined tasks correctly; senior work means owning outcomes that no ticket fully describes. Ask what user or business result the work serves, define what done means, and anticipate the parts nobody wrote down: operability, cost, migration, documentation, and the questions support will receive. Volunteer for ambiguous problems, because scope grows through evidence that you can create clarity for others. The pitfall is waiting for perfectly specified tickets, which keeps your contribution capped at execution. Rule of thumb: before starting significant work, be able to state the outcome and how anyone will know it was achieved.$body$, $code$Before starting a feature, write answers to:
- What user or business outcome does this change serve?
- How will we observe success or failure after release?
- What happens during rollout, and what is the rollback?
- Who operates this, and what documentation or alerts do they need?
- What did I have to assume, and how will I validate it?
Bring these answers to refinement instead of asking for a full spec.$code$),
    ('growing-from-junior-to-senior', 2, 'Exercise judgement over raw output', $body$Seniority shows in decisions about what not to build and when good enough is genuinely good enough. Compare options by cost, reversibility, and risk rather than by elegance, and say plainly which trade-off you are choosing and why. Sometimes the right answer is a quick fix that unblocks users; sometimes it is slowing down to protect an invariant. Know when to disagree and commit after a decision is made, and when to escalate a risk to someone who owns the trade-off. The pitfall is either gold-plating a throwaway tool or shipping fragile work at full speed because the schedule looked tight. Rule of thumb: make the trade-off visible, and match rigor to consequence.$body$, $code$Decision note for a small internal tool:
Option A: one-day script with manual cleanup. Reversible, low cost, no UI.
Option B: two-week service with auth and dashboards.
Context: used by one team for three months; data is not customer-facing.
Decision: option A, with a documented owner and a review in 90 days.
If usage spreads or data becomes sensitive, revisit with option B criteria.$code$),
    ('growing-from-junior-to-senior', 3, 'Build deliberate feedback loops', $body$Growth accelerates when feedback is routine rather than annual. Ask specific questions after a project: what would have made my design review easier, where did I create rework, what should I keep doing. Seek input from peers, not only your manager, and check it against evidence such as review comments, incident outcomes, and delivery timelines. Write short summaries after milestones to practice judgment and create a record for future interviews. The pitfall is interpreting one piece of criticism as a verdict on your ability, or collecting feedback without ever choosing a change. Rule of thumb: after each major piece of work, name one thing you will do differently next time and tell someone.$body$, $code$Post-project feedback prompts, asked in person:
- Where did my work create extra work for you?
- What information did I leave out that you needed?
- Which of my decisions would you have made differently, and why?
- What should I keep doing exactly as it is?
Write down the answers; pick at most two changes for the next project.
Share those changes with your manager in the next one-on-one.$code$),
    ('engineering-metrics-that-help', 1, 'Use delivery metrics as system signals', $body$The widely used DORA metrics describe software delivery performance through four measurements: deployment frequency, lead time from change to production, change failure rate, and time to restore service after a failure. Together they show whether a team can deliver changes quickly and recover safely, and they are most useful as trends for a service or team, never as a ranking of individuals. Pair them with service-level objectives and user outcomes so speed never becomes an end in itself. The pitfall is adopting the numbers as targets and watching behavior bend toward the metric. Rule of thumb: a good metric prompts a conversation about a system constraint and a candidate experiment.$body$, $code$Monthly delivery review, one page:
- Deployment frequency: how often this service reaches production.
- Lead time: median and 90th percentile from first commit to production.
- Change failure rate: share of deployments causing degraded service.
- Time to restore: median duration of user-visible incidents.
Add context: major migrations, holidays, and staffing changes.$code$),
    ('engineering-metrics-that-help', 2, 'Measure lead time and failure rate carefully', $body$Define each metric precisely before collecting it, because loose definitions produce arguments instead of insight. Lead time should state the start point and end point, for example from first commit on a merge request to running in production, and should be computed from pipeline events rather than memory. Change failure rate counts deployments that caused degraded service or required immediate remediation, divided by total deployments; automated detection makes it more honest than self-reporting. Segment by service to find bottlenecks, and remember that smaller batches can flatter cycle metrics while quality stays flat. The pitfall is debating definitions after the numbers arrive and losing the improvement discussion. Rule of thumb: write the definition and its data source next to the chart.$body$, $code$Lead time, change delivery definition:
- Start: first commit pushed to the merge request.
- End: deployment to production marked complete.
- Source: CI and deployment pipeline events.
- Reported: median and 90th percentile, per service, weekly.
Change failure rate:
- Numerator: deployments causing user-visible degradation or rollback.
- Denominator: all production deployments in the period.
- Source: incident records linked to deployment identifiers.$code$),
    ('engineering-metrics-that-help', 3, 'Avoid vanity metrics and misuse', $body$Some numbers feel satisfying but guide nothing: lines of code, commit counts, hours online, or story points compared across teams. Once a metric is used to judge individuals, people learn to optimize the number instead of the outcome, and the measurement quietly stops reflecting reality. Keep delivery metrics at the team or service level, combine them with qualitative context from retrospectives and incidents, and treat every metric as a clue that needs a story. Ask what decision a metric would change; if there is no plausible decision, stop collecting it. The pitfall is presenting dashboards as scoreboards, which turns improvement work into self-defense. Rule of thumb: metrics inform experiments, not performance reviews.$body$, $code$Questions before adding a metric:
- What decision or experiment would this number change?
- Who could be harmed or tempted to game it if it were compared?
- Does it measure a system property rather than a person?
- Can it be collected automatically without extra manual reporting?
- Will we still find it meaningful in six months?
If any answer is unclear, measure something closer to user outcomes.$code$),
    ('stakeholder-communication', 1, 'Translate engineering into business language', $body$Stakeholders make decisions with the information you give them, so speak in terms of impact, risk, cost, and time rather than framework names and internal architecture. Explain what a change means for users, revenue, reliability, or compliance, and name the trade-offs in plain words. Bad news is easier to absorb early: state the problem, its likely impact, the options you see, and what you need from the listener. Keep a written risk list so expectations do not depend on who attended which meeting. The pitfall is reporting activity such as percent complete while the actual outcome drifts out of reach. Rule of thumb: lead with the impact and the decision you need, then supply technical depth if asked.$body$, $code$Weekly status, three bullets:
- Outcome: checkout reliability work is on track for the October window.
- Risk: a legacy payment client still lacks a sandbox; if unresolved by Friday,
  the integration test phase moves one week.
- Decision needed: approve the temporary test double for that client, or delay.
Attach the technical detail as an appendix for anyone who wants it.$code$),
    ('stakeholder-communication', 2, 'Manage expectations before they slip', $body$Expectations are set by every conversation, not only by plans. Agree in advance on what done means, when stakeholders will see working software, and how changes will be communicated. Put agreements in writing after meetings so different recollections surface early, while they are cheap to resolve. When new information changes the forecast, renegotiate scope explicitly instead of silently slipping the date; stakeholders usually prefer a smaller deliverable on time over a surprise delay. The pitfall is saying yes in a hallway conversation and hoping the schedule absorbs it. Rule of thumb: no date changes silently, and no scope changes without a visible trade-off.$body$, $code$After each steering meeting, send a short note:
- What we agreed to build and what we agreed to leave out.
- The demo date and what will be demonstrable.
- Open risks with owners and dates for updates.
- Decisions that need someone else, and by when.
If a deadline becomes unrealistic, propose two options: reduce scope or move the
date, with the consequences of each spelled out for the listener.$code$),
    ('stakeholder-communication', 3, 'Decline requests constructively', $body$Saying yes to everything guarantees that something important will arrive late, so a clear no is part of professional communication. Acknowledge the request and the need behind it, explain the constraint honestly, and offer alternatives: sequence it, scope it down, trade it against something else, or bring help. When competing priorities come from different stakeholders, move the trade-off to the person or forum that owns it instead of quietly absorbing the conflict. A resentful yes followed by a missed date damages trust more than an early, respectful no. The pitfall is either refusing with no explanation or committing without capacity. Rule of thumb: decline the request, stay committed to the goal, and always offer a next step.$body$, $code$Reply to an unplanned request:
"Thanks for raising this; I understand why the report matters by Friday.
We cannot start it without moving the migration, which is committed for this
sprint. Options: bring in one engineer from the data team and keep both,
deliver a manual extract on Friday and automate next sprint, or move one of
the two dates. If none of these work, I suggest we let the delivery lead
decide the priority. I am happy to walk through the estimates."
$code$),
    ('documentation-and-knowledge-sharing', 1, 'Write docs that stay alive', $body$Documentation stays useful when it lives close to what it describes, has a named owner, and gets reviewed on a schedule. Keep pages short and focused on one question, link them from the code or repository where the reader will look, and record the last review date. Prefer a decision log for choices and their reasons over exhaustively describing how everything works, because code explains the what. Delete or archive stale pages rather than leaving contradictions that erode trust. The pitfall is the wiki graveyard: a large, unowned space that everyone knows is outdated and nobody dares edit. Rule of thumb: every page answers one question, names its owner, and has a review date.$body$, $code$Service README skeleton:
- What this service does, in two sentences, plus a diagram link.
- How to run it: exact commands for build, test, and local start.
- Configuration: environment variables with meanings and defaults.
- Decisions: link to the decision log, newest first.
- On-call: link to the runbook and dashboards.
- Owner and review date at the top; update in the same pull request as
  behavior changes whenever possible.$code$),
    ('documentation-and-knowledge-sharing', 2, 'Run knowledge-sharing sessions that stick', $body$A brown-bag session works when it has a narrow topic, a concrete takeaway, and notes that outlive the meeting. Pick real material: an incident and what it taught, a tool the team will use, or a design that is about to be built. Record the session or publish a short summary with links, and rotate presenters so knowledge spreads instead of concentrating around one expert. Leave time for questions and follow up unanswered ones in writing. The pitfall is a monthly lecture series that everyone attends politely and nobody references again. Rule of thumb: every session produces one durable artifact someone can use without having attended.$body$, $code$Session plan: "Reading production traces without panic", 30 minutes.
- 5 min: a real slow request, shown from the trace view.
- 10 min: how to find the slow span and correlate with logs.
- 10 min: attendees trace a second request on their own laptops.
- 5 min: open questions; owner writes answers in the shared notes.
Published afterward: recording link, notes, and a five-line cheat sheet.$code$),
    ('documentation-and-knowledge-sharing', 3, 'Create a real onboarding path', $body$Onboarding is a product with users, not an accident of proximity. Prepare a first-week checklist, environment setup steps that were actually followed recently, a starter task small enough to merge quickly, and a named buddy for questions. Provide a glossary and a simple architecture sketch with the main flows. After each new joiner, update the path with whatever confused them, because their notes are the best defect report you will get. The pitfall is leaving newcomers to absorb tribal knowledge by osmosis, which wastes weeks and spreads misinformation. Rule of thumb: if a new engineer cannot merge a small change in the first few days, the onboarding path needs work.$body$, $code$New joiner, first week:
- Day 1: laptop, accounts, repository access; meet the buddy.
- Day 2: run the service locally using the onboarding guide; note every gap.
- Day 3: read the architecture sketch and glossary; ask three questions.
- Day 4: pick a starter task from the labeled list; pair for the first hour.
- Day 5: open a small pull request; review the guide with the buddy.
Buddy updates the checklist with anything that was missing or wrong.$code$),
    ('career-ladders-and-growth-plans', 1, 'Read frameworks as evidence', $body$A competency framework describes the behaviors expected at each level across dimensions such as scope, autonomy, impact, communication, and direction. Read it as a map of evidence to collect, not as a set of labels to claim. Different companies define levels differently, so compare responsibilities and expectations rather than titles when you change organizations. Use the framework to notice which behaviors you already demonstrate consistently and which you only show occasionally, because consistency is what reviewers look for. The pitfall is assuming time in role automatically produces promotion, or treating the document as a checklist to game. Rule of thumb: keep a running file of examples tied to framework dimensions and dates.$body$, $code$Evidence log entry format:
- Dimension: technical direction.
- Example: wrote the proposal that replaced the shared cache after the stall.
- Impact: removed a recurring cross-team incident class this quarter.
- Scope: three services, two teams, no external dependencies.
- Feedback: design review notes and the incident trend can verify this.
Add one entry per meaningful piece of work, while details are fresh.$code$),
    ('career-ladders-and-growth-plans', 2, 'Assess gaps and plan evidence', $body$An honest self-assessment starts with evidence and outside input, not with a wish. Compare your recent work against the framework, ask your manager and a few peers where they see strengths and gaps, and look for patterns rather than one-off comments. Choose two or three gaps that matter for the role you want next, and write a plan with specific outcomes, a timeframe of a quarter or two, and the evidence that will show progress. Track it in regular one-on-ones instead of waiting for review season. The pitfall is trying to fix everything at once, or only polishing strengths you already enjoy. Rule of thumb: a growth plan names the outcome, the practice, and the proof.$body$, $code$Growth plan example, one quarter:
- Gap: influencing decisions outside my team.
- Outcome: two cross-team proposals reviewed and accepted or rejected on merit.
- Practice: write a one-page proposal each month; request senior review.
- Proof: proposal links, review comments, decision log entries.
- Support: manager introduces me to the platform review forum.
- Checkpoint: revisit in one-on-ones every two weeks.$code$),
    ('career-ladders-and-growth-plans', 3, 'Choose your next role deliberately', $body$Titles matter less than the daily work a role contains. Before aiming at a promotion or a move, talk to people already doing that job about their week: how much of it is meetings, code, mentoring, or firefighting, and what they find draining. Weigh your own energy, constraints, and long-term options, then test the direction with a small experiment such as leading a project, mentoring someone, or writing a design for a neighboring area. Distinguish growing in your current role from changing roles, because they require different plans. The pitfall is pursuing a title while disliking the work it actually involves. Rule of thumb: choose roles by the problems you want to spend your days on.$body$, $code$Questions before pursuing a role:
- What does a typical week look like for people already in it?
- Which parts of my current work energize me, and which drain me?
- What constraints must hold: location, hours, compensation, stability?
- What small experiment could test this direction within a month?
- Who could I talk to before committing, and what would change my mind?
Decide with answers, not with the org chart.$code$)
) AS s(slug, sort_order, title, body, starter_code)
JOIN tutorial t ON t.slug = s.slug
WHERE NOT EXISTS (
    SELECT 1
    FROM tutorial_section existing
    WHERE existing.tutorial_id = t.id AND existing.sort_order = s.sort_order
);

INSERT INTO learning_path_tutorial (learning_path_id, tutorial_id, sort_order)
SELECT lp.id, t.id,
       COALESCE((SELECT MAX(existing.sort_order)
                 FROM learning_path_tutorial existing
                 WHERE existing.learning_path_id = lp.id), 0)
       + ROW_NUMBER() OVER (PARTITION BY lp.id ORDER BY t.slug)
FROM learning_path lp
JOIN tutorial t ON t.level = CASE lp.slug
    WHEN 'junior-java-developer' THEN 'Junior'
    WHEN 'mid-java-engineer' THEN 'Mid'
    WHEN 'senior-java-engineer' THEN 'Senior'
    WHEN 'lead-java-engineer' THEN 'Lead'
    WHEN 'principal-java-engineer' THEN 'Principal'
END
WHERE t.slug IN (
    'reading-code-effectively', 'asking-better-technical-questions',
    'writing-engineering-proposals', 'estimating-work-realistically',
    'code-review-culture', 'mentoring-junior-engineers',
    'on-call-healthy-practices', 'blameless-incident-reviews',
    'runbooks-and-operational-readiness', 'technical-interview-preparation',
    'writing-a-strong-cv', 'growing-from-junior-to-senior',
    'engineering-metrics-that-help', 'stakeholder-communication',
    'documentation-and-knowledge-sharing', 'career-ladders-and-growth-plans'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
