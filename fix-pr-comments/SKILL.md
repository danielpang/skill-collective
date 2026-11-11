---
name: fix-pr-comments
description: Use when the user asks to check, review, or fix GitHub PR comments, or when finishing a PR and wanting to address reviewer feedback. Checks the current branch for an open PR, fetches unresolved comments, triages them, and implements fixes for real issues.
---

# Fix PR Comments

Automatically fetch unresolved GitHub PR comments for the current branch, triage them, and fix real issues.

**Announce at start:** "I'm using the fix-pr-comments skill to check and address PR feedback."

## Prerequisites

- Must be in a git repository
- `gh` CLI must be authenticated
- Current branch should have an open PR

## Step 1: Find the PR

Run:
```
gh pr list --head $(git branch --show-current) --json number,title,url,state --jq '.[] | select(.state == "OPEN")'
```

If no open PR is found:
- Tell the user: "No open PR found for the current branch."
- Stop.

## Step 2: Fetch Unresolved Comments

Use the GraphQL query below — it's the only approach that returns `isResolved` cleanly AND gives you the `databaseId` you'll need in Step 5 to post replies. Do NOT skip `databaseId`: GraphQL's `id` is a node ID like `PRRC_kwDO…`, but the REST reply endpoint only accepts the integer `databaseId`.

```
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            isResolved
            comments(first: 10) {
              nodes {
                databaseId
                body
                path
                line
                author { login }
              }
            }
          }
        }
      }
    }
  }
' -f owner=OWNER -f repo=REPO -F pr=PR_NUMBER
```

Filter to only **unresolved** threads. If all threads are resolved:
- Tell the user: "All PR comments are already resolved."
- Stop.

For each unresolved thread, keep the **first comment's `databaseId`** — that's the thread's top-level comment, and the one you'll reply to.

## Step 3: Triage Each Comment

For each unresolved comment, read the referenced file and surrounding code context, then classify as:

| Classification | Action |
|---|---|
| **Real bug/issue** | Will fix |
| **Valid improvement** | Will fix |
| **False positive / not applicable** | Skip with explanation |
| **Style preference / subjective** | Skip with explanation |
| **Already addressed** | Skip with explanation |

**Triage criteria — a comment is a real issue if:**
- It identifies a bug, crash, or incorrect behavior
- It identifies a security vulnerability
- It identifies a performance problem with measurable impact
- It points out missing error handling that could cause failures
- It identifies a real race condition or timing issue

**A comment is NOT a real issue if:**
- It's a bot-generated suggestion that doesn't apply to the actual code
- It suggests a style change with no functional impact
- It's about code that was intentionally written that way (check git blame / context)
- It misunderstands the code's purpose
- It's already been addressed by other changes in the PR

Present the triage summary to the user in a table:

```
| # | File | Comment | Source | Verdict | Reason |
|---|------|---------|--------|---------|--------|
| 1 | src/foo.ts:42 | "Missing null check" | @reviewer | Real issue | Could crash on undefined |
| 2 | src/bar.ts:10 | "Use const" | bot | Skip | Style preference |
```

## Step 4: Implement Fixes

For each comment classified as a real issue:

1. Read the affected file
2. Understand the full context (not just the flagged line)
3. Implement the minimal correct fix
4. If the fix touches test assertions, update them

After all fixes:
1. Run the project's type-check command (e.g., `npm run check-types`, `tsc --noEmit`)
2. Run the project's test suite
3. Fix any failures caused by the changes

## Step 5: Reply to Each Comment

After implementing fixes (and verifying types + tests pass), reply to **every** unresolved comment thread — both fixed and skipped. Each reply must describe the fix or the reasoning, not just "Fixed."

**Endpoint (NOTE: includes `{pull_number}` — a common mistake is to omit it and get a 404):**

```
gh api repos/{owner}/{repo}/pulls/{pull_number}/comments/{comment_id}/replies \
  -X POST \
  -f body="..."
```

`{comment_id}` is the `databaseId` captured from the GraphQL query in Step 2. Save the response's `html_url` — you'll list it in the Step 6 report so the user can verify the reply landed without asking.

### Reply content — required structure

Every **fixed** reply MUST include, at minimum:

1. **What changed** — the file path (and function/section when relevant).
2. **The change itself** — either a short diff/code snippet, or a one-sentence description of the mechanical change when it's obvious from the file path.
3. **Why** — the reason the fix is correct, or the reasoning if you deviated from the reviewer's suggested approach.
4. **Verification** — tests run and result (e.g. "20/20 tests still pass"), when the fix touched code with tests.

Every **skipped** reply MUST include:
- **False positive / not applicable**: the specific fact that makes the comment not apply (e.g. "the worker already handles 404 as success").
- **Style preference**: the intentional choice and its rationale.
- **Already addressed**: a pointer to the commit / line / other comment where it was addressed.

Keep replies under ~6 sentences when possible. A code snippet counts as one "sentence."

### Reply templates

**Fix template:**
> Fixed in `<file>`. [One-line description of what changed, or a short diff]. [Why — the root cause this addresses, or why this approach was taken over an alternative]. [Tests: N/N still pass.]

**Fix with deviation template** (when your fix differs from what the reviewer suggested):
> Fixed with [approach]. I didn't take the suggested approach of [X] because [reason it wouldn't have worked / would have been wrong layer]. The protective fix belongs at [correct layer]. [Tests: N/N still pass.]

**Skip template (false positive):**
> This comment doesn't apply — [specific fact about the code or context that invalidates the concern].

**Skip template (intentional):**
> This is intentional: [the design choice], because [the reason].

### Good vs bad examples

**❌ Bad** — too terse, doesn't explain or verify:
> Fixed. Changed the regex.

**❌ Bad** — doesn't describe the fix or where:
> Good catch, updated!

**✅ Good** — file, change, why, verification:
> Fixed in `src/lib/api-key.ts`. `parseApiKeyHeader` now uses `/^Bearer\s+(\S+)$/i` with a leading `.trim()` — accepts `Bearer`/`bearer`/`BEARER` case-insensitively per RFC 6750 and rejects any token containing whitespace. Added three new tests covering case-insensitive acceptance, whitespace rejection, and tolerance of trailing header whitespace. Tests: 17/17 pass.

**✅ Good** — deviation with reasoning:
> Fixed with a safer SQL ORDER BY rather than the suggested Zod regex. This PR only defines **response** schemas, so a `regex(/^\d+$/)` on them would only reject malformed outgoing responses *after* the DB query had already thrown. The protective fix belongs at the SQL layer: `CASE WHEN itemNumber ~ '^\d+$' THEN CAST(... AS INTEGER) ELSE NULL END NULLS LAST`. Tests: 20/20 pass.

**✅ Good** — skip with concrete reasoning:
> This is intentional — the worker already handles 404 from Drive as a success (idempotent delete), so no additional guard is needed here.

### Verify replies landed

Immediately after posting, the response JSON contains an `html_url`. Keep the list of URLs for Step 6. Do NOT re-query the unresolved threads just to "confirm" — the response status + `html_url` are your confirmation. If a POST returned a non-2xx status, surface the error to the user and retry.

## Step 6: Report

Show a summary. **Always include the `html_url` for each posted reply** — the user will not have to ask whether replies actually landed.

```
## PR Comment Fixes

**PR:** #123 - Title (URL)
**Unresolved comments:** N
**Real issues found:** X
**Fixes implemented:** X
**Skipped:** Y (with reasons)

### Changes Made
- `file1.ts` — description of fix
- `file2.ts` — description of fix

### Replies posted
- Thread @ `file1.ts:42` (reviewer): <html_url>
- Thread @ `file2.ts:10` (reviewer): <html_url>

### Verification
- Type check: PASS/FAIL
- Tests: PASS/FAIL (N tests)
```

## Important Notes

- Do NOT fix comments that are style preferences or false positives — explain why they're skipped
- Do NOT over-engineer fixes — make the minimal change that addresses the issue
- If a comment requires a large architectural change, flag it to the user instead of implementing
- Always verify fixes compile and tests pass before reporting
- If unsure whether a comment is a real issue, err on the side of fixing it
- Always reply to ALL unresolved threads — both fixed and skipped
- Every reply MUST describe the fix (file, change, why) or the reason for skipping — never just "Fixed." See Step 5 templates
- Every Step 6 report MUST list each posted reply's `html_url` so the user can verify replies landed without asking

