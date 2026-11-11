---
name: green-pr
description: Take over a GitHub pull request and make it green. Rebases the PR branch on the latest base branch, resolves merge conflicts, fixes CI failures, and force pushes with lease. Use when the user gives a PR URL and asks to take it over, fix its conflicts, get CI passing, or "make it green".
argument-hint: <pr-url>
---

# Green PR

Take over the pull request at `$ARGUMENTS` and leave it rebased on the latest base branch, free of conflicts, passing CI, and force pushed with lease.

If no PR URL or number was given, ask for one.

## 1. Read the PR

```bash
gh pr view <url> --json number,headRefName,baseRefName,headRepositoryOwner,isCrossRepository,mergeable,title,body,commits
gh pr checks <url>
```

Note the head branch, base branch, and whether it is a fork. For a fork, check that you can push (`maintainerCanModify`). If you can't, stop and tell the user.

## 2. Work in an isolated worktree

Do not check out the branch in the user's main checkout. It may hold uncommitted or untracked files that collide with the branch. Use a worktree in the scratchpad directory (or `/tmp` if there is none):

```bash
git fetch origin <base> <head>
git worktree add <scratch>/pr<number> -B <head> origin/<head>
```

For a fork, fetch with `gh pr checkout <number>` inside the worktree instead.

## 3. Rebase on the latest base

```bash
git log --oneline origin/<base>..HEAD   # the PR's own commits
git rebase origin/<base>
```

When it stops on conflicts, resolve each hunk by understanding both sides rather than picking one:

- Read what changed on the base since the PR branched (`git log origin/<base> -- <file>`, `git show`). Renames, removed endpoints, moved helpers, and new conventions on the base are the usual cause.
- Keep the PR's intent while following the base's current shape. If the base renamed something, the PR's new code uses the new name. If the base removed something the PR extended, drop the PR's part of it too, unless the PR's whole point is that thing. In that case ask the user.
- Search the PR's non-conflicting files for the same stale names too (`grep` for the old identifiers). Git only flags hunks that overlap.
- Read and follow the repo's CLAUDE.md conventions while resolving.

After each step: `git add` the resolved files, then `GIT_EDITOR=true git rebase --continue`. Make sure no conflict markers are left (`grep -rn '^<<<<<<<\|^>>>>>>>'`).

## 4. Verify locally

Install dependencies and run the project's static checks and the tests for the files the PR touches (find the commands in CLAUDE.md, package.json, Makefile, or CI config). Fix what fails. Put each fix in its own commit on top of the PR's commits, unless it belongs inside a conflict resolution.

## 5. Fix CI failures

Look at what CI reported on the PR before the rebase, and again after you push:

```bash
gh pr checks <url>
gh run view <run-id> --log-failed
```

Reproduce each failure locally where you can, fix the root cause (don't skip or weaken tests), and commit. Some failures are unrelated to the PR: flaky tests, or a failure that also happens on the base branch. Check the base's latest CI run, then say so instead of "fixing" them.

## 6. Force push with lease

```bash
git push --force-with-lease origin <head>
```

Never push with a bare `--force`. If the lease is rejected, someone else pushed. Fetch, look at what they pushed, rebase onto it, and push again.

Then watch CI until it finishes (`gh pr checks <url> --watch`) and go back to step 5 if anything fails. Check that GitHub reports the PR as `MERGEABLE`.

## 7. Clean up and report

```bash
git worktree remove <scratch>/pr<number> --force
```

Report briefly: that the PR is rebased and pushed, how each conflict was resolved and why (especially anything dropped from the PR), what CI fixes were made, the final check status, and anything not verified.
