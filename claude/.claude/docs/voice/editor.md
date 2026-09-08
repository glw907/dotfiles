# Register: end-user and editor documentation

The reader is a non-technical person using the software to get a job done: an editor saving a
post, someone following a setup guide, a first-time user who has never seen the admin. They did
not read the code and do not want to. Applies to end-user help, editor guides, setup
walkthroughs, and the in-product copy a non-technical reader sees.

The standard is the **Microsoft Writing Style Guide**
(https://learn.microsoft.com/style-guide/welcome/). The linter is the **Vale Microsoft
package**, selected per glob in the repo's `.vale.ini`. The exemplar corpus is **Microsoft
Learn** and Microsoft's product help. This register is the end-user arm of the authoring
charter (`~/.claude/docs/authoring-charter.md`).

## What the standard asks for

- Warm and relaxed, but plain. Write the way you would explain the task to a colleague. The
  Microsoft voice is friendly without being chatty.
- Second person, present tense, active voice. "You save the post", not "the post is saved".
- Short sentences and short words. Choose the everyday word: "use" over "utilize", "sign in"
  over "authenticate", "lets you" over "enables you to".
- Lead with the task and the outcome. Tell the reader what to do and what happens, not how it
  works inside.
- Put the reader in charge. Address them directly and tell them what they can do next.
- Reassure at the point of worry. If a step looks risky, say plainly what is safe.
- Skip the jargon and the marketing. The reader is already here; nothing needs selling.
- Describe only what the product really shows and does. Copy that names a button, screen, or
  behavior that isn't there strands the reader mid-task. If you don't know what a step looks
  like, don't fill it in.

## Exemplars

Each passage is written in the Microsoft Writing Style Guide voice for end users. The one-line
note says which trait of the standard it shows.

Task instruction, second person, plain everyday verbs (the standard's friendly how-to voice):

```
To change your photo, select your account picture, and then select Change photo. Choose a new
picture from your device, and then select Save. Your new picture appears across your account
right away.
```

A reassuring explanation at the point of worry (the standard's "be helpful, lower the stress"
guidance):

```
Don't worry about losing your work. We save your changes automatically as you go, so your
document is always up to date. You can close the tab and come back later, and everything will
be just as you left it.
```

A concept made plain for a non-technical reader (the standard's "use simple words and short
sentences" rule):

```
A backup is a copy of your files that's kept somewhere safe. If something happens to your
device, you can use the backup to get your files back. You choose how often the backup runs.
```

A short, encouraging empty state or get-started line (the standard's warm, reader-in-charge
tone):

```
You don't have any files here yet. When you're ready, select New to create your first one. You
can always rename or move it later.
```

A clear recovery instruction that tells the reader exactly what to do (the standard's
plain-spoken error guidance):

```
We couldn't sign you in. Check that your email address is spelled correctly, and then try
again. If you still can't sign in, select Forgot password to reset it.
```

## The docs-register measures

For a file in a repo that has opted in, `tellgrader` reports two cadence measures,
`hinged_pair_share` and `short_sentence_share`, whose definitions live in
`~/.claude/skills/writing-voice/evals/tellgrader/MEASURES.md`.

The measures are report-only. They carry no band and gate nothing, and the hinged-pair
definition is unsettled; no number here is a threshold. The corpus for this audience is
held by the consuming repo and reaches a review through the dispatching brief. No file in
this directory names a cairn corpus entry id.

## Off-voice contrast

The same content in the register this file exists to prevent (jargon, passive voice, and
selling):

```
Our platform empowers users with a seamless, intuitive experience. Leveraging robust
cloud-based infrastructure, your data is automatically persisted upon modification, ensuring
enterprise-grade reliability and giving you peace of mind so you can focus on your most
important work.
```
