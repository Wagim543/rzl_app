# RZL — Technology Acceptance Model (TAM) Instrument

Evaluated by **20 residents and tourists**. Feeds Chapter 4.

TAM (Davis, 1989) measures acceptance through **Perceived Usefulness (PU)** and
**Perceived Ease of Use (PEOU)**, which together predict **Attitude Toward Use (ATU)** and
**Behavioral Intention to Use (BIU)**. Report the model honestly: this is a *descriptive*
TAM evaluation, not a structural equation model — with n = 20, do not claim causal paths.

## 1. Constructs and items

12 items, 4 per construct except ATU/BIU split. 5-point Likert (1 = Strongly Disagree,
5 = Strongly Agree).

### Perceived Usefulness (PU)

| # | Item |
|---|---|
| 1 | Using RZL helps me find events in Rizal that I would otherwise miss. |
| 2 | RZL makes discovering local events faster than checking social media pages one by one. |
| 3 | RZL gives me information I need to decide whether to attend an event. |
| 4 | Overall, RZL is useful for someone living in or visiting Rizal. |

### Perceived Ease of Use (PEOU)

| # | Item |
|---|---|
| 5 | Learning to use RZL was easy for me. |
| 6 | I can find what I need without asking for help. |
| 7 | The screens and labels are clear and understandable. |
| 8 | Navigating between features feels natural. |

### Attitude Toward Use (ATU)

| # | Item |
|---|---|
| 9 | I like the idea of using RZL to keep up with local events. |
| 10 | Using RZL is a good idea for residents and visitors. |

### Behavioral Intention to Use (BIU)

| # | Item |
|---|---|
| 11 | I intend to use RZL in the future if it becomes available to the public. |
| 12 | I would recommend RZL to other residents or visitors. |

## 2. Respondent profile (collect before the items)

| Field | Options |
|---|---|
| Role | Resident of Rizal / Tourist or visitor |
| Municipality / origin | Binangonan / other Rizal / outside Rizal |
| Age bracket | below 18 / 18–24 / 25–34 / 35–44 / 45–54 / 55+ |
| Sex | — |
| Frequency of attending local events | never / rarely / monthly / weekly |
| Smartphone proficiency | beginner / intermediate / advanced |

Report this as a demographic table in Chapter 4. It justifies the sample.

## 3. Analysis

Per construct, report the mean and standard deviation:

```
mean = Σx / n
sd   = sqrt( Σ(x − mean)² / (n − 1) )
```

Interpretation bands (same as the ISO instrument):

| Mean | Interpretation |
|---|---|
| 4.21 – 5.00 | Strongly Agree |
| 3.41 – 4.20 | Agree |
| 2.61 – 3.40 | Neutral |
| 1.81 – 2.60 | Disagree |
| 1.00 – 1.80 | Strongly Disagree |

Target: all four constructs ≥ 4.00 (Agree or better). If PEOU lands below PU, that is a
**finding**, not a failure — report it and point at the specific UI causing it. Panels
respect an honest negative finding backed by a fix far more than a suspiciously perfect 4.9.

## 4. Sample size honesty

n = 20 supports **descriptive** statistics only. In Chapter 5, state plainly:

> The Technology Acceptance Model was applied descriptively to measure perceived
> usefulness, ease of use, attitude, and behavioral intention among 20 residents and
> tourists. Because the sample size does not support inferential modelling, results are
> reported as weighted means and standard deviations and are interpreted within the scope
> of Binangonan.

Do not compute p-values or fit a regression on 20 responses. That is the fastest way to
lose credibility.

## 5. Administration notes

- Collect **on a device running the app**, not from a slide deck. TAM measures reaction to
  actual use.
- Give a 2–3 minute guided task first: find a festival, open it, bookmark it, RSVP.
- Record consent. Keep response sheets separate from names.
- Paper or Google Forms both work — but if Forms, screenshot the export for the appendix.

## 6. Chapter 4 presentation

| Construct | Mean | SD | Interpretation |
|---|---|---|---|
| Perceived Usefulness | | | |
| Perceived Ease of Use | | | |
| Attitude Toward Use | | | |
| Behavioral Intention to Use | | | |

Follow with one paragraph per construct naming a concrete app feature that explains the
score. "PU = 4.35 because semantic search surfaced events residents had not seen on
Facebook" is a defensible sentence; "PU = 4.35" alone is not.
