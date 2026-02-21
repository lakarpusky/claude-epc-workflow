---
name: git-workflows
description: |
  Git commands, workflows, and emergency recovery patterns.
  Use when committing, branching, resolving conflicts, or user mentions
  "git", "commit", "merge", "rebase", "conflict", "rollback", "revert".
  Complements git-wizard agent with ready-to-use commands.
metadata:
  author: Gabo
  version: 1.0.0
  companion-agent: git-wizard
---

# Git Workflows

Production-grade Git patterns for high-velocity teams.

---

## Conventional Commits

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(auth): add OAuth2 login` |
| `fix` | Bug fix | `fix(cart): correct price calculation` |
| `refactor` | Code change (no feature/fix) | `refactor(api): extract service layer` |
| `perf` | Performance improvement | `perf(list): virtualize large lists` |
| `test` | Add/fix tests | `test(auth): add login integration tests` |
| `docs` | Documentation | `docs(readme): update installation` |
| `style` | Formatting (no code change) | `style: format with prettier` |
| `chore` | Maintenance | `chore(deps): update dependencies` |
| `ci` | CI/CD changes | `ci: add coverage reporting` |

### Breaking Changes

```
feat(api)!: change response format

BREAKING CHANGE: response.data is now response.payload
```

---

## Branch Strategies

### Solo/Small Team (GitHub Flow)

```
main ─────●─────●─────●─────●─────
          │     ↑     │     ↑
          │     │     │     │
feature/auth ●──┘     │     │
                      │     │
feature/cart ─────────●─────┘
```

### Large Team (Trunk-Based + Feature Flags)

```
main ─────●─────●─────●─────●─────●─────
          │     │     │     ↑     │
          │     │     │     │     │
short-lived-1 ●─┘     │     │     │
                      │     │     │
short-lived-2 ────────●─────┘     │
                                  │
short-lived-3 ────────────────────┘

Features behind flags until ready.
```

---

## Daily Commands

### Stage & Commit

```bash
# Stage specific files
git add src/auth/login.js src/auth/logout.js

# Stage all changes
git add .

# Stage interactively (select hunks)
git add -p

# Commit
git commit -m "feat(auth): add login flow"

# Commit with body
git commit -m "feat(auth): add login flow" -m "Implements OAuth2 with Google and GitHub providers"
```

### Branching

```bash
# Create and switch
git checkout -b feature/auth

# Or (newer syntax)
git switch -c feature/auth

# Switch to existing
git checkout main
git switch main

# Delete merged branch
git branch -d feature/auth

# Delete unmerged branch (force)
git branch -D feature/auth
```

### Syncing

```bash
# Fetch all remotes
git fetch --all

# Pull with rebase (preferred)
git pull --rebase origin main

# Push
git push origin feature/auth

# Push and set upstream
git push -u origin feature/auth
```

---

## Rebase Workflow

### Interactive Rebase (Clean History)

```bash
# Squash last 3 commits
git rebase -i HEAD~3

# In editor:
# pick abc123 First commit
# squash def456 Second commit
# squash ghi789 Third commit

# Rebase onto main
git fetch origin
git rebase origin/main
```

### Handle Rebase Conflicts

```bash
# 1. Fix conflicts in files
# 2. Stage fixed files
git add <fixed-files>

# 3. Continue rebase
git rebase --continue

# Or abort
git rebase --abort
```

### Force Push After Rebase

```bash
# Safe force push (fails if remote has new commits)
git push --force-with-lease origin feature/auth

# Danger: overwrites everything
git push --force origin feature/auth  # ⚠️ Team coordination required
```

---

## Merge Strategies

### Fast-Forward Merge

```bash
git checkout main
git merge --ff-only feature/auth
# Only works if no new commits on main
```

### Merge Commit (No Fast-Forward)

```bash
git checkout main
git merge --no-ff feature/auth
# Creates merge commit even if FF possible
```

### Squash Merge

```bash
git checkout main
git merge --squash feature/auth
git commit -m "feat(auth): add login flow"
# All branch commits become single commit
```

---

## Conflict Resolution

### View Conflicts

```bash
# List conflicted files
git diff --name-only --diff-filter=U

# Show conflict markers
git diff
```

### Resolve Strategies

```bash
# Keep ours (current branch)
git checkout --ours path/to/file

# Keep theirs (incoming branch)
git checkout --theirs path/to/file

# Manual edit, then stage
git add path/to/file

# Use merge tool
git mergetool
```

---

## Emergency Recovery

### Undo Last Commit (Keep Changes)

```bash
git reset --soft HEAD~1
# Changes staged, ready to recommit
```

### Undo Last Commit (Discard Changes)

```bash
git reset --hard HEAD~1
# ⚠️ Changes lost (unless pushed)
```

### Revert Pushed Commit (Safe)

```bash
git revert <commit-sha>
# Creates new commit that undoes changes
```

### Find Lost Commits

```bash
git reflog
# Shows all HEAD movements
# Find SHA, then:
git checkout <sha>
# Or cherry-pick:
git cherry-pick <sha>
```

### Recover Deleted Branch

```bash
git reflog
# Find last commit of deleted branch
git checkout -b recovered-branch <sha>
```

### Fix Detached HEAD

```bash
git branch temp-recovery  # Save current state
git checkout main
git merge temp-recovery   # If you want the changes
```

### Unstage Files

```bash
git restore --staged <file>
# Or all:
git restore --staged .
```

### Discard Working Changes

```bash
git restore <file>
# Or all:
git restore .
# ⚠️ Uncommitted changes lost
```

---

## Stash Operations

```bash
# Save work in progress
git stash

# Save with message
git stash push -m "WIP: auth flow"

# List stashes
git stash list

# Apply most recent (keep stash)
git stash apply

# Apply and remove
git stash pop

# Apply specific stash
git stash apply stash@{2}

# Drop stash
git stash drop stash@{0}

# Clear all stashes
git stash clear
```

---

## Repository Forensics

### Find When Bug Was Introduced

```bash
git bisect start
git bisect bad HEAD          # Current is broken
git bisect good v1.0.0       # This version worked
# Git checks out middle commit
# Test and mark:
git bisect good  # or bad
# Repeat until found
git bisect reset
```

### Find Who Changed a Line

```bash
git blame path/to/file
# Or specific lines:
git blame -L 10,20 path/to/file
```

### Search Commit Messages

```bash
git log --grep="auth"
```

### Search Code Changes

```bash
git log -S "functionName" --oneline
```

---

## Multi-Agent Commit Organization

Based on files touched during a multi-agent task:

```
FILES FROM CONTEXT:
- src/components/Dashboard.jsx (modified)     → feat commit
- src/components/Dashboard.test.jsx (created) → test commit
- src/utils/cache.js (created)                → refactor commit

COMMIT STRATEGY:
1. refactor(utils): add cache utility
   - src/utils/cache.js

2. feat(dashboard): optimize render performance
   - src/components/Dashboard.jsx

3. test(dashboard): add integration tests
   - src/components/Dashboard.test.jsx
```

Each commit is:
- **Atomic** - Can be reverted independently
- **Deployable** - Doesn't break main
- **Reviewable** - Tells a clear story

---

## CI/CD Awareness

| Operation | CI Trigger | Risk Level |
|-----------|------------|------------|
| Push to feature branch | Tests run | Low |
| Push to main | May auto-deploy | High |
| Force push to main | Never | Critical |
| Merge PR | Tests + Deploy | Medium |
| Revert on main | Deploy | Low (safe) |

---

## Checklist Before Push

- [ ] `git status` shows expected files
- [ ] Commit messages follow conventional format
- [ ] Tests pass locally
- [ ] Lint/format passes
- [ ] No sensitive data committed
- [ ] Branch is up to date with main

---

## Dangerous Commands Reference

| Command | Risk | Alternative |
|---------|------|-------------|
| `git reset --hard` | Loses uncommitted work | `git stash` first |
| `git push --force` | Overwrites remote | `--force-with-lease` |
| `git clean -fd` | Deletes untracked files | `git clean -n` first (dry run) |
| `git checkout .` | Discards all changes | `git stash` if unsure |
