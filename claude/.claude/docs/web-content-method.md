# Web-content authoring method

The shared, site-agnostic method for drafting and reviewing website content. Each site supplies
its own voice and facts in its local `content-guide.md`. This doc supplies the process, the
catalog, and the rubric. Both the `content-draft` and `content-review` skills load it.

The guiding principle: a website article is not a code comment. Website content starts from the
audience. The substance levers (audience, concreteness, exemplars, an independent rubric review)
do the real work. The avoidance levers (the banned list, burstiness) are backstops, best left to
the deterministic `prose-guard`.

## 1. The audience-first drafting method

1. Audience and purpose brief, first. Before any prose, state who the piece serves, what they
   already know, what they need or worry about, where and how they will read it, and the one action
   or takeaway it must land. If any of these is unknown, ask. Nothing gets drafted before the brief.
2. Gather the concrete facts. Pull the real specifics from the site's canonical facts: places,
   dates, schedule, gear, cost, sign-up. Drafting on abstractions is the failure mode this prevents.
3. Load the register and its exemplars. Read the site `content-guide.md` for the voice and the
   facts, and read the exemplar pairs below. The exemplars are the primary style control. Match them.
4. Outline, then critique the outline. Sketch the headings and the one or two sentences each section
   must carry. Check the outline against the brief before writing prose.
5. Draft. Write audience-first and concrete, matching the exemplars, with varied sentence and
   paragraph length.
6. Self-check. Run the self-check in section 6 below.
7. Offer the score. Offer to run `content-review` before saving or committing.

## 2. The exemplar library

The primary style control. Each pair shows the slop version and the on-voice version of the same
idea. Each site adds its own pairs in its local `content-guide.md`. The off-voice halves sit in a
fenced block because they carry the words the guard blocks.

```
Off-voice (AI or program marketing): "East Community Nordic offers a comprehensive summer training
experience that empowers young athletes to navigate their journey toward elite Nordic skiing
performance, fostering a vibrant community of passionate skiers."

Off-voice: "Whether you're a beginner or a seasoned racer, our experienced volunteer coaches
provide expert guidance in a supportive environment, helping you take your skiing to the next level."
```

On-voice (a coach): "We run, ride mountain bikes, and roller-ski together through the summer.
Tuesday evenings we usually meet at the Service High parking lot. Most weeks include one strength
session when the gym is open."

On-voice: "Returning racers and first-summer kids both come. The pace is whatever the group can
hold together. Bring trail shoes, a water bottle, and bug spray."

## 3. The Signs-of-AI-writing catalog

The full set, sourced from Wikipedia's "Signs of AI writing" page and the user's standard. It lives
in a fenced block so the guard skips it.

```
Vocabulary to skip: delve, dive into, navigate (as metaphor), unlock, embark, foster, cultivate,
empower, leverage, harness, unpack, underscore, bolster, shed light on, pave the way, robust,
comprehensive, vibrant, dynamic, seamless, holistic, intricate, nuanced (as empty praise),
multifaceted, journey (as metaphor), passion, passionate, vital, crucial, essential, pivotal,
transformative, groundbreaking, cutting-edge, innovative, foundational, testament.

Constructions to skip: "It's not just X. It's Y." and every negative-parallelism form;
"Whether you're a beginner or a seasoned racer..."; "More than just..."; "In today's world...";
"It's worth noting / It's important to note"; "When it comes to / At its core / At the end of the
day"; "Join us as we... / Discover the joy of..."; "Take it to the next level"; opening with a
rhetorical question; closing with a motivational tag; sentences ending in an "-ing" editorial tag.

Structural patterns to skip: three-item lists where two or four fit equally; stacked parallel
sentence openings; every paragraph ending on a punchy line; paragraphs all the same length;
decorative em-dashes; excessive bolding; "Bold term: explanation" list formatting; bullets for
content that reads better as prose; closing summaries.

Tonal patterns to skip: promotional or tourism-website tone; performative enthusiasm; unsolicited
reassurance; phrases that promise standards of care or safety guarantees.

Wikipedia adds, beyond the user's list: copula avoidance (swapping plain is/are for fancier
being-verbs), formulaic upbeat conclusion sections, and vague attribution openers.
```

## 4. The rubric

Audience-first, with hard gates that override the score.

Hard gates. Any hit blocks publish, whatever the score:
- A banned word or phrase from the catalog (also caught by `prose-guard`).
- An unverified factual claim or fabricated social proof.
- A safety or standard-of-care promise that carries legal risk.
- A cost misstatement, for sites where cost is a fact (training is free; donations optional).

Scored dimensions. Each scores 0 to 5, weighted, then normalized to 100:

| Dimension | Weight |
|---|---|
| Audience fit | x3 |
| Concreteness and local specificity | x2 |
| Voice fidelity | x2 |
| AI-tell freedom | x2 |
| Cadence and burstiness | x1 |
| Structure and scannability | x1 |
| Key-fact and next-step clarity | x1 |

The weights sum to twelve sub-scores. Maximum raw score is sixty. Normalized score is the raw score
times 100 divided by 60.

The band is the verdict; the number is a secondary signal:
- Publish at 80 or above, with no hard-gate hit.
- Hold from 60 to 79. One revision pass, then re-score.
- Redraft below 60. Return to the brief.

Cadence and AI-tell freedom are inputs, never gates. Only the four hard gates block.

## 5. Per-dimension level anchors

What a 0, a 1, a 3, and a 5 look like, so a score means the same thing across sessions.

Audience fit:
- 5: speaks to both audiences at once, answers their real questions, reading level fits a teen and a
  parent, respects where they read it.
- 3: serves one audience well and the other thinly, mostly answers the real questions.
- 1: generic, addresses no specific reader, misses the questions they actually have.
- 0: wrong audience, an institutional or marketing voice.

Concreteness and local specificity:
- 5: names real places, dates, workouts, gear, cost, with nothing abstract.
- 3: some specifics, some filler abstraction.
- 1: mostly abstract, few real details.
- 0: brochure copy, no real details.

Voice fidelity:
- 5: the site's coach voice throughout, warm and plain, matches the guide.
- 3: mostly on-voice with a few off-register lines.
- 1: a corporate or cheerleader voice creeping in.
- 0: an institutional or marketing voice throughout.

AI-tell freedom:
- 5: clean against the catalog.
- 3: one or two tells.
- 1: several tells.
- 0: saturated with tells.

Cadence and burstiness:
- 5: varied sentence and paragraph length, no low-burstiness flag from the sweep.
- 3: some variation, one flat stretch.
- 1: uniform cadence, the sweep flags low burstiness.
- 0: metronomic.

Structure and scannability:
- 5: clear headings, short paragraphs, tables or bullets where they earn their place.
- 3: readable, a wall in places.
- 1: poor structure, hard to scan.
- 0: an unstructured block.

Key-fact and next-step clarity:
- 5: cost, schedule, safety, sign-up clear, with an obvious next step where relevant.
- 3: most facts clear, the next step vague.
- 1: key facts missing or buried.
- 0: misleading on a key fact.

## 6. The self-check before delivering

1. Read it out loud. Anything that sounds like a school brochure or a tourism page gets rewritten.
2. Search for the banned vocabulary and the negative-parallelism frame.
3. Scan for em dashes. For each, confirm it does work a comma, period, or parentheses cannot. If
   not, replace it.
4. Check for sentences ending in an "-ing" editorial tag.
5. Check for participial and formal-connector openers, and for paragraphs that restate themselves.

## 7. The calibration gold set

Re-anchor scoring against these from time to time, so the same piece lands in the same band. The
slop sample sits in a fenced block because it carries banned words.

Sample A, expected band Publish (about 88):

"Summer training starts the first week of June. We meet Tuesday and Thursday evenings at the Service
High parking lot, plus a Saturday morning long session. Most weeks we run, roller-ski, or ride
mountain bikes, and we add one strength session when the gym is open. Bring trail shoes, a water
bottle, and bug spray. Training is free. If you have questions, reach a coach through the contact
form."

Sample B, expected band Redraft (about 40):

```
"East Community Nordic is a vibrant, comprehensive program that empowers passionate young athletes
to embark on a transformative journey. Whether you're a beginner or a seasoned racer, our dedicated
coaches foster a dynamic environment. It's not just training. It's a community. Take your skiing to
the next level. Your summer starts here."
```
