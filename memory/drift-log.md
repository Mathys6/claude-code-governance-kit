# Drift log

Append-only. When a rule from `CONTRACT.md` (or from memory or `CLAUDE.md`) is ignored in practice, add an entry here while the cause is still fresh. Two or three drifts on the same rule is the signal to harden it: clarify the wording, enforce it with a hook or a gate, or promote it into the contract.

`hooks/inject-contract.sh` counts the real entries (headings that start with a date) and shows the number at every session start.

## Format

```markdown
### YYYY-MM-DD · short title

- **Rule:** which rule drifted (contract number, memory note or doctrine section)
- **What happened:** what the agent did, factually
- **Impact:** what it cost or could have cost
- **Hardening:** the rule, hook or check added so it does not happen again
```

## Examples

> The three entries below are **invented examples** that illustrate the format. Their headings start with `[example]`, so the hook does not count them. Delete this section once you log your first real drift.

### [example] 2026-03-04 · subagent committed outside its worktree

- **Rule:** contract 8, subagents commit only in their own worktree.
- **What happened:** an implementer subagent was told to "work from" a worktree path. It ran its first `git commit` from the main checkout, so a stray commit landed on the local integration branch. The orchestrator noticed only because the SHA in the subagent's report did not exist in the worktree.
- **Impact:** about forty minutes to reset the branch and reapply the fix in the right place. Nothing was pushed.
- **Hardening:** every command in subagent prompts now starts with `cd <worktree> &&`, and the orchestrator runs `git log -1` in the worktree and `git status` in the main checkout after each task.

### [example] 2026-04-17 · merged a pull request with a red quality gate

- **Rule:** contract 5, never merge with a red quality gate.
- **What happened:** the quality job failed on a lint rule the agent judged unrelated to the diff. It said so in one line and merged in the same command.
- **Impact:** none this time, the failure was indeed unrelated. The next real regression would have gone through the same way.
- **Hardening:** the merge is now `&&`-conditioned on an explicit `pass` in the check output. An unrelated failure gets fixed or quarantined in its own pull request, never waived inline.

### [example] 2026-05-22 · unmeasured number in marketing copy

- **Rule:** `skills/regulated-communication`, no number that was not measured.
- **What happened:** asked for a landing-page section, the agent wrote "saves two hours per day per operator". No such measurement existed; the figure sounded plausible and the requester liked it.
- **Impact:** caught in review before publication. Published in a regulated sector, it is a misleading claim attached to the company's name.
- **Hardening:** the skill now requires a written source for every figure, and the agent states what it refused before it drafts.

## Entries

<!-- Real entries go below, newest last. Headings must start with the date: ### 2026-11-08 · title -->
