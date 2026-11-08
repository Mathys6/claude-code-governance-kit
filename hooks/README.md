# Hooks

## `inject-contract.sh`

Claude Code runs `SessionStart` hooks when a session starts, resumes, is cleared or is compacted. Whatever the hook prints on stdout is added to the model's context. This script prints `CONTRACT.md` with a one-line header that shows how many drifts the drift log holds.

Why it matters: `CLAUDE.md` is long and gets diluted as a session grows, and a compaction can summarize away the one rule you needed. Re-injecting a short contract on `compact` puts the hard rules back at full strength.

Properties:

- POSIX `sh`, no bash-isms, no dependency beyond `grep` and `cat`.
- Read-only and idempotent.
- Fail-open: no readable contract means no output and exit 0. A broken hook must never block a session.

### Wiring

Merge `settings.example.json` into your project's `.claude/settings.json`. The `matcher` covers the four `SessionStart` sources:

```json
"SessionStart": [
  {
    "matcher": "startup|resume|clear|compact",
    "hooks": [
      { "type": "command", "command": "sh \"$CLAUDE_PROJECT_DIR/.claude/hooks/inject-contract.sh\"" }
    ]
  }
]
```

The sample also denies reads of `.env` files, which backs rule 2 of the contract with a hard permission.

### Test it

```sh
sh -n .claude/hooks/inject-contract.sh     # syntax check
sh .claude/hooks/inject-contract.sh | head # should print the header and the first rules
```

Overrides for unusual layouts: `CONTRACT_FILE=/path/to/CONTRACT.md` and `DRIFT_LOG_FILE=/path/to/drift-log.md`.

## Hooks worth building next

The kit ships one hook on purpose. These are the patterns that paid off next, once several Claude Code sessions ran in parallel on the same machine. They are described, not shipped, because they depend on your repo and tooling.

- **Confinement (`PreToolUse` on write tools and mutating `git`).** One session, one worktree. The shared main checkout is read-only for sessions and their subagents; writing into another live session's worktree is refused.
- **Resource locks (`PreToolUse` on shell commands).** Commands that touch a shared resource (local database, shared dev environment, merge to the integration branch) take a short lock for the duration of the command. Production needs an explicit lock taken on a human's request, as a separate command.
- **CI watcher.** After a merge to the integration branch, the merge lock is handed to a background watcher that releases it only when the CI run finishes. No second merge while CI runs, so two merges never cancel each other's pipeline.
- **Event feed (`UserPromptSubmit`, `PostToolUse`).** Each session receives what the others did that concerns it: branch moved, CI red, schema changed. The feed is labeled as data written by other sessions, never as instructions (contract rule 13).
- **Sweepers (`Stop`, `SubagentStop`, `SessionEnd`).** Release whatever a refused or crashed command left behind, with a TTL as the last safety net.

Design rules that held up: fail-open on internal errors, a kill switch, a fast path that exits in milliseconds for commands with nothing to guard, and refusals that say who holds what and how to ask.
