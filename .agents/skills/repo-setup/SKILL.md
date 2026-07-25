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

This step has two independent parts: the configuration change and the README update.
Skip each part individually if it is already done, and skip the entire step only when both are done.

**Configuration**: if the `enabled: false` line is already gone from `.github/renovate.json5`, skip this part.

**README**: the README needs updating only when its description no longer matches the actual state.
If Renovate is still disabled (`enabled: false` is present),
the "disabled by default" sentence is accurate — skip this part.
If Renovate is enabled and the sentence is already gone, the README is up to date — skip this part too.

If either part still needs work, explain: Renovate is preconfigured in `.github/renovate.json5`
to track the pinned ISSL environment version,
Action SHAs, tool versions pinned in `.github/workflows/ci.yaml`, and pre-commit hooks.

If the user opts in:

- Delete the `enabled: false,` line (including its trailing comment) from `.github/renovate.json5`.
- Update the "Renovate" subsection of `README.md`:
  replace the sentence "It is disabled by default; to opt in, change the `enabled: false` line to `true` (or remove it),
  and make sure the Renovate GitHub App is installed for the repository."
  with a note that Renovate is enabled and the Renovate GitHub App must be installed for this repository to take effect.
- Remind the user that the Renovate GitHub App must be installed for this repository to take effect.

## 5. Enforce Conventional Commits (opt-in)

This step has two independent parts: the configuration changes and the README update.
Skip each part individually if it is already done, and skip the entire step only when both are done.

**Configuration**: if all three blocks below are already uncommented, skip this part;
still offer to install the `commit-msg` hook at the end of this part if it is missing.

**README**: the README needs updating only when its description no longer matches the actual state.
If the CI jobs are still commented out, the "opt-in" sentence is accurate — skip this part.
If the CI jobs are already uncommented and the README already reflects that
(no "This is opt-in" sentence, and `--hook-type commit-msg` is in the `prek install` command),
skip this part too.

If either part still needs work, explain: this enforces
[Conventional Commits](https://www.conventionalcommits.org) on commit messages and PR titles
via [Commitizen](https://github.com/commitizen-tools/commitizen).
Linting the PR title is especially useful with squash merging,
since the PR title becomes the squashed commit subject.

If the user opts in, uncomment all of the following blocks:

- the `lint-commit-messages` job in `.github/workflows/ci.yaml`
- the `lint-pr-title` job in `.github/workflows/manage-pull-requests.yaml`
- the `commitizen` repo block in `.pre-commit-config.yaml`

The `commitizen` hook runs at the `commit-msg` stage, which step 3 does not install.
Install it additionally (skip if `.git/hooks/commit-msg` already exists),
with the same fallback rules as step 3:

```console
prek install --hook-type commit-msg
```

Also update `README.md`:

- In the "Pre-commit Hooks" subsection, add `--hook-type commit-msg` to the `prek install` command
  so the documented command installs all three hook types at once.
- In the "Conventional Commits" subsection, replace the sentence that begins with
  "This is opt-in: uncomment `lint-commit-messages` in `ci.yaml`…" with a note that
  the enforcement is enabled (the CI jobs and the pre-commit hook are already configured).

## 6. Decide how to handle the REUSE workflow (opt-in)

This step has two independent parts: the workflow change and the README update.
Skip each part individually if it is already done, and skip the entire step only when both are done.

**Workflow**: if `.github/workflows/reuse.yaml` is already deleted or its `if` guard is already removed,
skip this part.

**README**: the README needs updating only when its description no longer matches the actual state.
If the workflow still has its `if` guard, the "scoped to the template repository" paragraph is accurate — skip this part.
If the workflow was deleted or the guard was removed and the README already reflects that
(no "This check is scoped to the template repository itself" paragraph), skip this part too.

If the workflow part still needs a decision, explain: `.github/workflows/reuse.yaml` checks
[REUSE](https://reuse.software) compliance,
but its `lint-reuse` job is guarded to run only in the upstream template repository,
so it does nothing in this repository and can safely be left in place.

Ask the user which they prefer:

- Leave it as is (default; nothing to do).
- Delete `.github/workflows/reuse.yaml` to drop the workflow entirely.
  Also update the "REUSE Compliance" subsection of `README.md`:
  replace the entire content (from the paragraph beginning with "The `reuse.yaml` CI workflow…"
  through the paragraph ending with "…remove the `if` guard from the `lint-reuse` job.")
  with a short note that the REUSE workflow has been removed and can be restored from the template if needed.
- Remove the `if` guard from the `lint-reuse` job to enforce REUSE compliance in this repository.
  Also update the "REUSE Compliance" subsection of `README.md`:
  replace the two paragraphs about the scoping and the `if` guard
  (from "This check is scoped…" through "…remove the `if` guard from the `lint-reuse` job.")
  with a note that every file must carry REUSE-compliant copyright and licensing information,
  either in the file itself or through an entry in `REUSE.toml`.
  Remind the user of this requirement as well.

If only the README part is stale (the workflow was already changed by a previous run),
update the README to match the current workflow state without re-asking the user.

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
