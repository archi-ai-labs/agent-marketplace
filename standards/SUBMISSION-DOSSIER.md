# SUBMISSION-DOSSIER — the facts to paste into the form

Everything Anthropic's plugin-directory submission form asks for, per plugin,
gathered so nobody has to re-derive it at the moment of filling it in. Rules and
reasoning live in [`COMMUNITY-PLUGIN-STANDARD.md`](COMMUNITY-PLUGIN-STANDARD.md);
this file is only the facts.

Regenerate the measured lines below at each release — a dossier quoting an old
version is worse than none, because it reads as current.

## 0. Before you open the form

**You need one of these two accounts.** Neither can be created on your behalf.

| Route | What it requires | URL |
|---|---|---|
| claude.ai | A **Team or Enterprise** organization, plus directory-management access. Organization Owners have it by default; on Enterprise an Owner can delegate it through a custom role. | https://claude.ai/admin-settings/directory/submissions/plugins/new |
| Console | **Developer, Admin or Owner** on a Console organization. This is the route for an individual author with no Team or Enterprise org — sign up at platform.claude.com. | https://platform.claude.com/plugins/submit |

**Do not open a pull request.** PRs against `anthropics/claude-plugins-community`
are closed automatically; that repository is a read-only mirror and every change
flows from the internal review pipeline.

**What you are submitting to.** `claude-community`, the public community
directory. `claude-plugins-official` is curated by Anthropic at its own
discretion — there is no application, and this form does not add anything to it.

## 1. `trim-kit`

| Field | Value |
|---|---|
| Repository | https://github.com/archi-ai-labs/trim-kit *(public)* |
| Version submitted | **0.5.0**, tagged `v0.5.0` |
| Licence | MIT |
| One line | Audits a project's Claude Code configuration and says what to add and what to cut — then applies it. |
| Skills | 4 — `scan`, `apply`, `distill-plugin`, `status` |
| Hooks | **none** |
| MCP servers | **none** |
| Sub-agents | **none** |
| Reachable by Claude on its own | `status` only — read-only (`disallowed-tools: Write Edit`) and forked (`context: fork`) |
| Always-on context cost | **~89 tokens**, one skill description. Asserted by `tests/harness.sh` in CI. |
| Runtime requirements | Claude Code. `scan` prices plugins through Python 3.8+, then Node 14+, then a shell-only fallback; every run reports which tier answered. |

## 2. `docs-kit`

| Field | Value |
|---|---|
| Repository | https://github.com/archi-ai-labs/docs-kit *(public)* |
| Version submitted | **0.9.0**, tagged `v0.9.0` |
| Licence | MIT |
| One line | A three-layer documentation model with deterministic checks and an HTML read model generated from the markdown. |
| Skills | 5 — `docs-init`, `docs-sync`, `docs-check`, `docs-render`, `brief` |
| Hooks | **2, warn-only** — see §2.1 |
| MCP servers | **none** |
| Sub-agents | **none** |
| Reachable by Claude on its own | `brief` only |
| Default state on install | **disabled** (`defaultEnabled: false`) — see §2.2 |
| Always-on context cost | **~77 tokens**, one skill description |
| Runtime requirements | Claude Code v2.1.154+ for the opt-in install. `docs-render` wants Python 3.9+ and skips with a message if absent. Scripts hold a bash 3.2 / BSD awk floor. |

### 2.1 Hook disclosure

Declare these explicitly. A reviewer seeing hooks will look for exactly this.

| Event | Matcher | Runs | What it does |
|---|---|---|---|
| `PostToolUse` | `Edit\|Write\|MultiEdit` | `scripts/hook_architecture_warn.sh` | Prints a warning when an Architecture document is edited outside the Decision path. |
| `Stop` | *(all)* | `scripts/hook_stop_scan.sh` | Prints a warning when the session touched something sensitive and the docs do not record it. |

Both are **warn-only**: they emit text and never block, never edit a file, and
never call the network. Both resolve their script through
`${CLAUDE_PLUGIN_ROOT}`, so nothing is read from outside the plugin directory.

### 2.2 Why it installs disabled

Hooks run without the user asking on that particular occasion, so `docs-kit`
ships `defaultEnabled: false` and waits to be switched on. Existing installs are
unaffected — a setting already in `enabledPlugins` outranks the default at every
scope — and Claude Code before v2.1.154 ignores the field.

## 3. Evidence

Re-run before submitting and paste the current output. This was taken at
trim-kit 0.5.0 / docs-kit 0.9.0:

```
$ cd trim-kit && claude plugin validate . --strict
Validating plugin manifest: .../trim-kit/.claude-plugin/plugin.json

✔ Validation passed

$ cd docs-kit && claude plugin validate . --strict
Validating plugin manifest: .../docs-kit/.claude-plugin/plugin.json

✔ Validation passed

$ cd agent-marketplace && claude plugin validate . --strict
Validating marketplace manifest: .../agent-marketplace/.claude-plugin/marketplace.json

✔ Validation passed
```

Both repos also run `claude plugin validate . --strict` in CI on every push and
pull request, so the state above is not a one-off local result.

## 4. After you submit

- Review takes as long as the queue takes. **Distribute via the GitHub URL or the
  `archi-ai-labs` catalog in the meantime** — nothing about submitting changes
  how the plugins install today.
- On approval, the plugin is **pinned to a commit SHA** in the community catalog,
  and Anthropic's CI advances that pin as you push. **You do not resubmit for
  updates.**
- The public catalog **syncs nightly** from the review pipeline, so there is a
  delay between approval and the plugin appearing in
  [`marketplace.json`](https://github.com/anthropics/claude-plugins-community/blob/main/.claude-plugin/marketplace.json).
  Search for the plugin name there to check whether it is installable yet.
- Approval is not promised. `claude-community` runs automated review and safety
  screening, not an audit, and an "Anthropic Verified" badge is a separate,
  further review that no plugin is entitled to.

## 5. Checklist before opening the form

- [ ] Both repos public, `main` pushed, working tree clean.
- [ ] Tags `v0.5.0` and `v0.9.0` on the remote, and CI green on both.
- [ ] `claude plugin validate . --strict` re-run, output pasted into §3.
- [ ] §1 and §2 versions match the current `plugin.json` of each repo.
- [ ] [`COMMUNITY-PLUGIN-STANDARD.md`](COMMUNITY-PLUGIN-STANDARD.md) §11 walked
      for each plugin.
- [ ] [`README-STANDARD.md`](README-STANDARD.md) §6 walked for each plugin.
- [ ] Submitting through the form, **not** a pull request.
