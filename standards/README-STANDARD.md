# README-STANDARD — how a plugin in this marketplace writes its README

This file is the **source of truth** for the `README.md` of every plugin published
through the `archi-ai-labs` marketplace. It is descriptive, not aspirational: every
rule below was read off the two READMEs that already exist, and a rule that only
one of them follows is marked as such rather than promoted to a requirement.

The frame is fixed. Add plugin-specific sections where §2 allows them; do not
reorder the frame, and do not drop a required section because a particular plugin
"does not really need it" — the reader needs it in the same place every time.

**Where this sits.** This file governs the *shape of the README*. How the plugin
is packaged — manifest, layout, skills, invocation, versioning, what may ship —
belongs to [`COMMUNITY-PLUGIN-STANDARD.md`](COMMUNITY-PLUGIN-STANDARD.md). When
the two documents can both be read as covering something, and they disagree, the
order is:

```
1. Anthropic's published spec        ← highest, not negotiable
2. COMMUNITY-PLUGIN-STANDARD.md      ← packaging, manifest, layout, skills
3. README-STANDARD.md                ← this file
4. trim-kit's own README             ← lowest
```

§5 below says that when this file and trim-kit's README disagree, trim-kit is
right. **That still holds between those two.** It stops holding when Anthropic's
spec is the other party: the spec wins, even where that forces a change to
trim-kit's README. A house standard is ours to revise; the spec is the condition
of being listed in someone else's catalog.

## 1. Purpose and scope

**Applies to:** the root `README.md` of a plugin repo listed in
`.claude-plugin/marketplace.json` — today `trim-kit` and `docs-kit`.

**Does not apply to:**

- `README.md` of the `agent-marketplace` repo itself. That document describes a
  catalog, not a plugin: it has no `/plugin install` line of its own, no Usage
  table of commands, and no Uninstall section. It is out of scope by design.
- Design and rationale documents — `PRINCIPLES.md` (trim-kit), `STANDARD.md`
  (docs-kit). They answer *why*, and this frame is built for *how do I use this*.
- Internal working files — `BACKLOG.md`, `LESSONS.md`, `PROPOSAL.md`,
  `decisions.md`, `NOW.md`. They have no external reader to serve.

**What this standard is for.** A reader arriving at the second plugin should not
have to re-learn where anything is. The install command, the scope picker warning,
the uninstall path and the maintainer notes sit at the same depth in every repo, so
the only thing that differs between two READMEs is the thing that actually differs
between two plugins.

## 2. The section frame

Fixed order, top to bottom. "Required" means both existing READMEs carry it and a
new plugin must too; "per-plugin" means it is present in one and legitimately
absent from the other.

| # | Section | Required? |
|---|---|---|
| 1 | `# <repo-name>` — H1, matching the repo name exactly | required |
| 2 | Hero image inside `<p align="center">` | per-plugin |
| 3 | Badge row — CI · license · Claude Code | required |
| 4 | Tagline — a `>` blockquote, 2–3 lines | required |
| 5 | The problem — one paragraph of prose | required |
| 6 | `**Requirements:**` | required |
| 7 | `**Menu:**` — anchor links to every H2 below | required |
| 8 | `## 🚀 Install` — Option 1 / Option 2 (contract in §4) | required |
| 9 | `### ▶︎ After installing` — numbered steps | required |
| 10 | `<details>` install appendix (contract in §4) | required |
| 11 | `## 💡 Usage` — command table + typical flow | required |
| 12 | Plugin-specific sections | per-plugin |
| 13 | `## 🧹 Uninstall` | required |
| 14 | `## 🛠️ For maintainers` | required |
| 15 | `## 🗺️ Roadmap` | required |

### 2.1 Title

`# <repo-name>`, spelled as the repo is spelled. The reader arrived from a repo
listing or a search result and needs one glance to confirm they are in the right
place; a title that differs from the repo name costs that glance.

### 2.2 Hero image — per-plugin

`<p align="center"><img src="docs/hero.svg" …></p>`, directly under the H1, before
the badges. Present in trim-kit, absent from docs-kit — so it is not required, but
when a plugin has one it goes exactly here. A hero that arrives after the badges
splits the badge row from the tagline it belongs to.

### 2.3 Badge row — required

Three badges, in this order, on three consecutive lines:

1. **CI** — the `validate` workflow badge, linking to the workflow's run list.
2. **License** — `license: MIT`, linking to `LICENSE`.
3. **Claude Code** — `Claude Code | plugin` in `#8A63D2`, linking to the Claude Code docs.

Badges answer three questions a stranger asks before reading a word of prose: is it
maintained, may I use it, and what is it. Anything beyond these three is noise —
neither existing README carries a fourth.

### 2.4 Tagline — required

A `>` blockquote of 2–3 lines, opening with the words **"A Claude Code plugin"** in
bold, and naming what the plugin does — not what it is built from. This is the line
that gets quoted into a chat message, so it has to survive alone.

### 2.5 The problem — required

One paragraph, prose, no bullets: the failure mode this plugin exists for, in the
reader's own vocabulary, before any feature is named. A feature list read by
someone who has not been told the problem is a list of things to skip.

### 2.6 `**Requirements:**` — required

A bold inline label, not a heading. It states the hard floor (Claude Code) and then
every soft dependency together with **what happens when it is missing** — a
degraded tier, a skipped step, a message. A requirement without its failure
behaviour makes the reader guess whether they are disqualified.

### 2.7 `**Menu:**` — required

One line, after Requirements, before the first `---`. Every H2 in the document, in
document order, as an anchor link, separated by ` · `. The emoji is dropped from
the anchor, which leaves a leading hyphen: `## 🚀 Install` → `#-install`.

The frame is long enough that the section a reader wants is usually below the fold.
The menu is also the cheapest self-check there is: an H2 missing from it is
normally an H2 that was added without being thought about.

### 2.8 `## 🚀 Install` — required

Both installation paths, in the fixed order Option 1 then Option 2. Full contract in
**§4** — this is the section that goes wrong most often, so it has its own.

### 2.9 `### ▶︎ After installing` — required

Numbered steps, inside the Install section, covering at minimum: restart or
`/reload-plugins`; approve the marketplace trust prompt if asked; the one command
to run first. Installation is not the goal — the first useful run is. A README that
stops at "installed" leaves the reader at the least valuable moment.

### 2.10 `<details>` install appendix — required

The material an installing reader may want but most do not. Contract in **§4**.

### 2.11 `## 💡 Usage` — required

Three parts, in order:

1. A table with exactly the columns **Command · What it does · Writes files**. The
   third column is not decoration: it is how a reader decides whether to try
   something on a repo with uncommitted work.
2. A **`**Typical flow:**`** line naming the ordinary sequence of commands.
3. A ```` ```text ```` block showing that flow as a session, with `$` prompts and
   `→` result lines.

The table says what exists; the flow says what to do on day one. Both READMEs carry
all three, and the table alone has repeatedly proved not to be enough.

### 2.12 Plugin-specific sections — per-plugin

Between Usage and Uninstall, and nowhere else. Anything the plugin cannot be
understood without: docs-kit has `## 🧭 The model`, `## 🖼 Generated views` and
`## 🔒 Enforcement`; trim-kit has none and is complete without them. Same H2 form,
same emoji convention, and each must appear in the Menu.

Placement is the whole rule. Before Usage they delay the commands; after Uninstall
nobody reaches them.

### 2.13 `## 🧹 Uninstall` — required

Every route back out, symmetric with §4's routes in:

- `/plugin uninstall <plugin>@archi-ai-labs`, and `/plugin marketplace remove
  archi-ai-labs` when dropping the catalog too, with the consequence stated —
  removing the marketplace uninstalls every plugin installed from it.
- `/plugin disable <plugin>@archi-ai-labs` as the reversible middle option.
- `/reload-plugins` or a restart to apply.
- **For a script install: the two keys to delete by hand** —
  `extraKnownMarketplaces["archi-ai-labs"]` and
  `enabledPlugins["<plugin>@archi-ai-labs"]` — plus the timestamped `.bak` the
  installer left behind.
- **When the plugin generates files in the user's repo:** what survives
  uninstalling. docs-kit says `docs/` is ordinary markdown and keeps working;
  trim-kit has nothing equivalent to say, so this bullet is conditional on the
  plugin actually leaving something behind.

A plugin that writes to a user's settings owes them the exact keys to remove. The
manual route is the one people need precisely when the tooling is what broke.

### 2.14 `## 🛠️ For maintainers` — required

Everything here is inside `<details>` blocks; a user scrolling to Roadmap should
pass it in three lines. Required blocks:

- **Validate before sharing** — the `claude plugin validate` invocation, and the
  statement that CI runs it on every push and PR, linking the workflow file.
- **Cut a release** — the numbered order, and the sentence that the version lives
  in exactly one place, `.claude-plugin/plugin.json`.
- **Project layout** — an annotated tree of the repo with one comment per
  significant path.

A plugin may add blocks — docs-kit has **Test recipe** — and may put a short
pointer *above* the `<details>` blocks when there is one document a contributor
must read first (trim-kit points at `LESSONS.md`).

### 2.15 `## 🗺️ Roadmap` — required

Last section. What is not built yet and what would have to be true for it to be.
Roadmap items name their gating condition, not a date. It is also the section that
goes stale fastest, so it is checked at every release: a roadmap describing a
structure the repo no longer has is worse than no roadmap.

## 3. Form conventions

1. **Language: English.** Public-facing files (README, `install.sh` comments,
   `index.html`) are English regardless of the working language of the session that
   produced them. Internal documents are not covered by this rule.
2. **Every H2 opens with an emoji**, one space, then the title: `## 🚀 Install`.
   The set in use is 🚀 Install · 💡 Usage · 🧹 Uninstall · 🛠️ For maintainers ·
   🗺️ Roadmap, plus one per plugin-specific section. Reuse the existing emoji for
   an existing section; never assign two sections the same one.
3. **`▶︎` marks a post-install step heading**, and nothing else in the document.
4. **`---` between major blocks** — after the Menu line, and between every pair of
   H2 sections. Not inside a section.
5. **`<details>` for anything secondary**, so the primary path reads in roughly one
   screen. Summary form: `<summary><b>Title</b> — short hint</summary>`, with the
   hint present when the title alone does not say what is inside. Everything under
   `## 🛠️ For maintainers` is collapsed; the install appendix is collapsed; the
   primary install path, Usage and Uninstall are never collapsed.
6. **Bold inline labels, not headings, for one-line facts** — `**Requirements:**`,
   `**Menu:**`, `**Typical flow:**`. They are one line each; an H3 would put them
   in the menu and imply a section.
7. **Prose wraps at about 80 columns**, and a fenced block is never wrapped.
8. **A `>` blockquote is a warning or an aside**, never body text: the tagline, the
   scope-picker note, the consequence of removing a marketplace.

## 4. The Install contract

This section is the one that goes wrong, because it is the only part of the README
that has to stay true about *three* systems at once — the marketplace, the plugin,
and the user's `settings.json`. All six items below are required.

**Provenance, stated plainly:** only §4.2 was read off both READMEs. The rest —
the two labelled options, `--project`, the safety guarantee, reading the script
first, and the JSON block — comes from trim-kit alone, because until the
marketplace was split out there was one `install.sh` and it lived in the trim-kit
repo. These are not required because trim-kit happens to do them; they are required
because a single shared installer now serves every plugin in the catalog, so the
same six facts are true of every one of them. A plugin whose README omits them is
not simpler, it is missing a path its users have.

**4.1 — Two paths, labelled and ordered.** `### Option 1 — One command in your
terminal ⭐` first, `### Option 2 — Inside Claude Code` second, with a one-line
introduction above them saying there are two and which is recommended. Option 1 is
one `curl … | bash` line from the marketplace's Pages URL. Option 2 is the
`/plugin marketplace add` + `/plugin install` pair. Option 2 exists for Windows and
for anyone without `bash`; it is not a fallback for when Option 1 fails, and
dropping it excludes real users.

**4.2 — The scope picker, spelled out.** `/plugin install` **does not default to
global**. All three choices get a line — **User** (every project, marked as the one
to pick for global), **Project** (`.claude/settings.json`, shared), **Local**
(`.claude/settings.local.json`, private) — followed by the note that the shell form
`claude plugin install <plugin>@archi-ai-labs` installs to User scope without a
picker. This is the single most common install mistake: the plugin lands in one
repo and appears not to work anywhere else.

**4.3 — The per-project variant of Option 1.** The `--project` flag, what it writes
(`./.claude/settings.json`) and how that differs from the default.

**4.4 — Re-running is safe, and why.** One sentence naming the actual guarantees:
the installer backs up the existing `settings.json` first and aborts without
touching it when the JSON is invalid. "Idempotent" is a claim; those two behaviours
are the reason to believe it.

**4.5 — How to read the script before running it.** In the appendix: the
`curl -o install.sh` / `less` / `bash install.sh` sequence. Piping `curl` into
`bash` runs code sight unseen, and telling a reader to do that without showing the
alternative is not a defensible default.

**4.6 — What the installer writes, as JSON.** In the appendix: the exact
`extraKnownMarketplaces` and `enabledPlugins` keys deep-merged into the target
file, with the note that they can be added by hand instead. This block is what
makes §2.13's manual uninstall verifiable, and it is what a security-conscious
reader checks before running anything.

The appendix also carries **local dev** — the `claude --plugin-dir <path>` one-liner
for a session-only load that writes nothing to settings.

## 5. Worked example, and which one wins

The reference implementation is **[`README.md` of
`archi-ai-labs/trim-kit`](https://github.com/archi-ai-labs/trim-kit/blob/main/README.md)**.
Every rule above was read off it and off `docs-kit`'s README; where they agreed, the
rule is required, and where they differed, §2 says so.

**When this document and trim-kit's README disagree, trim-kit is right and this
document is wrong.** The standard was extracted from that README rather than
imposed on it, so a disagreement means the extraction missed something — not that
the example drifted. Fix this file; leave the README alone. The same does not hold
for the other direction: a plugin that is not the source of the standard gets
corrected to match it, which is exactly what docs-kit's README was in v0.8.0.

The one exception is set out at the top of this file: where Anthropic's spec is
what trim-kit's README contradicts, the README is corrected, not the spec and not
this document. That happened once already — the README claimed zero always-on
context while a skill description sat permanently in context, and v0.5.0 replaced
the claim with a measured number
([`COMMUNITY-PLUGIN-STANDARD.md` §6.2](COMMUNITY-PLUGIN-STANDARD.md)).

## 6. Pre-publish checklist

Before publishing or releasing a plugin, walk the list. Each line is checkable by
looking, not by judgement.

- [ ] H1 matches the repo name.
- [ ] Three badges — CI, license, Claude Code — and the CI badge points at this
      repo's workflow, not at the one it was copied from.
- [ ] Tagline is a 2–3 line blockquote naming what the plugin does.
- [ ] One prose paragraph on the problem, before any feature.
- [ ] `**Requirements:**` states every soft dependency's failure behaviour.
- [ ] `grep -n "^## " README.md` — every H2 appears in the Menu line, same order.
- [ ] Install has Option 1 and Option 2, in that order.
- [ ] All three scope-picker choices are described, and the no-picker shell form.
- [ ] `--project` documented; the backup-and-abort guarantee stated.
- [ ] Appendix has all three: read the script first, local dev, what the installer
      writes as JSON.
- [ ] `### ▶︎ After installing` ends on the first command worth running.
- [ ] Usage table has the `Writes files` column, followed by a typical flow and a
      ```` ```text ```` session block.
- [ ] Uninstall names both keys to delete by hand, and says what survives.
- [ ] For maintainers has Validate, Cut a release and Project layout, all collapsed.
- [ ] Project layout tree matches the repo as it is now.
- [ ] Roadmap describes the repo's current structure, not a previous one.
- [ ] No `archimonde12` left in any forward-facing file — the marketplace is
      `archi-ai-labs` and install ids are `<plugin>@archi-ai-labs`. Historical
      documents (`CHANGELOG` sections for old versions, `decisions.md`,
      `LESSONS.md`, `PROPOSAL.md`) keep the old name: it was true then.
