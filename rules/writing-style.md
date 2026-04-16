---
paths:
  - "**/README*"
  - "**/CONTRIBUTING*"
  - "docs/**"
---

# Writing Style — Prose for Reader-Facing Docs

> Plain and precise. No strawman fights, no noun-packaging, no slogans substituted for information.

## When this rule applies

When writing or editing reader-facing prose:

- README, README.zh-TW
- `docs/` files
- Blog posts, release notes
- PR / MR description narrative (not the checklist)
- External tutorials and articles

**Does not apply to**: commit messages, code comments, specs, memory files, session notes, `rules/` themselves, CLAUDE.md. Those have their own formatting conventions.

## Six anti-patterns

### 1. Antithesis packaging

Form: "This is not X — it's Y" / "A, not B" / "A rather than B" / "A is worse than B".

Why avoid: reads like fighting a strawman. Uses aggression in place of information. The reader gets shoved before entering.

❌ "This is not a tips collection — it's an opinionated, self-iterating harness"
❌ "Outdated memory is worse than no memory"
✅ "A personal Claude Code setup: rules, agents, skills, hooks"

### 2. Noun-packaging

Form: ordinary concepts dressed up as capitalized or proprietary-sounding names ("The XX Principles", "XX System", "XX Loop", "XX Closure").

Why avoid: the packaging inflates the concept but doesn't describe the substance. Readers want to know what's actually happening.

❌ "Three-Tier Memory System", "Five Core Principles", "Verification Loop", "Self-Iteration Closure"
✅ "Memory in three tiers", "CLAUDE.md has five principles", "Verification flow"

### 3. Slogan endings

Form: closing a paragraph with an aphoristic, rhythmic, or symmetrical short sentence.

Why avoid: slogans carry stance, not information. Readers remember the cadence but forget the content.

❌ "Rules grow from mistakes — not designed upfront"
❌ "They're complementary, not competing"
✅ "Each rule traces back to a specific incident: Claude did something wrong in some situation, and a rule got added so it wouldn't repeat"

### 4. Adjective stacking

Form: two or more adjectives piled on one noun, especially flattering ones.

Why avoid: every adjective is self-congratulation. Readers recoil.

❌ "opinionated, self-iterating harness"
❌ "battle-tested, structured, extensible workflow"
✅ "A personal setup", "rules accumulated over time"

### 5. Translation stiffness

Form: sentences that follow the source language structure but read awkwardly in the target language.

Why avoid: it reads like machine translation. Readers feel the author didn't care.

❌ "Let AI stay disciplined and productive" (direct rendering from a Chinese draft)
❌ "What You Have / What You Get" as column headers

### 6. Pronoun stacking

Form: heavy use of "I" or "you" as grammatical subjects.

Why avoid: the personality in reader-facing prose should come from content, not pronouns. Too many "I"s feel self-absorbed; too many "you"s feel lecturing.

❌ "My own setup", "I wrote a rule for this", "I suggest you..."
✅ "A personal setup", "a rule got added", "a good starting point is..."

## Four positive patterns

### 1. Fact first, meaning second

Open with what this is and how to use it. Don't define yourself or fight other concepts first.

### 2. Concrete examples beat abstractions

To claim "every rule has a failure case behind it", name one: "critic must run in fresh context — because when the AI reviews code it just wrote, it rationalizes the missing pieces."

### 3. Keep sentences short

If a sentence passes ~25 English words, consider breaking it. Readers lose focus in long sentences.

### 4. Lead with what's useful to the reader

Don't start with self-definition. Start with what the reader can do, or how to start.

## Self-check

After writing, scan once:

- [ ] Any "X — not Y" / "X, rather than Y" antithesis constructions?
- [ ] Any capitalized or quoted "XX Principle / XX System / XX Loop / XX Closure" packaging?
- [ ] Any noun with two or more adjectives stacked in front?
- [ ] When comparing Chinese and English versions, does either read like a direct translation of the other?
- [ ] Can "I" / "you" frequency be lowered with "a personal..." or no subject?
- [ ] Does the first paragraph fight a strawman?

## Sync coordination

When `skills/sync-public` translates README or docs, both the Chinese and English versions must pass this rule's checks independently. The English version isn't a sentence-by-sentence translation — both versions are written with the same principles but independently.
