# Register: Go developer documentation

The reader is a competent Go developer who knows the stdlib, terminals, and Unix idiom, and
has not read this codebase. Applies to READMEs, design docs, ADRs, and package-level prose in
the Go repos (poplar, jrnl-md, displaywidth). Code comments have their own standard in the
go-conventions skill (Go Doc Comments); this register covers prose at the document level.

The standard is the **Google Developer Documentation Style Guide**
(https://developers.google.com/style). The linter is the **Vale Google package**, selected per
glob in each repo's `.vale.ini`. The exemplar corpus is **Google's own developer documentation**.
This register is the Go-prose arm of the authoring charter (`~/.claude/docs/authoring-charter.md`).

## What the standard asks for

- Second person and the imperative for instructions. Address the reader as "you"; start a task
  step with a verb ("Run", "Set", "Return").
- Present tense and active voice. "The command writes the file", not "the file will be written".
- Short sentences, one idea each. Break a compound sentence into two.
- Define an abbreviation or a term on first use, then use it consistently.
- Lead with the most important information. State what a thing does before how it works.
- Plain words over jargon and filler. Cut "simply", "easily", "just", "in order to", and
  marketing adjectives.

## Exemplars

Each passage is written in the Google developer-documentation style. The one-line note says
which trait of the standard it shows.

Task instruction, imperative and second person, present tense (the standard's voice for a
how-to step):

```
To deploy the service, run gcloud run deploy and specify the source directory. The command
builds a container image, pushes it to Artifact Registry, and creates a revision. When the
deployment finishes, gcloud prints the service URL.
```

Concept explanation, active voice, most important fact first (the standard's "lead with what
it does" rule):

```
A service account is an account that an application uses to make authorized API calls. The
application, not a person, owns the account. You grant the service account roles, and the
application inherits those permissions when it runs.
```

Precise UI and action verbs, no vague "click here" (the standard's UI-verb guidance: select,
enter, choose):

```
In the Google Cloud console, go to the Roles page. Select the role you want to copy, and then
click Create role from selection. In the Title field, enter a name for the new role.
```

Reference prose for a parameter, declarative and exact, edge case stated plainly (the
standard's reference register):

```
The --max-instances flag sets the maximum number of container instances for the revision. The
default is 100. If incoming requests exceed the capacity of the running instances, Cloud Run
creates more instances up to this limit, and then queues the remaining requests.
```

A note that warns without alarm, the consequence stated directly (the standard's note and
caution style):

```
Deleting a bucket is permanent. After you delete a bucket, its name is released and another
user can claim it. Move any data you want to keep to another bucket before you continue.
```

## Off-voice contrast

The same content in the register this file exists to prevent (marketing tone, filler,
future tense, vague verbs):

```
Cloud Run is a powerful, fully-managed platform that makes it easy to deploy your apps. Simply
run the deploy command and you'll be up and running in no time! Your service will automatically
scale to handle whatever traffic comes your way, so you can just focus on building great
software.
```
