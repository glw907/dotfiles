# AI-Writing Tells: External Evidence Base for a Benchmark Corpus and Deterministic Grader

Compiled 2026-09-01 by a research pass over roughly 60 fetched sources. Where a number is
recomputed from primary data rather than quoted, it says so. Where a widely repeated claim
failed verification, it is listed as a negative finding, because a grader built on folklore
will fire on human prose.

Local data preserved in `data/`: Kobak `excess_words.csv` (900 annotated words, MIT) and the
slop-forensics essay-domain bigram/trigram lists (MIT). The 5.6 MB raw `yearly-counts.csv.gz`
was verified but not vendored; fetch from `github.com/berenslab/llm-excess-vocab`.

---

## 1. Published tell taxonomies

### 1.1 Wikipedia WP:AITELLS — Wikipedia:Signs of AI writing (CC BY-SA 4.0)

`https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing` — shortcuts WP:AISIGNS,
WP:AITELLS, WP:LLMSIGNS. Maintained by WikiProject AI Cleanup (~298 participants). 1,890
lines of wikitext, 95 sections. Descriptive rather than prescriptive.

**AI vocabulary, split by model era** (WP:AIVOCAB). No other source publishes this axis.

```
2023 – mid-2024 (GPT-4 era):   Additionally, boasts, bolstered, crucial, delve, emphasizing,
                               enduring, garner, intricate/intricacies, interplay, key,
                               landscape, meticulous/meticulously, pivotal, underscore,
                               tapestry, testament, valuable, vibrant
mid-2024 – mid-2025 (GPT-4o):  align with, bolstered, crucial, emphasizing, enhance, enduring,
                               fostering, highlighting, pivotal, showcasing, underscore, vibrant
mid-2025 onward (GPT-5):       emphasizing, enhance, highlighting, showcasing
Grok-specific:                 causal, empirical, correlate, underscore
```

**Undue emphasis on significance and legacy** (WP:AILEGACY), verbatim words-to-watch:
stands/serves as · is a testament/reminder · a crucial/pivotal/vital/significant/key
role/moment · underscores/highlights its importance/significance · reflects broader ·
symbolizing its ongoing/enduring/lasting · contributing to the · setting the stage for ·
marking/shaping the · represents/marks a shift · key turning point · evolving landscape ·
focal point · indelible mark · deeply rooted

**Superficial analysis** (WP:SUPERFICIAL). The structural signature is a trailing
present-participle clause bolted onto a finished sentence: highlighting/underscoring/
emphasizing … · ensuring … · reflecting/symbolizing … · contributing to … ·
cultivating/fostering … · encompassing … · enhancing … · valuable insights ·
align/resonate with

**Promotional language** (WP:AIPUFFERY): boasts a · vibrant · rich · profound · enhancing ·
showcasing · exemplifies · commitment to · natural beauty · nestled · in the heart of ·
groundbreaking · renowned · featuring · diverse array

**Copula avoidance** (WP:AINOCOPULA), replacing is/are: serves as / stands as / marks /
functions as / operates as / represents [a] · boasts / features / maintains / offers [a] ·
refers to

**Vague attribution** (WP:AIWEASEL): Industry reports · Observers have cited · Experts argue ·
Some critics argue · several sources/publications · such as

**Outline-shaped conclusions** (WP:FACESCHALLENGES): "Despite its… faces several challenges…" ·
"Despite these challenges" · "Challenges and Legacy" · "Future Outlook"

**Negative parallelism** (WP:AIPARALLEL): "Not only … but …" · "It is not just …, it's …" ·
"It's not …, it's …" · "no …, no …, just …" · "X rather than Y" (flagged as especially
Grok-like)

**Rule of three** (WP:RO3): adjective-adjective-adjective triads and short-phrase triads.

**Style and formatting tells:** title repeated as a level-1 heading · title case in section
headings (WP:AITITLECASE) · headings containing only other headings · boldface overuse
(WP:AIBOLD) · inline-header vertical lists, i.e. `- **Header:** prose` (WP:AILIST) ·
em-dash overuse with spaces around the dash (WP:AIDASH) · emoji as formatting (WP:AIEMOJI) ·
unnecessary small tables · curly quotes (WP:AICURLY, noted as typical of ChatGPT and
DeepSeek and NOT of Gemini or Claude) · skipped heading levels · `----` thematic breaks.

**Chatbot markup artifacts — the highest-precision signals in the whole survey:**

```
ChatGPT:     :contentReference[oaicite:0]{index=0} · oai_citation · citeturn0search0
             · citeturn0news0 · citeturn1file0 · attributableIndex · "Example+1"
Gemini:      [cite: 1] · [cite: 3, 12, 13] · [span_1](start_span) · (end_span)
Grok:        <grok-card data-id="…" data-type="citation_card"> · grok_render_citation_card_json
DeepSeek:    【85†L261-269】  (lenticular brackets)
Perplexity:  [attached_file:1] · [web:1] · URLs containing ppl-ai-file-upload
Unclassified: :::writing{variant="document" id="[5 digits]"}
Tracking:    utm_source=chatgpt.com · utm_source=openai · utm_source=copilot.com
             · referrer=grok.com
```

**Assistant leakage** (WP:CERTAINLY): I hope this helps · Of course! · Certainly! · You're
absolutely right! · Would you like… · is there anything else · let me know · more detailed
breakdown · here is a

**Knowledge-cutoff disclaimers** (WP:AICUTOFF): Up to my last training update · as of my
last knowledge update · While specific details are limited/scarce · not widely
available/documented/disclosed · in the provided/available sources · based on available
information

**Ineffective indicators — what Wikipedia says does NOT work.** A grader must respect this
list, unique to this source: perfect grammar (many editors are professional writers) ·
mixed casual/formal register (indicates technical-field writing, youth, or neurodivergence) ·
"bland" or "robotic" prose (LLM output skews positive and verbose, not robotic) ·
"fancy"/academic/formal prose (the correlation is to SPECIFIC WORDS, not to formality) ·
transition words in isolation · unsourced content · bizarre or correct wikitext.

**Signs of human writing** (useful as negative features): simple is/has phrasing · plain
synonyms over stiff ones (wrote not authored, used not utilized, died not passed away) ·
superlatives · hedges and intensifiers (very, perhaps, tends to) · wordy constructions
(as a result of, in order to, the fact that).

### 1.2 Wikipedia companion: Signs of AI-generated comments

Discussion-prose tells: canned assurances of policy adherence ("I am committed to…") ·
canned third-party review requests · itemization of policies as bullet lists inside a
comment · overuse of "concrete [noun]" · section subheadings inside a talk comment ·
dismissal-of-AI-accusation vocabulary (accusatory, impression, interpretation, speculation,
subjective, unsubstantiated).

### 1.3 Matthew Vollmer, A Field Guide to AI Tells

`https://matthewvollmer.substack.com/p/i-asked-the-machine-to-tell-on-itself`. Twelve
categories, 32 numbered tells, plus domain sections. Its model-family fingerprints section
is the closest thing to a published Claude profile — treat as observational:

```
ChatGPT:  heaviest em-dash user pre-5.1 · intro + triplet + closing-recap default
          · "Certainly!"/"Absolutely!" openers · aggressive boldface on list stems
          · negated contrast especially characteristic · breaks into markdown unprompted
Claude:   longer multi-clause sentences · em dashes mid-sentence rather than clause-end
          · heavier hedging register ("It's worth noting", "While this may vary",
            "Generally speaking", "In many cases") · first-person self-reference
          · LESS prone to triplet-closing and tricolon · holds voice more consistently
Gemini:   verbose, flatter rhythms · lower em-dash frequency · stronger list/heading
          preference
```

Its 30-second field check: flag if three or more tells appear within a few hundred words
(a Kobak focal word in non-academic context, a not-X-but-Y, a tricolon, additive em dashes,
an "In summary/Ultimately" wrap, uniform sentence length, promotional adjectives on
non-promotional subjects, a sycophantic opener, orphaned demonstratives, a bold-stemmed
bullet list where prose would do, absence of any proper noun, date, or idiosyncratic
detail).

### 1.4 isitslop.io — Signs of AI writing

Ranks tells by reliability: **debris** (citation placeholders, invented DOIs — "almost no
false positives") → **structural uniformity** → **rule of three** → **stock vocabulary**
("the easiest tell to look for and the weakest"). Its structural list: paragraphs of
near-identical length · every section resolving the same way ("real challenges remain, but
the outlook is promising") · bold everywhere and a heading for everything · nothing
digresses · coverage instead of argument · the question restated before it is answered and
the answer summarised again.

### 1.5 Journalism and publisher guides — a negative finding

AP Stylebook, Poynter, Nieman Lab, Reuters, Elsevier, Wiley, and Springer Nature all
publish generative-AI guidance. None publishes a tell catalogue or a word list. The
nearest institutional lexical claim is Cambridge University Press & Assessment's
*Research Matters* 37 ("ChatGPT loves an Oxford comma"), with no rate published.

### Confidence — §1

The Wikipedia catalogue is the strongest published taxonomy and actively maintained, but
Wikipedia-scoped. Its era-split vocabulary matches the independent decay evidence in §2.
Its ineffective-indicators section should be encoded as checks the grader deliberately
does not run.

---

## 2. Lexical-marker research

### 2.1 Kobak et al. — the anchor study

Kobak, González-Márquez, Horvát, Lause (2025), "Delving into LLM-assisted writing in
biomedical publications through excess vocabulary." *Science Advances* 11(27):eadt3813.
arXiv 2406.07016. Data: `github.com/berenslab/llm-excess-vocab` (MIT). 15.1M PubMed
abstracts, 2010–2024. At least 13.5% of 2024 abstracts LLM-processed.

Method: `p` is the fraction of abstracts containing the word. Counterfactual
`q = p(Y−2) + 2·max(p(Y−2) − p(Y−3), 0)`. Excess ratio `r = p/q`; gap `δ = p − q`.

**Calibration.** `r` is a corpus-dilution measure: with ~13.5% of abstracts LLM-touched, a
word an LLM uses 20× more shows corpus-level r ≈ 3. Liang-style per-document Q/P ratios run
5–15× larger for the same word. Never mix the scales in one threshold.

Ratios recomputed this session from the raw yearly counts; they reproduce the published
figure annotations exactly (delves ×28, underscores ×13.8, showcasing ×10.7).

**Tier A — r ≥ 4.5:**
```
delves 28.18 · underscores 13.78 · delved 12.31 · showcasing 10.70 · meticulously 10.47
delve 7.91 · intricacies 7.65 · underscoring 7.48 · intricate 7.40 · surpassing 7.09
delving 6.95 · commendable 6.82 · underscore 6.73 · excels 5.87 · garnered 5.28
underscored 5.14 · intricately 4.98 · realm 4.97 · encompassed 4.94 · renowned 4.91
grappling 4.91 · groundbreaking 4.87
```

**Tier B — 2.5 ≤ r < 4.5 (selection; full 407-word list in data/excess_words.csv):**
```
emphasizing 4.67 · encompassing 4.38 · necessitating 4.25 · offering 4.25
revolutionizing 4.07 · aligning 4.01 · formidable 3.90 · showcases 3.84 · showcased 3.82
bolstering 3.76 · advancements 3.61 · heightened 3.60 · notable 3.42 · unveiled 3.41
stands 3.34 · fostering 3.12 · meticulous 3.11 · leveraging 3.08 · seamlessly 3.08
pivotal 3.06 · transformative 2.97 · multifaceted 2.87 · crafting 2.87 · nuanced 2.72
complexities 2.76 · realms 2.67 · notably 2.63 · fosters 2.61 · highlighting 2.58
```

**Tier C — 2.0 ≤ r < 2.5 (selection):** streamlining 2.51 · bolstered 2.44 · enhancing
2.43 · leverages 2.43 · paving 2.39 · akin 2.36 · burgeoning 2.32 · streamline 2.29 ·
noteworthy 2.27 · poised 2.22 · seamless 2.16 · empowers 2.14 · interplay 2.11 · crucial
2.11 · utilizing 2.09 · foundational 2.07 · enduring 2.06 · insights 2.04 · elevates 2.03 ·
featuring 2.02 · valuable 2.01

**Rare-band words recovered by full-corpus rescan (60 ≤ count < 400):** adeptly 24.6 ·
boasting 16.2 · excelling 12.7 · navigates 8.2 · grapples 7.9 · spotlighting 7.6 · esteemed
5.9 · tapestry 5.5 · adorned 5.1 · captivating 5.1 · boasts 4.9 · standout 4.6 · prowess
3.3 · testament 2.6 · nestled 2.4

**POS shift, the most portable structural finding.** Pre-2024 excess words were 79.2%
content nouns (COVID vocabulary). The 2024 excess set is 66% verbs and 14% adjectives. The
signature flipped from topic to register.

### 2.2 Folk tells that FAIL the Kobak test (r₂₀₂₄ ≤ ~1.0)

```
myriad 0.99 · plethora 0.83 · moreover 0.88 · however 1.01 · indeed 0.79 · essentially 0.78
undoubtedly 0.81 · importantly 1.05 · unleash 0.76 · reimagine 0.28 · nexus 0.89
ecosystem 0.95 · unpack 0.81 · today 0.76 · world 0.86 · conclusion 0.91 · therefore 0.79
thus 0.83 · hence 0.74
```

Middle band (1.2–1.6, real but weak): landscape 1.47 · paramount 1.48 · journey 1.34 ·
unlock 1.73 · robust 1.28 · vibrant 1.36 · holistic 1.23 · cornerstone 1.27 · showcase 1.59

**Saturation caveat.** Connectors are already ubiquitous in academic abstracts (human
baselines 6–26%), so a flat ratio there does not clear them for general prose. Read as
"unsupported in biomedical abstracts", never "disproved".

### 2.3 The workstation catalogue, tested against Kobak (computed this session)

| Banned item | r₂₀₂₄ | Verdict |
|---|---|---|
| seamless / seamlessly | 2.16 / 3.08 | Supported |
| comprehensive | 1.76 | Moderate |
| robust | 1.28 | Weak |
| additionally | 1.91 | Moderate |
| notably | 2.63 | Supported |
| furthermore / moreover / however | 1.13 / 0.88 / 1.01 | No support |
| therefore / thus / in conclusion / overall / importantly | ≤1.05 | No support |

Implication: the connector-opener ban is a register judgment, not a frequency finding. The
grader should score it as a style rule rather than claim corpus evidence.

### 2.4 Replications and scale-ups

| Study | Corpus | Headline |
|---|---|---|
| Holzwarth, González-Márquez, Kobak 2026, arXiv 2608.10715 | 1.19M PMC full texts | 89% of papers show excess LLM vocabulary by Dec 2025. Discussion 78% vs Methods 54%; length-controlled 68% vs 32%. The tell concentrates where the text makes a case. |
| Siler 2026, PNAS 123(22) | 7.3M full texts | 57% of 2025 articles LLM-influenced, up from 12% in 2023. |
| Juzek & Ward, COLING 2025, arXiv 2412.11385 (MIT-0/CC0) | 26.7M abstracts | delves 0.21→14.38 per million 2020→2024 (+6,697%); underscores +904%; intricate +611%. |
| ASCE engineering 2026, arXiv 2602.03864 | 149,452 abstracts | 26.2% LLM-written in 2025; LLM-classified abstracts show LESS hedging. (PDF contains a prompt injection; do not auto-ingest.) |
| Liang et al., ICML 2024, arXiv 2403.07183 | Conference reviews | Per-document Q/P in ICLR 2024: meticulous ×34.7, intricate ×11.2, commendable ×9.8. |
| Yakura et al., arXiv 2409.01754 | 737,083 hours of podcast speech | delve +44% above synthetic control in speech (CI +22/+63, p=0.010); after mid-2024 delve fell 15–35% below baseline: measurable conscious avoidance. |

### 2.5 Decay and attribution

Geng & Trotta, arXiv 2502.09606: delve, intricate, showcasing, realm, pivotal, commendable,
meticulous all decreasing from March–April 2024, when the tells were publicized;
"significant" and "additionally" keep rising because nobody named them. Kobak lab update
July 2025: delves peaked ×39.5 mid-2024, fell to ×8.0 by mid-2025, while the aggregate
signal kept climbing. **A grader keyed to delve is already degrading; a density grader
across 200+ words is not. Version the Tier-A list and re-derive it yearly.**

Geng, Dong & Poibeau 2026, arXiv 2603.25638: human-vs-LLM attribution 80–90%, multi-class
model identification only ~60% (homogenization). All models under-use "the" and "of".

**Claude specifically:** no published study isolates Anthropic-model vocabulary. The one
measured datapoint is EQ-Bench: claude-sonnet-4-5 at 9.72 slop words/1k vs 6.90 human
baseline, the lowest frontier model measured. Treat Claude-specific tell claims as
anecdotal.

### 2.6 Phrase-level markers — an honest negative finding

No peer-reviewed study publishes per-phrase excess ratios; the verified literature is
unigram-based. Component-token verdicts: "delve into" strongest in the literature;
"underscores the importance", "in the realm of", "a testament to", "rich tapestry" strong;
"navigate the complexities" partial (the noun carries it); "it's important to note",
"in conclusion", "in today's fast-paced world", "plays a vital role" (as tokens),
"at its core", "game-changer" — no corpus support; they are register rules. The best
phrase evidence is the slop-forensics essay-domain n-gram lists (§4.1), derived against a
human baseline and directly usable.

---

## 3. Structural and stylometric markers

### 3.1 Em dashes — best-quantified, least usable per-document

Freeburg 2026, "The Last Fingerprint", arXiv 2603.27006 (unrefereed). Em dashes per 1k,
unconstrained: GPT-4.1 10.62 · Claude Opus 4.6 9.09 · Claude Sonnet 4 8.29 · DeepSeek V3
6.95 · GPT-4o 4.12 · Gemini 2.5 Pro 3.53 · GPT-5.4 1.43 · Llama 3.1/3.3 0.00. **Human
baseline 3.23 mean, median 3.83, range 0.33–17.12** (8 essays, 57,232 words). Second human
pool (Gutenberg, 702,939 words): 4.76/1k; Twain 10.13, Melville 8.12, Austen 3.47. Base vs
instruct Llama: 0.49 vs 0.00 — **em dashes are an RLHF artifact.** Under a "no markdown"
instruction all markdown features go to zero across twelve models; em dashes persist in
OpenAI/DeepSeek models and collapse in Anthropic/Google ones.

Population evidence: Czuma, arXiv 2606.29540 (preregistered), N=69,632 medRxiv Discussion
sections: ≥1 em dash 4.23% pre-ChatGPT → 11.58% post (OR 2.96, CI 2.77–3.17); 20.3% in
2025. The author: "a population-level indicator, not a per-paper detector."

Corrections: Kobak has no em-dash analysis (the "OR 2.92, Kobak" attribution circulating
online conflates it with Czuma). The 50× within-human range means **a per-document em-dash
threshold is not supportable**; the workstation's per-register em-dash bans are policy
enforcement, not detection, and that framing is correct.

### 3.2 Rule of three / tricolon

Bakhshi 2026, arXiv 2604.19768 (unrefereed), 225 argumentative texts: tricolon per
document LLM 7.13 vs human expert 3.73 (σ 3.48), p<0.001 — the largest single-marker
effect size found. Also: rhetorical questions run 2.4× HIGHER in human experts (5.55 vs
2.28); aporetic endings human 2.7% vs LLM 24.0%. The paper publishes no detection rule;
narrow regexes (`\w+ly, \w+ly, and \w+ly` family) have good precision, poor recall.
Adjacent and deterministic: 76% of syntactic templates in model output trace to
pretraining data vs 35% in human text (Shaib et al., EMNLP 2024, arXiv 2407.00211).

### 3.3 Sentence length and burstiness

"Burstiness" means three different things in the literature, and GPTZero abandoned the
perplexity-burstiness pair in 2023. **The variance finding is robust and replicated; the
mean finding is not.** CCNews readability SD collapses 8.2 → 2.1 under LLM regeneration
(arXiv 2505.07784); ENEM essay word-count SD 40.45 → 11.50 (arXiv 2408.05035); French
speech sentence SD 16.4 → 10.9 (arXiv 2411.18382); LLM rewriting reduces
writing-complexity variance 21–50% across 880k+ texts (*Nature Human Behaviour*, arXiv
2502.11266). Sentence-length MEAN flips direction by genre and model generation (GPT
longer than human in Herbold, shorter in Wang; 2025 models 15–30% longer). **Grade
dispersion, never the mean. No published CV threshold exists; calibrate locally.**

### 3.4 Grammatical markers — the PNAS table (strongest deterministic evidence)

Reinhart et al., "Do LLMs write like humans?", *PNAS* 122, arXiv 2410.16107. Figures as %
of the human rate:

| Feature | Human /1k | GPT-4o | GPT-4o mini | Llama-3-70B-Inst | Llama base |
|---|---|---|---|---|---|
| Present participial clauses | 1.7 | **527%** | 481% | 261% | 102% |
| "That" clauses as subject | 2.1 | 263% | 331% | 173% | 68% |
| Nominalizations | 14.6 | 214% | 209% | 151% | 91% |
| Attributive adjectives | 43.8 | 150% | 140% | 104% | 83% |
| Clausal coordination | 12.4 | 59% | 63% | 127% | 116% |
| Agentless passive | 7.8 | **53%** | 51% | 89% | 98% |

Base models sit near 100% across the board: **instruction tuning introduces the style.**
The participial-tail tell has a measured 5.3× effect size and is trivially regexable.
Word-frequency extremes vs human (GPT-4o): camaraderie 162× · tapestry 155× · grapple 131× ·
intricate 119× · underscore 107× · vibrant 92×.

### 3.5 Formatting density — measured as judge bias

LMSYS style control: answer length coefficient 0.249 vs markdown list 0.031, header 0.024,
bold 0.019 — length dominates by an order of magnitude. Format bias in preference data
(arXiv 2409.11704): bold in 42.76% of preferred vs 16.78% of rejected responses; reward
models prefer lists at 86.75% on content-identical pairs. Freeburg's suppression
asymmetry: formatting tells are prompt-suppressible, punctuation and syntax tells are not
— a formatting-only grader measures instruction-following, not register.

### 3.6 EQ-Bench slop-score per-model baselines (human row included)

From `github.com/sam-paech/slop-score` leaderboard data:

| Model | slop words /1k | slop trigrams /1k | ngram repetition | not-X-but-Y /1k chars |
|---|---|---|---|---|
| human-baseline | 6.90 | 0.09 | 3.93 | **0.04** |
| claude-sonnet-4-5 | 9.72 | 0.23 | 7.43 | 0.17 |
| claude-sonnet-4 | 13.53 | 0.33 | 6.47 | 0.21 |
| chatgpt-4o-latest | 23.26 | 0.79 | 6.51 | 0.25 |
| gemini-2.5-flash | 40.16 | 0.95 | 7.39 | 0.39 |
| gemma-3-4b-it | 40.44 | 0.59 | 12.45 | **0.81** |

**The not-X-but-Y column is the cleanest deterministic separator available**: human 0.04,
Claude Sonnet 4.5 at 4.25× human, worst model at 20× human, fully computable, published
human baseline. Caveat: the human corpus is Reddit fiction prompts; treat the
not-X-but-Y and repetition rows as usable and the slop-word row as domain-shifted.

### 3.7–3.9 Unstable or unbaselined markers

Lexical diversity flips direction between model generations and moves with sampling
temperature — report, do not gate. Hedging direction is unsettled and genre-dependent —
grade the specific frames lexically, never density. **No published baseline of any kind**
exists for: paragraph-length variance, semicolon/colon rate, curly-vs-straight quote rate,
Oxford-comma rate, sentence-opener entropy, or a formatting-only detector with reported
precision/recall.

One result to hold against everything above: Tabach, arXiv 2604.23471 — 251 judges, 1,999
paired comparisons; the two groups differed in perceived humanity (p=0.0002) while "on
every measurable text feature I extracted … the two groups were indistinguishable." The
computable feature set and perceived AI-ness are not the same target.

---

## 4. Tools and wordlists to borrow

### 4.1 slop-forensics (MIT) — the best non-fiction n-gram lexicon

`github.com/sam-paech/slop-forensics`, domain-separated. Essay-domain lists vendored in
`data/`: 390 bigrams, 358 trigrams (plus 2,973 phrases upstream). Top essay phrases with
corpus counts: plays a crucial role (693) · plays a pivotal role (666) · make informed
decisions (640) · extends far beyond (413) · plays a vital role (308) · requires a
multifaceted approach (197) · landscape continues to evolve (184) · essay explores the
multifaceted (178) · rapidly evolving landscape (140) · left an indelible mark (138) ·
testament to the enduring power (134) · marked a pivotal moment (121) · serves as a
cautionary tale (108) · challenge the status quo (99). Sibling repos: antislop-sampler
(scoring function, weighted phrase list), antislop-vllm (`regex_not_x_but_y.json`).

### 4.2 Vale rule packs

- **tbhb/vale-ai-tells** (MIT, ~150 rules): the best off-the-shelf pack. Notable rules:
  Metacommentary (maps one-to-one onto the setup-colon ban: "This matters because", "The
  key here is", "At its core", "Think of it as", "This is where X comes in", bolded
  **Key insight:** stems), WrapUpHeadings/ExplainerHeadings (Final Thoughts · Wrapping Up ·
  The Bottom Line · Why It Matters · Deep Dive · Under the Hood), ContrastiveFormulas
  (~80 spelled-out not-X-but-Y patterns), VerbTricolon, ParticipialPadding, plus
  experimental SentenceLengthVariance and SentenceStartEntropy.
- **JMill/deslop** (MIT, 41 rules): density calibration is its contribution — em dash max
  1/paragraph; RealityAdverb max 1/paragraph calibrated against 388,561 corpus blocks.
  Ships should-flag/should-pass fixture corpora useful for validating any grader.
- **Syntaf/vale-llm-slop**: 17 rules for code comments, commits, PRs (Anthropomorphism,
  RestatesCode, EmptyQualifiers); calls NegativeParallelism "the single most reliable
  structural tell"; narrow tricolon regexes.
- **ammil-industries/vale-signs-of-ai-writing** (CC-BY-SA): machine-readable port of the
  Wikipedia guide.
- **Google and Microsoft Vale packages catch essentially none of this.** Neither has a
  not-X-but-Y rule, heading-cliché rule, hedging-frame rule, or AI vocabulary list. Layer
  an AI-slop pack on top; neither substitutes.

### 4.3 slop-score reference implementation

Composite: 60% slop words · 25% not-X-but-Y · 15% slop trigrams. The two-stage
not-X-but-Y detector (10 surface regexes + 35 POS-tagged regexes) is the most reusable
artifact in the survey; its guards (reporter-frame lookahead, "not without", subject
guards) are what make it usable. Stage-1 core:

```
\b(?:(?:is|are|was|were)\s+not|isn't|aren't|wasn't|weren't|not(?!\s+(?:that|only)\b))\s+
(?:(?!\bbut\b|[.?!]).){1,100}?[,;:]\s*but\s+
(?!when\b|while\b|which\b|who\b|where\b|if\b|that\b|as\b|because\b|although\b|though\b
|until\b|unless\b|here\b|there\b|then\b|my\b|we\b|I\b|you\b|anything\b)
```

### 4.4 Wikipedia AbuseFilter 1325 — production regex at Wikipedia edit volume

Tags edits matching: `(?:stand|serve)s? as | is) a testament` · `I hope this helps` ·
`as (?:an AI|a large) language model` · `in (conclusion|summary),?` · `it is (important to
note|worth noting)` · `must-(visit|see)` · `rich (cultural heritage|history|tapestry)` ·
`stunning natural beauty` · `underscor(es|ing) the importance` · `would you like` · emoji
at line start. Filter 1346 catches AI-sourced citation URLs and markup artifacts.

### 4.5 Licenses

MIT/CC0 for the best sources (berenslab, tjuzek/delve, Paech family, vale-ai-tells,
deslop); AGPL for AlpinDale/gptslop; CC-BY-SA for anything derived from Wikipedia;
all-rights-reserved for commercial word lists (slopdetector.org). proselint (BSD-3) worth
running alongside for pre-2022 human clichés.

---

## 5. Eval-design guidance

### 5.1 What published benchmarks do

- **EQ-Bench CW v3**: rubric scoring + Glicko-2 pairwise Elo with win margin; bidirectional
  judging cancels position bias; 4,000-char truncation controls length bias; over-weights
  the one criterion judges under-detect (`+ 5 × Forced_Metaphor^1.7`) — a transferable
  trick for any tell a judge misses.
- **WritingBench** (arXiv 2503.05244): per-query instance-specific criteria. Human
  agreement: static global rubric + ChatGPT 69% → dynamic criteria 79% → dynamic + Claude
  87%. Query-specific rubrics beat a fixed rubric.
- **HelloBench** (arXiv 2409.16191): weighted binary checklists correlate with human
  judgment at ρ=0.32 vs direct LLM 0–10 scoring at ρ=0.08 — roughly 4×. N-gram metrics at
  or below zero.
- **InFoBench** (arXiv 2401.03601): decomposed binary scoring raises inter-annotator κ from
  0.284 to 0.532 — decomposition nearly doubles agreement.
- **LongWriter**: decouple constraint adherence from quality into two scores; asymmetric
  length penalty (under-length steeper than over-length); judge told to ignore the
  constrained dimension.

### 5.2 Judge pitfalls, with numbers

- **Length bias**: verbosity instruction alone swings uncontrolled win rate 22.9%→64.3%
  (LC-AlpacaEval, arXiv 2404.04475). Control by truncation or covariate regression.
- **Markdown bias**: humans prefer markdown 57% (barely above chance); Gemini 2.5 Pro 97%,
  Claude Sonnet 4 83%, GPT-4o 53% (arXiv 2604.23178, unreplicated). Proportionally the
  largest judge artifact for style work. Claude judges show negative verbosity bias
  (−0.12, prefers shorter).
- **Position bias**: GPT-4 conflict rate 46.3%, ChatGPT 82.5% (ACL 2024, arXiv
  2305.17926). Judge bidirectionally or alternate positions.
- **Self-preference**: GPT-4 egocentric bias 0.78 vs 0.5 baseline; self-recognition ~73.5%
  and correlates with self-preference. **Pick a judge from a different family than the
  model under test** — same-family judge and subject share blind spots.
- **Style bias**: SciStyleBench SBI mean 0.566; 97.8% of stylistic perturbations preserve
  substance while changing judge output.

### 5.3 Deterministic lexical grading vs human judgment

Weak positive correlation only: r = 0.25–0.48 against slop-span proxies; lexical-metric
linear models reach AUPRC 0.52–0.55 against 0.25–0.27 base rates ("some signal beyond
chance", explicitly not a detector — arXiv 2509.19163). Human slop judgments correlate
with latent coherence and relevance, which no lexicon measures. Trained writing-quality
reward models beat lexical metrics (66–72% expert preference, arXiv 2504.07532). **Use
the tell scan as a diagnostic score and trend line, never a pass/fail quality gate.**

### 5.4 Which tasks elicit tells

Argumentative and interpretive prose carries the register tells at over 2× the rate of
procedural prose at matched length (Discussion 68% vs Methods 32%). Format-constrained
prompts measure instruction-following, not register. Creative writing is the hardest to
judge (LitBench zero-shot ceiling 73% vs MT-Bench ~85%).

---

## Top 20 deterministic checks, ranked

Ranked by evidence strength × precision × catalogue relevance. Rates per 1,000 words
unless stated. (1) Contrast-frame density — human 0.04/1k chars, flag ~0.10, hard-fail
0.30; use the slop-score stage-1 guards. (2) Trailing participial clauses — 527% of a
1.7/1k human baseline, peer-reviewed. (3) Kobak style-word density weighted by log(r) —
density, never presence. (4) Tier-A hard list (22 words, r ≥ 4.5) — version it; it decays.
(5) Essay-domain n-gram hits — human 0.09/1k. (6) Metacommentary and setup-colon payoff.
(7) Sentence-length CV — dispersion only; no published threshold, calibrate locally.
(8) Scaffold and wrap-up headings. (9) Chatbot markup artifacts — near-zero false
positives. (10) Assistant-voice leakage. (11) Opening-cliché frames — register rule, mostly
no corpus support except "in the realm of". (12) Em-dash rate — soft signal only; human
range spans 50×. (13) Tricolon density — largest effect size, no published rule; narrow
regexes only. (14) Formatting density — measures instruction-following. (15) Promotional
puffery. (16) N-gram repetition score — human 3.93, flag above ~6. (17) Copula avoidance.
(18) Hedging frames as strings, never density. (19) Nominalization load — human 14.6/1k,
GPT-4o 214%. (20) Aggregate co-occurrence gate — fail at ≥3 distinct families in a
500-word window; every serious catalogue converges here.

**Deliberately excluded:** paragraph-length uniformity, semicolon/colon rate, curly
quotes, Oxford-comma rate (no baselines); perfect grammar, formal register, isolated
transition words (Wikipedia's ineffective-indicators list); moreover/furthermore/however/
therefore/in-conclusion as frequency claims (keep as register rules); robust/myriad/
plethora (r ≤ 1.28); lexical-diversity thresholds; sentence-length mean.

**Two closing cautions.** Elicit with open-ended explainers, not constrained formats.
Score with weighted binary checklists, not holistic judge ratings; control judge length
bias by truncation, cancel position bias bidirectionally, and pick a judge from a
different model family than the subject.
