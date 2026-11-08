# AI code gate: a CI gate designed for agent-written code

Agents write plausible code faster than humans can review it. Review bandwidth becomes the bottleneck, so the gate has to catch what a tired reviewer misses: unsafe data flows, leaked personal data, complexity creeping in one pull request at a time. This page describes the design generically; pick the tools that fit your stack.

## What blocks, what only signals

| Family | Blocks on | Why |
| --- | --- | --- |
| **Static analysis with taint tracking** | any finding at `error` level; `warning` stays visible in the report | unsanitized input reaching a query, a shell, a redirect or the DOM is the classic plausible-looking bug |
| **Personal-data leak scan** | sensitive fields flowing into logs, URLs or third-party calls | agents log generously; in a regulated product one log line can be an incident |
| **Lint, `error` tier** | new violations only (baseline below): loose types, unhandled promises, layer boundaries, security rules, suppression without a reason | plausible bug, vulnerability or project contract |
| **Lint, `warn` tier** | never | form and readability; a long page component is not a fault |
| **Complexity** | one blocking measure (cognitive complexity), the rest as warnings | cyclomatic complexity measures the same thing with far more noise |
| **Duplication, dead code** | never, but every failure on the main branch sends a notification | hygiene is not a vulnerability; a silent non-blocking check measures nothing |
| **The gate itself** | a faulty fixture not detected, a custom rule whose own test fails, a missing baseline | a gate that silently stops detecting is worse than no gate |

## Ratchet with a baseline

Existing violations are recorded in a generated baseline file; only **new** ones fail. When code is fixed, the tool reports the now-useless suppression and the baseline must shrink in the same pull request. Debt can only go down. Nobody edits the baseline by hand, and a diff that grows it is refused in review.

Always build the dependent packages before linting or re-baselining. Type-aware rules go quiet when imports resolve to unknown types, and a baseline generated in that state is wrong in both directions.

## Exceptions: line by line, with a reason

- Every inline suppression names the rule **and** gives a reason; a bare suppression is itself an error.
- Inline disables that cannot carry a reason are banned by a custom rule.
- Never disable a rule globally without a dedicated pull request that explains why. Invisible exceptions empty a gate in three months.

## Testing the gate

Keep a folder of small fixtures, each containing exactly one fault the gate must catch (tainted query, data logged, bare suppression), plus clean fixtures that must pass. The gate's test suite runs them against the real binaries, pinned by version and checksum. Custom rules ship with their own rule tests.

## Speed

On pull requests, scan only the changed files when findings are file-local, and the touched packages for tools that cannot narrow further. A change to a global file (lockfile, lint config, CI workflows) triggers a full scan. A full scan runs every night and opens an issue when it fails. If the diff base cannot be found, fall back to a full scan, never to a guess.

## Lessons from calibration

- **A gate that blocks ordinary code does not filter AI output; it trains reflex suppressions.** Measure the violation rate on normal work before choosing what blocks.
- **Separate vulnerabilities from hygiene.** Stopping a release because duplication moved by half a point confuses the two.
- **A non-blocking check needs a notification**, or it quietly becomes a number nobody reads.
- **Memory limits are a signal.** When the lint job approaches its memory ceiling, raise the machine or move the job; do not raise the ceiling into a silent freeze.
