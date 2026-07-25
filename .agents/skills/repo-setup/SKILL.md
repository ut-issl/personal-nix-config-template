---
name: repo-setup
description: >-
  Interactive setup of a personal configuration repository newly created from this template:
  Git identity check and development tooling setup (pre-commit hooks, Renovate, Conventional Commits, REUSE).
  Use when the user asks to set up, initialize, or bootstrap the repository or its tooling.
  May also be used proactively,
  but only when home-modules/user/git.nix still has the personal identity lines commented out
  (a clear sign the repository is fresh from the template); otherwise wait for an explicit request.
---

# Repository Setup

Guide the user through setting up a personal Home Manager configuration repository created from this template.

This skill configures the repository contents only.
Do not assume that Nix or Home Manager is available, and never run `nix` or `home-manager` commands;
applying the configuration is out of scope and covered by the Getting Started section of `README.md`.

Users arrive here in one of two states:

- fresh from the template, with nothing configured yet, or
- after completing the Getting Started steps of `README.md`, with the Git identity already set.

Therefore, at the start of each step check the current state of the repository,
and if the step is already done, silently skip it and move on to the next step.
If this skill was triggered proactively rather than by an explicit request,
confirm with the user that they want to run the setup now before touching anything.

Follow the steps below in order, one step at a time.
Before each step, briefly explain what it does, then ask the user how to proceed.
Never enable an opt-in feature without an explicit yes from the user; if the user declines a step, skip it and move on.
Converse in the language the user writes in, but keep all edits (comments, commit messages, etc.) in English.

## 1. Update README badges

Check lines 14–15 of `README.md` for the CI and Test badge URLs.
If they still reference `ut-issl/personal-nix-config-template`, replace all four occurrences
(two in the image URL and two in the link URL across the two badges)
with the user's `<owner>/<repo>`.

Detect the owner and repo from the `origin` remote URL.
If `origin` is not set or already matches `ut-issl/personal-nix-config-template`, skip this step.

## 2. Configure your Git identity

Check `home-modules/user/git.nix`; if the `userName` and `userEmail` lines are already set, skip this step.

Otherwise, ask the user for the name and email address to use as the Git author identity,
then uncomment the `userName` and `userEmail` lines under the "Personal identity" comment
and fill in the user's answers.

## 3. Install pre-commit hooks

If the git hooks are already installed (both `.git/hooks/pre-commit` and `.git/hooks/pre-push` exist), skip this step.

Otherwise, ask the user whether to install them now.
If yes, run:

```console
prek install --hook-type pre-commit --hook-type pre-push
```

If `prek` is not on PATH, run the same command via `uvx prek` instead.
If `uv` is not available either, skipping this step is fine.

## 4. Enable Renovate (opt-in)

### 4-1. Configuration

If the `enabled: false` line is already gone from `.github/renovate.json5`, skip to 4-2.

Explain: Renovate is preconfigured in `.github/renovate.json5` to track the pinned ISSL environment version,
Action SHAs, tool versions pinned in `.github/workflows/ci.yaml`, and pre-commit hooks.

If the user opts in:

- Delete the `enabled: false,` line (including its trailing comment) from `.github/renovate.json5`.
- Remind the user that the Renovate GitHub App must be installed for this repository to take effect.

### 4-2. README

After 4-1 is resolved (either just completed or already skipped), check whether the README
matches the actual state of `.github/renovate.json5`.

If Renovate is enabled (no `enabled: false` line) but the "Renovate" subsection of `README.md`
still says "It is disabled by default", update it:
replace that sentence with a note that Renovate is enabled
and the Renovate GitHub App must be installed for this repository to take effect.

Otherwise (Renovate is still disabled, or the README already reflects the enabled state), skip this part.

## 5. Enforce Conventional Commits (opt-in)

### 5-1. Configuration

If all three blocks below are already uncommented, skip to 5-2;
still offer to install the `commit-msg` hook at the end of this part if it is missing.

Explain: this enforces [Conventional Commits](https://www.conventionalcommits.org) on commit messages and PR titles
via [Commitizen](https://github.com/commitizen-tools/commitizen).
Linting the PR title is especially useful with squash merging, since the PR title becomes the squashed commit subject.

If the user opts in, uncomment all of the following blocks:

- the `lint-commit-messages` job in `.github/workflows/ci.yaml`
- the `lint-pr-title` job in `.github/workflows/manage-pull-requests.yaml`
- the `commitizen` repo block in `.pre-commit-config.yaml`

The `commitizen` hook runs at the `commit-msg` stage, which step 3 does not install.
Install it additionally (skip if `.git/hooks/commit-msg` already exists), with the same fallback rules as step 3:

```console
prek install --hook-type commit-msg
```

### 5-2. README

After 5-1 is resolved (either just completed or already skipped), check whether the README
matches the actual state of the CI jobs and pre-commit config.

If enforcement is enabled (the CI jobs are uncommented) but the README still says
"This is opt-in", update it:

- In the "Pre-commit Hooks" subsection, add `--hook-type commit-msg` to the `prek install` command
  so the documented command installs all three hook types at once.
- In the "Conventional Commits" subsection, replace the sentence that begins with
  "This is opt-in: uncomment `lint-commit-messages` in `ci.yaml`…" with a note that
  the enforcement is enabled (the CI jobs and the pre-commit hook are already configured).

Otherwise (the CI jobs are still commented out, or the README already reflects the enabled state),
skip this part.

## 6. Decide how to handle the REUSE workflow (opt-in)

### 6-1. Workflow

If `.github/workflows/reuse.yaml` is already deleted or its `if` guard is already removed, skip to 6-2.

Explain: `.github/workflows/reuse.yaml` checks [REUSE](https://reuse.software) compliance,
but its `lint-reuse` job is guarded to run only in the upstream template repository,
so it does nothing in this repository and can safely be left in place.

Ask the user which they prefer:

- Leave it as is (default; nothing to do).
- Delete `.github/workflows/reuse.yaml` to drop the workflow entirely.
- Remove the `if` guard from the `lint-reuse` job to enforce REUSE compliance in this repository.
  In that case, remind the user that every file they add must carry REUSE-compliant licensing information.

### 6-2. README

After 6-1 is resolved (either just completed or already skipped), check whether the
"REUSE Compliance" subsection of `README.md` matches the actual workflow state.

- If `reuse.yaml` was deleted but the README still references it, remove the entire subsection.
- If the `if` guard was removed but the README still says "This check is scoped to the template repository itself",
  replace the two paragraphs about the scoping and the `if` guard
  (from "This check is scoped…" through "…remove the `if` guard from the `lint-reuse` job.")
  with a note that every file must carry REUSE-compliant copyright and licensing information,
  either in the file itself or through an entry in `REUSE.toml`.
- Otherwise (the workflow is unchanged, or the README already reflects the current state), skip this part.

## 7. Clean up the setup skill (opt-in)

Ask whether to remove this skill now that setup is complete.
If yes:

- Delete the `.agents/skills/repo-setup/` directory and the `.claude/skills/repo-setup` symlink,
  and remove `.agents/` and `.claude/` entirely if they are empty afterwards.
- Remove the `repo-setup` entry from the "Agent Skills" section of `README.md`, since it points to the deleted skill.
- Remove the `.agents/**` and `.claude/**` entries from `REUSE.toml` if no other skills remain there.

## 8. Wrap up

Show a summary of everything that was changed or skipped.
Offer to run `prek run --all-files --skip no-commit-to-branch` (or the same via `uvx prek`)
to verify the edited files pass the hooks (`no-commit-to-branch` must be skipped when working on `main`).
Leave all changes uncommitted; committing and pushing are up to the user unless explicitly requested.
