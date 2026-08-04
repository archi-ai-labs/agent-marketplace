# COMMUNITY-PLUGIN-STANDARD — what a plugin here must be before it is submitted

This file is the **source of truth** for how a plugin in the `archi-ai-labs`
marketplace is packaged: its manifest, its layout, its skills, how it is invoked,
how it is versioned, and what it is allowed to carry. It exists because these
plugins are submitted to Anthropic's **`claude-community`** directory, where a
reviewer who has never met them decides whether they belong.

Its companion, [`README-STANDARD.md`](README-STANDARD.md), governs the *shape of
the README*. This file governs everything else. Neither one replaces the other.

**Every rule below carries a label.** `[ANTHROPIC]` means Anthropic's published
documentation requires or states it, and the link is given so you can check.
`[HOUSE]` means we chose it, and a reason follows. A reader must be able to tell
a condition of entry from a matter of taste — most of the cost of a standard is
paid by the person who cannot.

## 1. Scope and precedence

**Applies to:** every plugin repo listed in `.claude-plugin/marketplace.json` —
today [`trim-kit`](https://github.com/archi-ai-labs/trim-kit),
[`docs-kit`](https://github.com/archi-ai-labs/docs-kit) and
[`now-board`](https://github.com/archi-ai-labs/now-board).

**Does not apply to:** the `agent-marketplace` repo itself. It is a catalog, not
a plugin: no `plugin.json`, no skills, nothing to submit.

### 1.1 Which document wins

Four documents can have an opinion about the same file. When they disagree:

```
1. Anthropic's published spec        ← highest, not negotiable
2. COMMUNITY-PLUGIN-STANDARD.md      ← packaging, manifest, layout, skills
3. README-STANDARD.md                ← the shape of the README
4. trim-kit's own README             ← lowest
```

`README-STANDARD.md` §5 says: *when this document and trim-kit's README disagree,
trim-kit is right and this document is wrong.* **That rule still holds between
those two.** It stops holding the moment Anthropic's spec is the other party —
then the spec wins, even where that forces a change to trim-kit's README.

The reason is not seniority, it is consequence. A house standard is something we
chose and can revise over lunch. The spec is the condition of being listed in
someone else's catalog; disagreeing with it does not make us right, it makes us
rejected.

## 2. Eligibility

Four conditions gate submission. Three are Anthropic's; the fourth is ours.

| # | Condition | Label |
|---|---|---|
| 2.1 | The repo is **public**. Closed-source plugins are not accepted. | `[ANTHROPIC]` [submit](https://claude.com/docs/plugins/submit) |
| 2.2 | `claude plugin validate .` passes. The review pipeline runs the same check. | `[ANTHROPIC]` [plugins](https://code.claude.com/docs/en/plugins#submit-your-plugin-to-the-community-marketplace) |
| 2.3 | Submission goes through the **in-app form**. A pull request opened against `anthropics/claude-plugins-community` is closed automatically — that repo is a read-only mirror. | `[ANTHROPIC]` [community mirror](https://github.com/anthropics/claude-plugins-community) |
| 2.4 | `claude plugin validate . --strict` passes, and CI runs it with `--strict` on every push. | `[HOUSE]` |

**On 2.4.** Warnings are not errors: an unrecognized field, or one misspelled by
a character or two, still loads and still validates
([plugins-reference](https://code.claude.com/docs/en/plugins-reference#unrecognized-fields)).
That is the right default for a manifest that might double as another
ecosystem's, and the wrong default for us — the field we misspell is a field we
believed we had set. `--strict` turns the warning into a failure at the only
moment it is cheap to fix.

## 3. The manifest contract

`.claude-plugin/plugin.json`. Anthropic requires almost nothing here; we require
most of it, for reasons that are about the reader rather than the loader.

| Field | Anthropic | Here | Why we ask for it |
|---|---|---|---|
| `name` | **required** | required | kebab-case, no spaces. It is the skill namespace: `/name:skill`. |
| `$schema` | optional | **required** | Editor autocomplete and validation before CI sees the file. Ignored at load time. |
| `displayName` | optional | **required** | What the `/plugin` picker shows. Without it the picker shows the kebab-case id. |
| `version` | optional | **required** | Explicit semver. See §8 — the alternative silently changes what "an update" means. |
| `description` | optional | **required** | The one line a stranger reads in the catalog before deciding. |
| `author` | optional | **required** | `{ "name": "archi-ai-labs", "url": "https://github.com/archi-ai-labs" }` |
| `homepage` | optional | **required** | The repo URL. A reviewer looking at a catalog entry should reach the source in one click. |
| `repository` | optional | **required** | Same URL. Distinct field because tooling reads them differently. |
| `license` | optional | **required** | SPDX id, matching `LICENSE`. A plugin whose licence you must open a file to learn is a plugin people skip. |
| `keywords` | optional | **required** | Discovery. Lowercase, no duplicates of `name`. |
| `defaultEnabled` | optional | **conditional** | Required when §7 applies. |

`name` is genuinely the only field Anthropic requires
([plugins-reference](https://code.claude.com/docs/en/plugins-reference#required-fields));
everything else in the "Here" column is `[HOUSE]`.

### 3.1 Identity lives in `plugin.json`, not in the catalog

A marketplace entry may repeat any manifest field, and `plugin.json` wins for
`version`
([plugins-reference](https://code.claude.com/docs/en/plugins-reference#metadata-fields)).
`[HOUSE]`: **when `marketplace.json` and `plugin.json` disagree about `name`,
`displayName`, `description` or `author`, fix the catalog.** One file owns
identity. Two files owning it is how a plugin ends up displaying two different
names in two different places, and nobody notices until a user asks which is real.

## 4. The layout contract

| Rule | Label |
|---|---|
| 4.1 · `.claude-plugin/` contains **`plugin.json` and nothing else**. `skills/`, `commands/`, `agents/`, `hooks/` and the rest live at the plugin root. | `[ANTHROPIC]` [layout](https://code.claude.com/docs/en/plugins-reference#standard-plugin-layout) |
| 4.2 · The plugin sits at the **repo root**, not under a `plugins/` subdirectory. | `[HOUSE]` |
| 4.3 · Skills live in `skills/<name>/SKILL.md`. **`commands/` is not used.** | `[HOUSE]` |
| 4.4 · Test fixtures and CI harnesses do not live under `skills/`. | `[HOUSE]` |

**On 4.3, because it is the one people get wrong.** Files in `commands/` are not
deprecated and not broken: they still work, and they support the same frontmatter
([skills](https://code.claude.com/docs/en/skills)). Anthropic's own guidance is
softer than ours — *"Use `skills/` for new plugins"*
([file locations](https://code.claude.com/docs/en/plugins-reference#file-locations-reference)).
We make it absolute for two reasons. A skill is a directory, so its scripts,
references and fixtures travel with it; a command is a lone file, and its
supporting material ends up somewhere with no stated relationship to it. And when
a skill and a command share a name, **the skill wins**
([skills](https://code.claude.com/docs/en/skills#where-skills-live)) — so a repo
holding both has a file that looks like the implementation and never runs.
docs-kit carried three such files until v0.9.0.

**On 4.4.** A reviewer reading `skills/` is reading what they believe is the code
that runs on a user's machine. A test harness there is not a security problem, it
is a legibility one — and see §5, where it becomes both.

## 5. The containment contract

An installed plugin is **copied** into `~/.claude/plugins/cache`, not run in
place ([caching](https://code.claude.com/docs/en/plugins-reference#plugin-caching-and-file-resolution)).
Everything in this section follows from that one fact.

**5.1 · Nothing resolves above the plugin root.** `[ANTHROPIC]` — a path that
traverses out of the plugin, such as `../shared-utils`, does not work after
installation, because those files were never copied
([path traversal](https://code.claude.com/docs/en/plugins-reference#path-traversal-limitations)).

`[HOUSE]` extension: this holds for **every** file under the plugin root, not
only the ones that run at install time. A CI-only script that computes
`$PLUGIN_DIR/../..` is dead code in the cache and is indistinguishable, to a
reviewer, from a plugin trying to read the user's home directory. Where a path
must stay inside the plugin, use `${CLAUDE_PLUGIN_ROOT}`.

**5.2 · Symlinks resolve inside the plugin, or inside the marketplace.** A
symlink pointing within the plugin is preserved; one pointing elsewhere in the
same marketplace is dereferenced and its content copied; one pointing outside is
**skipped for security**
([symlinks](https://code.claude.com/docs/en/plugins-reference#share-files-within-a-marketplace-with-symlinks)).
`[ANTHROPIC]`.

**5.3 · Write a comment wherever a path is deliberately awkward.** `[HOUSE]`.
Path arithmetic that avoids `../` looks like something to tidy up. The next person
to tidy it will not know why it was written that way unless the file says so.

## 6. The skill and invocation contract

### 6.1 What loads into context, and when

Three states, and the third column is the one that matters
([control who invokes](https://code.claude.com/docs/en/skills#control-who-invokes-a-skill)):

| Frontmatter | You invoke | Claude invokes | In context |
|---|---|---|---|
| *(default)* | yes | yes | **description always loaded**; body loads on invocation |
| `disable-model-invocation: true` | yes | no | **description not loaded**; body loads when you type it |
| `user-invocable: false` | no | yes | description always loaded |

`disable-model-invocation: true` removes the description from context entirely.
It is not merely a lock on automatic triggering — it is the only lever that makes
a skill cost nothing until used. `[ANTHROPIC]`.

`user-invocable: false` is the opposite lever: it hides the skill from the `/`
menu while **leaving its description in context**. `[HOUSE]`: **do not use it
here.** It costs context and removes the one thing the user can do about it.

### 6.2 The always-on budget

`[HOUSE]`. Two rules:

1. **A plugin's always-on context cost is at most 150 tokens**, counting the
   `description` and `when_to_use` of every skill that Claude can invoke.
2. **That cost is published in the plugin's README as a measured number**, not as
   a claim.

The second rule exists because trim-kit's README said *"adds zero always-on
context"* through four releases while one skill cost 127 tokens. The sentence was
not dishonest; it was unmeasured, and unmeasured claims drift in one direction.
A number has to be re-derived to stay wrong.

Measure it:

```bash
for f in skills/*/SKILL.md; do
  grep -q 'disable-model-invocation: *true' "$f" && continue
  awk '/^description:/{p=1} p&&/^[a-z_-]+:/&&!/^description:/{exit} p' "$f"
done | wc -c   # divide by 4 for an approximate token count
```

### 6.3 Which skills stay open

`[HOUSE]`. **A skill is closed by default.** It is opened only when Claude
noticing the need is worth more than the context it costs — which is rarely, and
never for anything that writes.

Current roster:

| Plugin | Open to Claude | Closed |
|---|---|---|
| `trim-kit` | `status` | `scan`, `apply`, `distill-plugin` |
| `docs-kit` | `brief` | `docs-init`, `docs-check`, `docs-sync`, `docs-render` |

`status` is the cheapest thing in either plugin to open: it declares
`disallowed-tools: Write Edit`, so Claude invoking it cannot change anything, and
`context: fork`, so its output lands in a subagent rather than the main thread.
`brief` is opened because a user assembling instructions for another agent will
not remember that a command for exactly that exists.

**`scan` is closed even though its description is the best-written trigger in
either plugin** — it names the situations a user describes and ends *"even if
they never name this skill."* That was deliberate work, and closing it was a
deliberate trade: a clean context in exchange for discovery. Do not reopen it
because the description looks wasted. If discovery becomes the priority again,
that is a decision to take on purpose, not a tidy-up.

### 6.4 Writing the two kinds of description

A `description` has exactly one reader, and which one depends on §6.3.

- **Closed skill → the reader is a human scanning `/help`.** Say what typing it
  does. Do not write *"Use only when the user runs /x"* — the flag already
  guarantees that, and the sentence costs a line in every menu it appears in.
- **Open skill → the reader is Claude, deciding.** Name the **situations a user
  describes**, not the features the skill has. A description that says what the
  skill *is* will not fire; one that says when it is *needed* will.

`[HOUSE]`: an open skill's description is **at most 400 characters**. Anthropic
truncates `description` + `when_to_use` at 1,536 characters in the listing
([frontmatter](https://code.claude.com/docs/en/skills#frontmatter-reference)), so
400 is ours, derived from §6.2 rather than from the cap.

### 6.5 The author is the only one who can change this

`skillOverrides` in settings **does not affect plugin skills**
([override visibility](https://code.claude.com/docs/en/skills#override-skill-visibility-from-settings)).
`[ANTHROPIC]`.

There is no per-skill escape hatch for a user who finds one of our skills noisy —
the frontmatter we ship is what everyone gets, and their only remedy is to
disable the whole plugin. That asymmetry is the reason §6.3 defaults to closed.

## 7. The opt-in contract

`[HOUSE]`. **A plugin that registers hooks or MCP servers ships
`defaultEnabled: false`.**

`defaultEnabled: false` installs the plugin in a disabled state until the user
turns it on
([default enablement](https://code.claude.com/docs/en/plugins-reference#default-enablement)).
Anthropic suggests it for plugins that "add cost or scope a user should opt into";
we make hooks and MCP servers the concrete test, because both run without the
user asking on that particular occasion.

Three things a README must say when this applies:

1. The plugin installs **off**, and the command to turn it on.
2. **Existing installs are unaffected** — a setting already written in
   `enabledPlugins` takes precedence over the default, at any scope.
3. It requires **Claude Code ≥ v2.1.154**. Earlier versions ignore the field and
   enable the plugin on install, so the README cannot promise more than the
   reader's version can deliver.

This is the same judgement the marketplace `install.sh` has always made: with no
arguments it enables `trim-kit` only, and `docs-kit` needs `--plugins docs-kit`.
The field moves that decision into the plugin, where it also applies to people
who never touch the installer.

## 8. The versioning and release contract

**8.1 · `version` is set explicitly, and `plugin.json` is the only place it
lives.** `[HOUSE]`, on top of an `[ANTHROPIC]` fact: if `version` is set, users
receive changes **only when it is bumped** — pushing commits alone leaves everyone
on the cached copy
([version management](https://code.claude.com/docs/en/plugins-reference#version-management)).
Omitting it makes the git SHA the version, so every commit is a release. We take
the first, and accept the obligation that comes with it.

**8.2 · Semver, and a `CHANGELOG.md` in Keep a Changelog form.** `[HOUSE]`. MAJOR
for breaking, MINOR for features **and for anything a user will notice**, PATCH
for fixes. A change to `defaultEnabled`, or to which skills Claude can invoke, is
at least MINOR: it is not a feature, but the user's experience changes.

**8.3 · The order is fixed: bump → commit → push → CI green → tag.** `[HOUSE]`.
CI fails a tag `v<x.y.z>` that does not match `version` in `plugin.json`, which
means tagging first to "see if it passes" produces a failed run attached to a tag
that now exists.

**8.4 · The release commit contains `CHANGELOG.md`, `plugin.json`, and anything
mechanically derived from the version — nothing else.** `[HOUSE]`. Every other
change goes in its own commit first.

The derived-file clause is not a loophole, it is a consequence. docs-kit stamps
the plugin version into `design/sample-*.html`, and CI fails when those files
differ from a fresh render. Regenerating them in a separate commit would leave
the release commit itself failing CI. They belong with the bump for the same
reason `plugin.json` does: reverting the release has to revert all of it. What
the rule actually forbids is the unrelated fix riding along — a release commit
that also corrects a typo is one nobody can revert cleanly.

**8.5 · Submission happens once.** `[ANTHROPIC]`. An approved plugin is pinned to
a commit SHA in the community catalog and CI advances the pin as you push; you do
not resubmit for updates. The public catalog syncs nightly, so a new tag is
visible to users on a delay you do not control
([plugins](https://code.claude.com/docs/en/plugins#submit-your-plugin-to-the-community-marketplace)).

## 9. What ships

**There is no packaging exclusion mechanism.** No `.claudeignore`, no `files`
field. For a `github` source the entire repository is the plugin and is copied
into every user's cache. `[HOUSE]` conclusion from `[ANTHROPIC]` facts — do not
go looking for an ignore file; keeping something out of the artifact means
**removing it from the repo**.

Three consequences.

**9.1 · No third-party material.** `[HOUSE]`. Content authored elsewhere — skills
extracted from another plugin, vendored files, a second `LICENSE` — does not
belong in a repo published under one licence. trim-kit carried three skills
distilled from an Apache-2.0 plugin, plus that plugin's licence file, inside an
MIT repo, and shipped all of it to every install until v0.5.0. The licences were
compatible and it was still wrong: nobody reading the repo could tell which terms
covered which file.

**9.2 · No personal configuration.** `[HOUSE]`. A maintainer's
`.claude/settings.json` is not repo content, and shipping it invites a reader to
treat one person's plugin choices as the project's recommendation.

**9.3 · Development material earns its place or leaves.** `[HOUSE]`. Design notes,
principles, lessons and decision logs may stay — they serve a reader. Test
fixtures and harnesses stay only outside `skills/` (§4.4), so nothing that never
runs on a user's machine looks like something that does.

## 10. Submitting

**10.1 · Access.** `[ANTHROPIC]`. Both forms require credentials the plugin
author may not have:

| Route | Requirement | URL |
|---|---|---|
| claude.ai | A **Team or Enterprise** organization plus directory-management access; Owners have it by default | https://claude.ai/admin-settings/directory/submissions/plugins/new |
| Console | Developer, Admin or Owner on a Console org — the route for individual authors | https://platform.claude.com/plugins/submit |

**10.2 · Before submitting.** Run `claude plugin validate . --strict` and keep
the output; walk §11.

**10.3 · Do not open a pull request.** PRs against
`anthropics/claude-plugins-community` are closed automatically. `[ANTHROPIC]`.

**10.4 · Two directories, one of which cannot be applied for.** `[ANTHROPIC]`.
`claude-community` is where submissions land after review.
`claude-plugins-official` is curated by Anthropic at its discretion; there is no
application process and the form does not add plugins to it.

**10.5 · What is being promised.** `[HOUSE]`. Anthropic runs automated review and
safety screening, not an audit. The README, the manifest and the licence are what
a reader has to go on, which is the entire reason this document exists.

## 11. Pre-submission checklist

Each line is checkable by looking, not by judgement.

- [ ] Repo is public; `LICENSE` present and its holder matches `license` in `plugin.json`.
- [ ] `claude plugin validate . --strict` passes, and CI runs it with `--strict`.
- [ ] `plugin.json` has all ten required fields (§3), and `name` is kebab-case.
- [ ] `marketplace.json` agrees with `plugin.json` on name, displayName, description, author.
- [ ] `.claude-plugin/` contains only `plugin.json`.
- [ ] No `commands/` directory; every skill is `skills/<name>/SKILL.md`.
- [ ] Every `../` chain under `skills/` lands **inside** the plugin root. List the
      candidates with `grep -rn '\.\./' skills/` and resolve each one by hand —
      `skills/a/scripts/../../b` is fine, one more `..` is not. Counting dots is
      not the check; where it lands is.
- [ ] No test fixtures or harnesses under `skills/`.
- [ ] Every skill not listed in §6.3 has `disable-model-invocation: true`.
- [ ] Each open skill's description is ≤ 400 characters and names situations, not features.
- [ ] No closed skill's description still says "use only when the user runs …".
- [ ] Measured always-on cost is ≤ 150 tokens and is stated as a number in the README.
- [ ] `defaultEnabled: false` if the plugin registers hooks or MCP servers, with all three README notes (§7).
- [ ] `version` set explicitly, matching the tag; `CHANGELOG.md` has a dated section for it.
- [ ] Release commit touched only `CHANGELOG.md`, `plugin.json`, and files
      regenerated from the version.
- [ ] No third-party skills, vendored files, or second licence in the repo.
- [ ] No maintainer `.claude/settings.json`.
- [ ] `README-STANDARD.md` §6 checklist has been walked as well.
