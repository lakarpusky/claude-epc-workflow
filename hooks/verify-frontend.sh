#!/usr/bin/env bash
# verify-frontend.sh
# SubagentStop gate for code-writing agents (javascript-specialist, react-virtuoso).
# Blocks a subagent from finishing while `tsc --noEmit` or `eslint` fail, so broken
# code never folds back into the orchestrator's context. On failure it exits 2 and
# writes the compiler/linter output to stderr, which Claude Code feeds back to the
# subagent as the reason to keep working.
#
# Design guarantees (so it never breaks an agent):
#   1. Loop-safe   — honors stop_hook_active; enforces at most ONE fix cycle, then
#                    lets the agent stop even if checks still fail (the failure is
#                    still surfaced to the orchestrator via the summary).
#   2. Non-JS safe — no package.json => nothing to verify => pass (exit 0). Inert
#                    in your Lua (WoW) and Swift (iOS) repos.
#   3. Tooling safe— skips a check when its tool isn't resolvable, instead of
#                    failing on a missing binary. Only real type/lint errors block.
#   4. No hard deps— jq is used only if present; falls back cleanly without it, so
#                    the gate never silently no-ops on a machine that lacks jq.
#
# Reads the hook JSON on stdin.

set -uo pipefail

INPUT="$(cat)"

# 1. Loop guard (no jq needed). If a previous Stop hook already kept this agent
#    running, don't block again — one enforced fix cycle, then allow completion.
if printf '%s' "$INPUT" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

# 2. Resolve the subagent's working directory. Prefer the JSON cwd when jq is
#    available; otherwise use the process working directory (the project root).
CWD="$PWD"
if command -v jq >/dev/null 2>&1; then
  J="$(printf '%s' "$INPUT" | jq -r '.cwd // empty')"
  [ -n "$J" ] && CWD="$J"
fi
cd "$CWD" 2>/dev/null || exit 0

# 3. Only gate JS/TS projects.
[ -f package.json ] || exit 0

FAILED=""
TSC_LOG="$(mktemp)"; ESLINT_LOG="$(mktemp)"
trap 'rm -f "$TSC_LOG" "$ESLINT_LOG"' EXIT

# 4. Type-check — only if a tsconfig exists AND tsc resolves.
if [ -f tsconfig.json ] && npx --no-install tsc --version >/dev/null 2>&1; then
  if ! npx --no-install tsc --noEmit >"$TSC_LOG" 2>&1; then
    FAILED="${FAILED}TypeScript (tsc --noEmit) failed:
$(cat "$TSC_LOG")

"
  fi
fi

# 5. Lint — only if an eslint config exists AND eslint resolves.
if ls .eslintrc* eslint.config.* >/dev/null 2>&1 && npx --no-install eslint --version >/dev/null 2>&1; then
  if ! npx --no-install eslint . >"$ESLINT_LOG" 2>&1; then
    FAILED="${FAILED}ESLint failed:
$(cat "$ESLINT_LOG")
"
  fi
fi

# 6. Verdict.
if [ -n "$FAILED" ]; then
  printf 'Verification gate failed — fix these before finishing:\n\n%s' "$FAILED" >&2
  exit 2
fi

exit 0
