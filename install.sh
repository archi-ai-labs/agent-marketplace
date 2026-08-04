#!/usr/bin/env bash
#
# archi-ai-labs plugin installer
#
# Registers the archi-ai-labs marketplace and enables the plugins you name, by
# writing to Claude Code's settings.json. No interactive /plugin steps needed —
# Claude Code fetches and activates them on next start.
#
# Global (default, every project) — registers the catalog, enables trim-kit:
#   curl -fsSL https://archi-ai-labs.github.io/agent-marketplace/install.sh | bash
#
# Pick which plugins to enable:
#   curl -fsSL .../install.sh | bash -s -- --plugins trim-kit,docs-kit
#
# This project only:
#   ./install.sh --project
#
# The default enables ONLY trim-kit. docs-kit installs PostToolUse and Stop
# hooks, and switching hooks on for someone who did not ask for them is not a
# default anyone should have to discover afterwards.
#
set -euo pipefail

REPO="archi-ai-labs/agent-marketplace"
MARKETPLACE="archi-ai-labs"

SCOPE="global"
PLUGINS="trim-kit"

usage() {
  cat <<'USAGE'
usage: install.sh [--plugins a,b] [--project]

  --plugins LIST   comma-separated plugin names to enable (default: trim-kit)
                   available: trim-kit, docs-kit
  --project        write ./.claude/settings.json instead of ~/.claude/settings.json
  -h, --help       this message

The marketplace is registered either way; --plugins only chooses what is
switched on. Re-running is safe: the existing settings.json is backed up first,
and the two keys are deep-merged rather than overwritten.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --project)      SCOPE="project" ;;
    --plugins)      shift; [ $# -gt 0 ] || { echo "error: --plugins needs a value" >&2; exit 1; }; PLUGINS="$1" ;;
    --plugins=*)    PLUGINS="${1#--plugins=}" ;;
    -h|--help)      usage; exit 0 ;;
    *)              echo "error: unknown argument '$1'" >&2; echo >&2; usage >&2; exit 1 ;;
  esac
  shift
done

[ -n "$PLUGINS" ] || { echo "error: --plugins was given an empty list" >&2; exit 1; }

# Resolve the settings.json to edit.
if [ "$SCOPE" = "project" ]; then
  SETTINGS_DIR="$(pwd)/.claude"
else
  SETTINGS_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
fi
SETTINGS="${SETTINGS_DIR}/settings.json"

echo "archi-ai-labs installer"
echo "  scope    : ${SCOPE}"
echo "  settings : ${SETTINGS}"
echo "  plugins  : ${PLUGINS}"
echo

# Claude Code ships with Node.js, so it is a safe dependency for the JSON merge.
if ! command -v node >/dev/null 2>&1; then
  echo "error: 'node' not found. Claude Code requires Node.js — install it, then re-run." >&2
  exit 1
fi

# /trim-kit:scan prices plugins through a resolver that runs on whichever runtime
# is present: python3 (3.8+), else node (14+), else a POSIX-shell fallback that
# reads the bundled snapshot. There is no configuration where it produces nothing,
# so this is a note about precision, never a failure.
case ",${PLUGINS}," in
  *,trim-kit,*)
    if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
      echo "note: no 'python3' found — /trim-kit:scan will fall back to node, or to a"
      echo "      shell-only tier that reports plugin names and cost but no skill,"
      echo "      agent or MCP detail. Install Python 3.8+ or Node 14+ for the full audit."
      echo
    fi
    ;;
esac

mkdir -p "$SETTINGS_DIR"

# Back up any existing settings before touching them.
if [ -f "$SETTINGS" ]; then
  BACKUP="${SETTINGS}.bak-$(date +%Y%m%d-%H%M%S)"
  cp "$SETTINGS" "$BACKUP"
  echo "backed up existing settings -> ${BACKUP}"
fi

# Safe, idempotent deep-merge of the two required keys. Aborts (via non-zero
# exit) if the existing file is present but not valid JSON, so nothing is lost.
SETTINGS_PATH="$SETTINGS" REPO="$REPO" MARKETPLACE="$MARKETPLACE" PLUGINS="$PLUGINS" node <<'NODE'
const fs = require('fs');
const path = process.env.SETTINGS_PATH;

let s = {};
if (fs.existsSync(path)) {
  const raw = fs.readFileSync(path, 'utf8').trim();
  if (raw) {
    try {
      s = JSON.parse(raw);
    } catch (e) {
      console.error(`error: ${path} is not valid JSON — aborting so nothing is overwritten.`);
      console.error(`       fix it by hand (a backup was made) and re-run.`);
      process.exit(1);
    }
  }
}

const marketplace = process.env.MARKETPLACE;

s.extraKnownMarketplaces = s.extraKnownMarketplaces || {};
s.extraKnownMarketplaces[marketplace] = {
  source: { source: 'github', repo: process.env.REPO },
};

// Names are printed back one per line: a typo produces a key that does nothing,
// and the only way to notice is to see what was actually written.
const names = process.env.PLUGINS.split(',').map(p => p.trim()).filter(Boolean);
if (names.length === 0) {
  console.error('error: no plugin names left after parsing --plugins.');
  process.exit(1);
}

s.enabledPlugins = s.enabledPlugins || {};
for (const name of names) s.enabledPlugins[`${name}@${marketplace}`] = true;

fs.writeFileSync(path, JSON.stringify(s, null, 2) + '\n');
console.log(`wrote extraKnownMarketplaces["${marketplace}"]`);
for (const name of names) console.log(`wrote enabledPlugins["${name}@${marketplace}"] = true`);
NODE

echo
echo "Done. Next:"
echo "  1. Restart Claude Code (or run /reload-plugins) — it will fetch the plugins from GitHub."
case ",${PLUGINS}," in
  *,trim-kit,*) echo "  2. Run  /trim-kit:status  to see the commands and what this project already has on." ;;
esac
case ",${PLUGINS}," in
  *,docs-kit,*) echo "  -  Run  /docs-kit:docs-init  in the repo you want documented." ;;
esac
case ",${PLUGINS}," in
  *,now-board,*) echo "  -  Run  /now-board:now update  in a repo you work in — there is no board until that first write." ;;
esac
