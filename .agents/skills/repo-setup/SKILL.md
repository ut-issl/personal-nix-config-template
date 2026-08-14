---
name: repo-setup
description: >-
  Interactive setup of a personal configuration repository newly created from this template:
  Git identity check, shell choice, development tooling setup (pre-commit hooks, Renovate, Conventional Commits, REUSE),
  and README update to match the new repository.
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

## 1. Configure your Git identity

Check `home-modules/user/git.nix`; if the `user.name` and `user.email` lines are already set, skip this step.

Otherwise, ask the user for the name and email address to use as the Git author identity,
then uncomment the `user.name` and `user.email` lines under the "Personal identity" comment
and fill in the user's answers.

## 2. Choose your shell

If the `home-bash-only` check is already gone from `flake.nix`, skip this step.

Explain: the shared ISSL environment enables Zsh by default, and its Bash configuration applies either way.
This is a repository-wide choice rather than a per-host one,
on the assumption that the user uses the same shell on every machine.

Ask which shell the user wants.
If they want a Bash-only environment:

- Uncomment the `issl.zsh.enable = false;` line in `home-modules/user/shell.nix`.
- Add `zsh-enabled: false` to the `with:` block of the `user-repo` job in `.github/workflows/test.yaml`,
  so that the environment tests expect a Bash-only result.

If they keep Zsh, delete `home-modules/user/shell.nix` and leave `.github/workflows/test.yaml` as it is.
That file carries nothing but the opt-out, and the shared default already gives them Zsh.
Mention that turning Zsh off later means putting the line back in a module under `home-modules/user/`
and adding `zsh-enabled: false` to `.github/workflows/test.yaml`.

Either way, delete the `home-bash-only` entry from `checks` in `flake.nix`.
The template keeps it so that both shells stay working for whoever adopts it next.
This repository has just settled on one shell, so the check would either duplicate `home`
or build a configuration nobody here applies.
Leave the `extraModules` argument of `mkHomeConfiguration` alone; the module list still uses it.

If the user picks Bash, mention that `home-modules/user/zsh.nix` stays in place but takes effect only
when Zsh is enabled, so the choice can be reverted later by commenting the line out again
and dropping `zsh-enabled: false` from `.github/workflows/test.yaml`.

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

If the `enabled: false` line is already gone from `.github/renovate.json5`, skip this step.

Explain: Renovate is preconfigured in `.github/renovate.json5` to track the pinned ISSL environment version,
Action SHAs, tool versions pinned in `.github/workflows/ci.yaml`, and pre-commit hooks.

If the user opts in:

- Delete the `enabled: false,` line (including its trailing comment) from `.github/renovate.json5`.
- Remind the user that the Renovate GitHub App must be installed for this repository to take effect.

## 5. Enforce Conventional Commits (opt-in)

If all three blocks below are already uncommented,
offer to install the `commit-msg` hook if it is missing, then proceed to the next step.

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

## 6. Decide how to handle the REUSE workflow (opt-in)

If `.github/workflows/reuse.yaml` is already deleted or its `if` guard is already removed, skip this step.

Explain: `.github/workflows/reuse.yaml` checks [REUSE](https://reuse.software) compliance,
but its `lint-reuse` job is guarded to run only in the upstream template repository,
so it does nothing in this repository and can safely be left in place.

Ask the user which they prefer:

- Leave it as is (default; nothing to do).
- Delete `.github/workflows/reuse.yaml` to drop the workflow entirely.
- Remove the `if` guard from the `lint-reuse` job to enforce REUSE compliance in this repository.
  In that case, remind the user that every file they add must carry REUSE-compliant licensing information,
  and add `.template-base` to the CC0 annotation in `REUSE.toml` when that file exists.

## 7. Update README for the new repository

Now that all opt-in decisions have been made, update `README.md` to reflect the actual state of this repository.
This step does not require a separate opt-in; it is a consistency fix.
Skip this step entirely if every item below is already up to date.

Detect the owner and repo from the `origin` remote URL
(handle both SSH and HTTPS forms, and strip a trailing `.git` suffix if present).
If `origin` is not set or already matches `ut-issl/personal-nix-config-template`,
skip the owner/repo-specific items (H1, badges) but still check the remaining items.

Update the following as needed:

- Replace the H1 heading (`# personal-nix-config-template`) with the repository name derived from `origin`.
- In the badge block near the top,
  find the CI and Test badge lines (the ones whose URLs contain `ut-issl/personal-nix-config-template/actions/workflows/`).
  Replace all four occurrences of `ut-issl/personal-nix-config-template`
  (one in the image URL and one in the link URL of each badge) with the user's `<owner>/<repo>`.
- Check the "Development Tooling" section intro sentence
  "Pre-commit hooks are part of the everyday workflow,
  while Renovate and Conventional Commits enforcement are opt-in."
  If the actual state of Renovate (`.github/renovate.json5`) or Conventional Commits
  (the CI jobs and commitizen block) no longer matches the "opt-in" claim,
  update the sentence to reflect which features are now enabled and which remain opt-in.
- If Renovate was enabled (no `enabled: false` line in `.github/renovate.json5`)
  but the "Renovate" subsection still says "It is disabled by default",
  replace that sentence with a note that Renovate is enabled
  and the Renovate GitHub App must be installed for this repository to take effect.
- If the commitizen block in `.pre-commit-config.yaml` is uncommented
  but the "Pre-commit Hooks" subsection's `prek install` command does not yet include `--hook-type commit-msg`,
  add it so the documented command installs all three hook types at once.
- If all three Conventional Commits blocks are uncommented
  (both CI jobs and the commitizen pre-commit hook)
  but the "Conventional Commits" subsection still contains the sentence that begins with
  "This is opt-in: uncomment `lint-commit-messages` in `ci.yaml`…",
  replace it with a note that the enforcement is enabled
  (the CI jobs and the pre-commit hook are already configured).
- If `home-modules/user/shell.nix` was deleted but the "Choose Your Shell" subsection is still there,
  remove that subsection along with the sentences in "Apply the Configuration" that point to it.
- If `reuse.yaml` was deleted but the "REUSE Compliance" subsection still references it,
  remove the entire subsection.
- If the `if` guard was removed from `reuse.yaml`
  but the "REUSE Compliance" subsection still says "This check is scoped to the template repository itself",
  replace the paragraph about the scoping and the `if` guard
  (from "This check is scoped…" through "…remove the `if` guard from the `lint-reuse` job.")
  with a short note that the check now runs in this repository.
- Review the rest of `README.md` for any remaining template-specific wording
  (e.g. phrasing that describes the template repository rather than the user's own repository)
  and adjust it to reflect that this is now the user's personal configuration repository.

## 8. Clean up the setup skill (opt-in)

Ask whether to remove this skill now that setup is complete.
This concerns `repo-setup` only; leave `customize` and `sync-template` in place, since both stay useful afterwards.
If yes:

- Delete the `.agents/skills/repo-setup/` directory and the `.claude/skills/repo-setup` symlink,
  and remove `.agents/` and `.claude/` entirely if they are empty afterwards.
- Remove the `repo-setup` entry from the "Agent Skills" section of `README.md`, since it points to the deleted skill.
- Remove the `.agents/**` and `.claude/**` entries from `REUSE.toml` if no other skills remain there.

## 9. Wrap up

Show a summary of everything that was changed or skipped.
Offer to run `prek run --all-files --skip no-commit-to-branch` (or the same via `uvx prek`)
to verify the edited files pass the hooks (`no-commit-to-branch` must be skipped when working on `main`).
Leave all changes uncommitted; committing and pushing are up to the user unless explicitly requested.
