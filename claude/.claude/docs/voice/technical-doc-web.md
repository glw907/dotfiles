# Register: SvelteKit/web developer documentation

The reader is a competent web developer adopting or operating the system, who has not read
the code. The persona is a maintainer explaining the system to a peer: decisions stated as
settled fact, each claim tied to its consequence, each design choice paired with the
alternative it rejected and the failure mode that rejection avoids.

Applies to the cairn-cms docs tree (explanation, guides, reference, tutorial), the sites'
developer docs, and READMEs in the web repos. The dialect is warmer than the Go register by
a notch (guides may address the reader as "you") but carries the same allergy to hedging and
marketing.

## Traits

- Short declarative present-tense sentences. Nearly every claim attaches its consequence
  with a "so" clause: "stores only the SHA-256 hash, so a database read never yields a
  usable link."
- Defend a design choice by naming the rejected alternative and walking its concrete
  failure mode. "KV was the rejected alternative here: its reads are eventually consistent,
  so two confirmations could both read the token as live."
- Design history is recorded plainly, dead ends included: "That was dropped."
- Terminology is reused exactly, never varied for elegance. The same thing has one name.
- A guide step says why it exists in the same breath as what to do. A reference page says
  what it deliberately omits.
- No hedging, no marketing adjectives, no second person outside guides and the tutorial.

## Exemplars

**Provisional.** These passages are Opus rough drafts that Geoff only lightly edited, not
prose he holds up as a target. They show the dialect's mechanics (the "so" clause, the
rejected alternative) but the register's true voice is unsettled pending his calibration
pick. Replace them with passages he has actually edited or approved as docs passes produce
them.

From the architecture explanation. A complete argument in three sentences, opening with a
blunt thesis and closing with a concrete inventory:

```
The engine is fat and the site is thin. Security-critical and fix-prone logic (auth, the
commit path, the admin shell, the render machinery) lives in the engine, so a fix is a
version bump that the site picks up. What the site owns is presentation: the adapter,
the component registry data, the CSS, and the thin route shims.
```

From the security model, the authentication flow. Mechanism in declarative present tense,
each security property stated as a consequence:

```
The flow is a self-owned magic link. A request for a link looks the email up in an
allowlist. On a match it mints a fresh 256-bit token, stores only the SHA-256 hash of
that token, and emails a confirmation link carrying the raw token. The response is
identical whether or not the email was on the allowlist, so the endpoint never leaks who
is an editor.
```

From the security model, the single-use guarantee. The signature move of this corpus: the
rejected alternative and its exact failure mode:

```
A returned row means the token was present, unexpired, and is now gone. The link is
single-use by construction. This is the one place the storage choice is load-bearing.
Cloudflare D1 is strongly consistent, so the delete-and-return cannot race with itself.
KV was the rejected alternative here: its reads are eventually consistent, so two
confirmations of the same link could both read the token as live before either delete
lands, and the single-use guarantee would not hold.
```

From the content model. Design history recorded in the open, arguing from a concrete
difference up to the principle:

```
An earlier design carried an open-ended collections[] array, where a site declared any
number of named collections and the engine treated them uniformly. That was dropped. An
open array pushes every site to invent its own taxonomy, and it forces the engine to
stay generic about something the engine should have an opinion on. A Post and a Page
differ in real ways, including whether the URL carries a date, so the engine models them
as distinct named concepts and gives each one its own behavior.
```

From a guide (configure auth and D1). An imperative step that explains the why and the
safety invariant in the same breath:

```
Seed the first owner. A fresh allowlist is empty, so no email can log in yet and the
site is locked out of its own admin. Insert one owner row to break in. The engine never
lets an owner remove or demote the last remaining owner, so this first row stays a safe
floor. Timestamps are epoch milliseconds.
```

From the delivery reference. Reference prose that scopes itself explicitly:

```
Those symbols are documented on the delivery-data reference and are not repeated here.
This page covers only the names /delivery adds on top of that surface: the
createPublicRoutes loader factory and its route-data types.
```

## Off-voice contrast

The same content in the register this file exists to prevent:

```
cairn-cms takes a unique approach to authentication. Rather than relying on heavyweight
third-party solutions, it features a streamlined magic-link flow designed with security
best practices in mind. This means you can rest assured that your editors enjoy a
seamless login experience while your content remains fully protected.
```
