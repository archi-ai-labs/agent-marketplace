# agent-marketplace

[![validate](https://github.com/archi-ai-labs/agent-marketplace/actions/workflows/validate.yml/badge.svg)](https://github.com/archi-ai-labs/agent-marketplace/actions/workflows/validate.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-marketplace-8A63D2.svg)](https://docs.claude.com/en/docs/claude-code)

> The **`archi-ai-labs` marketplace** for Claude Code — the catalog that makes
> this org's plugins installable, the one-command installer behind
> `archi-ai-labs.github.io/agent-marketplace`, and the README standard every
> plugin here is written to.

This repo is a catalog, not a plugin. It exists so that adding a third plugin
means adding an entry here rather than nesting it inside somebody else's repo —
which is exactly the shape the catalog grew out of, and exactly the shape that
made the marketplace end up named after a person.

**Menu:** [Install](#-install) · [Plugins](#-plugins) · [Standards](#-standards) · [Adding a plugin](#-adding-a-plugin) · [For maintainers](#%EF%B8%8F-for-maintainers)

---

## 🚀 Install

One command registers the catalog and enables `trim-kit`:

```bash
curl -fsSL https://archi-ai-labs.github.io/agent-marketplace/install.sh | bash
```

Choose what gets switched on:

```bash
curl -fsSL https://archi-ai-labs.github.io/agent-marketplace/install.sh | bash -s -- --plugins trim-kit,docs-kit
```

Add `--project` to write `./.claude/settings.json` in the current folder instead
of `~/.claude/settings.json`. Re-running is safe: the existing settings file is
backed up first, the installer aborts without touching it if the JSON is
invalid, and the two keys it writes are deep-merged rather than overwritten.

**The default enables only `trim-kit`.** `docs-kit` installs `PostToolUse` and
`Stop` hooks, and hooks should not be switched on for someone who did not ask
for them.

Or from inside Claude Code, with no terminal:

```
/plugin marketplace add archi-ai-labs/agent-marketplace
/plugin install trim-kit@archi-ai-labs
```

Each plugin's own README has the full install section, including the scope
picker and the exact keys the installer writes.

---

## 📦 Plugins

| Plugin | Install id | What it does |
|---|---|---|
| [**trim-kit**](https://github.com/archi-ai-labs/trim-kit) | `trim-kit@archi-ai-labs` | Audits a project's Claude Code config and says what to add and what to cut — then applies it. No hooks, no agents, no MCP. |
| [**docs-kit**](https://github.com/archi-ai-labs/docs-kit) | `docs-kit@archi-ai-labs` | A three-layer documentation model with deterministic checks and an HTML read model generated from the markdown. Ships two warn-only hooks. |

---

## 📐 Standards

- **[`standards/README-STANDARD.md`](standards/README-STANDARD.md)** — the fixed
  section frame, form conventions and install contract that every plugin README
  in this marketplace follows. It was extracted from the two READMEs that already
  existed rather than invented, and `trim-kit`'s README is its worked example.

`standards/` is where cross-plugin rules live, so a rule that applies to all of
them has one home instead of being re-derived per repo. This README is itself out
of scope for the README standard — that document describes a plugin README, and
this is a catalog.

---

## ➕ Adding a plugin

1. Publish the plugin as its own public repo in `archi-ai-labs`, with
   `.claude-plugin/plugin.json` at the root.
2. Write its README to [the standard](standards/README-STANDARD.md), and walk the
   checklist at the end of that file.
3. Add an entry to [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json)
   with a `github` source pointing at the new repo.
4. Add a row to the table above and a card to [`index.html`](index.html).

`install.sh` needs no change — `--plugins` passes names straight through, so the
catalog is the only list of plugins that has to stay current.

---

## 🛠️ For maintainers

<details>
<summary><b>Validate before sharing</b></summary>

```bash
claude plugin validate .    # checks marketplace.json
node -e "JSON.parse(require('fs').readFileSync('.claude-plugin/marketplace.json','utf8'))"
bash -n install.sh
```

All three run automatically on every push and PR via
[`.github/workflows/validate.yml`](.github/workflows/validate.yml).

</details>

<details>
<summary><b>Project layout</b></summary>

```
agent-marketplace/
├── .claude-plugin/marketplace.json  # the catalog — what /plugin marketplace add reads
├── .github/workflows/validate.yml   # CI: JSON lint + shell syntax + plugin validate
├── standards/README-STANDARD.md     # the plugin README frame
├── index.html                       # GitHub Pages landing (the vanity install URL)
├── .nojekyll                        # serve install.sh raw (skip Jekyll)
├── install.sh                       # one-command bootstrap
├── LICENSE
└── README.md
```

The catalog carries no versions — each plugin's `plugin.json` is the single
source of truth for its own version, and subscribers pick up new ones on their
next `/plugin marketplace update` or a session restart.

</details>

<details>
<summary><b>History</b> — where this repo came from</summary>

Until July 2026 the catalog lived at the root of `archimonde12/claude-trim-kit`,
which meant one repo was both the marketplace and a plugin, and the marketplace
was named `archimonde12`. Splitting it out renamed the marketplace to
`archi-ai-labs` — a **breaking change** for anyone who had installed from the old
id:

```
/plugin uninstall trim-kit@archimonde12
/plugin uninstall docs-kit@archimonde12
/plugin marketplace remove archimonde12
/plugin marketplace add archi-ai-labs/agent-marketplace
/plugin install trim-kit@archi-ai-labs
```

The old install URL `archimonde12.github.io/claude-trim-kit/` is not redirected
and is no longer updated; both old repos are archived.

</details>
