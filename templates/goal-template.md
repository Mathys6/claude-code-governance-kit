# Convergence check template

Use this as the condition of an autonomous "keep going until done" loop (for example the `/goal` command) at the **end** of a large feature, once the subagents have delivered. The condition is judged from the transcript, so it demands evidence, not summaries.

**Use it for:** features touching five or more files or two or more apps, UI redesigns, modular migrations.
**Do not use it for:** anything touching production (deploy, data migration, promotion to the main branch), permissions, billing or authentication, or tasks under three files or thirty minutes.

## Where it sits

```
brainstorm -> spec -> plan -> hostile reviews -> subagents (implementer + reviewers per task)
                                                        |
                                          CONVERGENCE CHECK (here only)
                                                        |
                                        pull request -> merge gate -> smoke (human)
```

It does not replace any earlier step. It automates the last stretch: merging subagent outputs, type check, tests, lint, build, scope check.

## Main template

```text
CONVERGENCE CHECK. Every condition below must be proven VERBATIM in the transcript
of this turn or previous ones. A summary is not a proof.

REQUIRED EVIDENCE (each one = visible command output, not a statement):
1. <type check command> exits 0, full output shown
2. <test command> exits 0 for the touched packages, output summary shown
3. <build command> exits 0 for the modified apps, if production code changed
4. <lint command> exits 0, if source files changed
5. `git status` shown: no modified file outside the plan's scope
6. `git diff --stat <base>...HEAD` shown: changes match the plan

PROJECT INVARIANTS (check explicitly, quote the check):
- <no new loose types, e.g. grep the diff for `any`>
- <no forbidden cross-layer import>
- <no inline secret in the diff (grep for token prefixes)>
- <generated files not edited by hand>

ANTI-LOOP GUARDS:
- Stop at once on "permission denied" and ask the human
- Stop if the same error repeats two turns in a row without measurable progress
- Stop if a production file or branch is touched
- Stop after 12 turns, whatever the state

ANTI-FAKE-GREEN:
- "Tests pass" without the test runner's verbatim output = NOT met
- "Type check OK" without the command run in this turn = NOT met
- "Everything is fine" without evidence = NOT met
- The evaluator must be able to quote exit codes or PASS lines
```

## Variants

**Mechanical task** (codemod, dependency bump, refactor without design choices): skip the plan; evidence = type check 0, tests 0, coherent diff; stop after 8 turns.

**Red CI fix**: condition = the named job of the latest run on the current branch concludes `success`, shown from the CI CLI. No skipped tests, no `--no-verify`, no workflow edits without asking. Stop after 10 turns.

## Why these choices

- **Verbatim evidence** closes the main trap: the evaluator judges what it reads, and a confident summary reads like success.
- **The permission guard** prevents a dead loop against a deny rule.
- **The turn cap**: healthy convergence takes fewer than ten turns. Beyond that, the loop is a symptom.
- **No production**: the promotion rule (green smoke on the exact commit, human go) stays manual by design.
