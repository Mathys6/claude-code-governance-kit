#!/bin/sh
# SessionStart hook: prints CONTRACT.md so Claude Code adds it to the session context.
# Plain stdout from a SessionStart hook is injected as additional context.
#
# Lookup order for the contract:
#   1. $CONTRACT_FILE (explicit override)
#   2. ../CONTRACT.md next to this script (works for .claude/hooks/ and for the kit itself)
#   3. $CLAUDE_PROJECT_DIR/.claude/CONTRACT.md
#
# Portable POSIX sh. Read-only. Fail-open: it never blocks a session from starting.

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd) || script_dir=.

contract=""
for candidate in "${CONTRACT_FILE:-}" "$script_dir/../CONTRACT.md" "${CLAUDE_PROJECT_DIR:-.}/.claude/CONTRACT.md"; do
  if [ -n "$candidate" ] && [ -r "$candidate" ]; then
    contract=$candidate
    break
  fi
done

# No readable contract: stay silent rather than break the session.
[ -n "$contract" ] || exit 0
contract_dir=$(CDPATH= cd -- "$(dirname -- "$contract")" 2>/dev/null && pwd) || contract_dir=$(dirname -- "$contract")
contract="$contract_dir/$(basename -- "$contract")"

drift_log="${DRIFT_LOG_FILE:-$contract_dir/memory/drift-log.md}"

# Count real drift entries: headings that start with a date. Examples are prefixed and not counted.
drift_count=0
if [ -r "$drift_log" ]; then
  drift_count=$(grep -c '^### [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' "$drift_log" 2>/dev/null) || drift_count=0
fi

echo "=================================================================="
echo "SESSION CONTRACT: hard rules (source: $contract)"
echo "Drift log: $drift_count logged drift(s). A rule ignored in practice gets a new entry."
echo "=================================================================="
echo ""
cat "$contract"

exit 0
