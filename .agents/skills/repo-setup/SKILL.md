---
name: repo-setup
description: >-
  Interactive setup of a personal configuration repository newly created from this template:
  Git identity check, shell choice, development tooling setup (pre-commit hooks, Renovate, Conventional Commits, REUSE),
  and README update to match the new repository.
  Use when the user asks to set up, initialize, or bootstrap the repository or its tooling.
  May also be used proactively,
  but only when home-modules/git/git.nix still has the personal identity lines commented out
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
When offering choices, work out the recommended one before presenting them,
then list it first, whatever order the step lists the options in, and mark it as recommended;
each step that offers a choice names its recommendation.
Never enable an opt-in feature without an explicit yes from the user, even a recommended one;
if the user declines a step, skip it and move on.
Converse in the language the user writes in, but keep all edits (comments, commit messages, etc.) in English.

## 1. Configure your Git identity

Check `home-modules/git/git.nix`; if the `user.name` and `user.email` lines are already set, skip this step.

Otherwise, ask the user for the name and email address to use as the Git author identity,
then uncomment the `user.name` and `user.email` lines under the "Personal identity" comment and fill in the user's answers.

## 2. Choose your shell

If the `home-bash-only` check is already gone from `flake.nix`, skip this step.

Explain: the shared ISSL environment enables Zsh by default, and its Bash configuration applies either way.
This is a repository-wide choice rather than a per-host one,
on the assumption that the user uses the same shell on every machine.

Ask which shell the user wants, recommending Zsh.

For a Bash-only environment:

- Uncomment the `issl.zsh.enable = false;` line in `home-modules/shell/shell.nix`.
- Add `zsh-enabled: false` to the `with:` block of the `repository-based` job in `.github/workflows/test.yaml`,
  so that the environment tests expect a Bash-only result.

Mention that `home-modules/zsh/zsh.nix` stays in place but takes effect only when Zsh is enabled,
so undoing both edits brings Zsh back.

To keep Zsh, leave `home-modules/shell/shell.nix` as it is:
its commented line is where Zsh is turned off later, and the recipes add their lines to that file.
Mention that turning Zsh off later means uncommenting that line
and adding `zsh-enabled: false` to `.github/workflows/test.yaml`.

Either way, delete the `home-bash-only` entry from `checks` in `flake.nix`:
this repository now runs one shell, so the check would either duplicate `home` or build a configuration nobody here applies.
Leave the `extraModules` argument of `mkHomeConfiguration` alone; the module list still references it.

## 3. Install pre-commit hooks

If the Git hooks are already installed
(`pre-commit`, `commit-msg`, and `pre-push` all exist in the directory that `git rev-parse --git-path hooks` prints),
skip this step.

Otherwise, check whether `prek` is on `PATH`, or failing that, whether `uv` is available to run it as `uvx prek`.
If neither is, tell the user that this step is skipped because neither is available, and move on.

Otherwise, ask the user whether to install them now, recommending yes.
If yes, run:

```sh
prek install
```

Run the same command via `uvx prek` instead when `prek` is not on `PATH`.

## 4. Enable Renovate (opt-in)

If the `mode: 'silent'` line is already gone from `.github/renovate.json5`, skip this step.

Explain: Renovate is preconfigured in `.github/renovate.json5` to track the pinned ISSL environment version,
Action SHAs, tool versions pinned in `.github/workflows/ci.yaml`, and pre-commit hooks.
Until the user opts in, it runs in silent mode: it scans the repository but opens no pull requests or issues.
Some updates are configured to merge automatically,
which waits for the checks to pass only when they are required (see "Required Status Checks" in `README.md`).
Requiring checks is optional; step 9 points to it.

Recommend opting in.
If the user opts in:

- Delete the `mode: 'silent',` line from `.github/renovate.json5`.
- Remind the user to install the Renovate GitHub App for this repository if it is not installed yet.
  - Renovate takes effect only with the app.
  - Word the reminder as conditional rather than as a required step, since the app may well be installed already.

## 5. Enforce Conventional Commits (opt-in)

If all three blocks below are already uncommented, skip this step.

Explain: this enforces [Conventional Commits](https://www.conventionalcommits.org) on commit messages and PR titles via [Commitizen](https://github.com/commitizen-tools/commitizen).
Linting the PR title is especially useful with squash merging, since the PR title becomes the squashed commit subject.

Recommend opting in.
If the user opts in, uncomment all of the following blocks:

- the `lint-commit-messages` job in `.github/workflows/ci.yaml`,
  together with its entry in the `needs` of the `check-ci-results` job
- the `lint-pull-request-title` job in `.github/workflows/manage-pull-requests.yaml`
- the `commitizen` repo block in `.pre-commit-config.yaml`

The `commitizen` hooks run at the `commit-msg` and `pre-push` stages, which step 3 already installs.

## 6. Decide how to handle the REUSE workflow (opt-in)

If `.github/workflows/lint-reuse-compliance.yaml` is already deleted or its `if` guard is already removed, skip this step.

Explain: `.github/workflows/lint-reuse-compliance.yaml` checks [REUSE](https://reuse.software) compliance,
but its `lint-reuse-compliance` job is guarded to run only in the upstream template repository,
so it does nothing in this repository and can safely be left in place.

Check the visibility with `gh repo view <owner>/<repo> --json visibility`,
taking `<owner>/<repo>` from the `origin` remote as step 7 describes.
Ask the user whether the repository is public instead
when `origin` is not set or still points to `ut-issl/personal-nix-config-template`, or when the command fails.
Recommend enforcing REUSE compliance when the repository is public and deleting the workflow otherwise.
Ask the user which they prefer.

- Delete `.github/workflows/lint-reuse-compliance.yaml` to drop the workflow entirely.
- Remove the `if` guard from the `lint-reuse-compliance` job to enforce REUSE compliance in this repository.
  In that case, remind the user that every file they add must carry REUSE-compliant licensing information
  (the `customize` skill adds it to the files it creates),
  and add `.template-base` to the CC0 annotation in `REUSE.toml` when that file exists.
- Leave it as is (nothing to do).

## 7. Update README for the new repository

Now that all opt-in decisions have been made,
update `README.md` (and the `flake.nix` description) to reflect the actual state of this repository.
This step does not require a separate opt-in; it is a consistency fix.
Skip this step entirely if every item below is already up to date.

Detect the owner and repo from the `origin` remote URL
(handle both SSH and HTTPS forms, and strip a trailing `.git` suffix if present).
If `origin` is not set or already matches `ut-issl/personal-nix-config-template`,
skip the owner/repo-specific items (H1, badges, clone command) but still check the remaining items.

Update the following as needed:

- Replace the H1 heading (`# personal-nix-config-template`) with the repository name derived from `origin`.
- In the badge block near the top, find the CI and Test badge lines (the ones whose URLs contain `ut-issl/personal-nix-config-template/actions/workflows/`).
  Replace all four occurrences of `ut-issl/personal-nix-config-template`
  (one in the image URL and one in the link URL of each badge) with the user's `<owner>/<repo>`.
- Remove the `[!WARNING]` callout that describes the repository as an early-stage prototype.
  It describes the template, not this repository.
- Remove the paragraph above the numbered steps of "Getting Started"
  that tells the reader to create their own repository from this template.
  This repository has already been created from it.
- In the clone command of "Getting Started",
  replace `<your-account>/<your-repository>` with `<owner>/<repo>` and `<your-repository>` with `<repo>`.
- If the `user.name` and `user.email` lines in `home-modules/git/git.nix` are set
  but "Configure Your Git Identity" still tells the reader to uncomment them,
  rewrite that step to say the identity is already set in `home-modules/git/git.nix`, which is where to change it.
- In `flake.nix`, drop "template" from the `description` (`Personal Home Manager configuration template for …`).
- In the intro of the "Development Tooling" section,
  replace "This template ships a few quality and maintenance tools." with
  "This repository ships a few quality and maintenance tools."
  If Renovate (no `mode: 'silent'` line in `.github/renovate.json5`) or Conventional Commits
  (both CI jobs with the `lint-commit-messages` entry in the `needs` of `check-ci-results`,
  and the `commitizen` pre-commit hook) is enabled,
  replace the sentence that follows with the line for what is enabled, word for word
  (the comments only label the variants).
  That sentence is the shipped one,
  "Pre-commit hooks are part of the everyday workflow, while Renovate and Conventional Commits enforcement are opt-in.",
  or a variant below that an earlier run left and that no longer matches what is enabled:

  ```markdown
  <!-- Both enabled -->
  Pre-commit hooks are part of the everyday workflow, and Renovate and Conventional Commits enforcement are enabled.
  <!-- Renovate only -->
  Pre-commit hooks are part of the everyday workflow and Renovate is enabled,
  while Conventional Commits enforcement is opt-in.
  <!-- Conventional Commits only -->
  Pre-commit hooks are part of the everyday workflow and Conventional Commits enforcement is enabled,
  while Renovate is opt-in.
  ```

- If Renovate was enabled but the "Renovate" subsection still says "It is silent by default",
  replace the lines from "It is silent by default" through "…installed for the repository." with:

  ```markdown
  It is enabled in this repository and takes effect once the Renovate GitHub App is installed for it.
  ```

- If all three Conventional Commits blocks are uncommented
  but the "Conventional Commits" subsection still contains the sentence that begins with "This is opt-in:",
  change "can be checked against" in its first sentence to "are checked against",
  and replace the lines from "This is opt-in:" through "…also fails `check-ci-results`." with:

  ```markdown
  The checks run in [`lint-commit-messages` in `ci.yaml`](.github/workflows/ci.yaml),
  [`lint-pull-request-title` in `manage-pull-requests.yaml`](.github/workflows/manage-pull-requests.yaml),
  and the `commitizen` hooks in [`.pre-commit-config.yaml`](.pre-commit-config.yaml).
  ```

- If Zsh was kept (the `issl.zsh.enable = false;` line in `home-modules/shell/shell.nix` is still commented out),
  leave "Choose Your Shell", the paragraph in "Apply the Configuration" beginning "Zsh is enabled by default",
  and the startup-file caution as shipped: they already describe Zsh and how to turn it off.
- If that line is uncommented but "Choose Your Shell" still reads as an instruction,
  rewrite that subsection to state that this repository is Bash-only and that going back means
  commenting the line out again, dropping `zsh-enabled: false` from `.github/workflows/test.yaml`,
  and putting `~/.zshenv` and the `zsh/zsh.nix` parenthetical back into the startup-file caution.
  Reduce the paragraph in "Apply the Configuration" beginning "Zsh is enabled by default"
  to one sentence that says so and links to "Choose Your Shell",
  and drop `~/.zshenv` and the `zsh/zsh.nix` parenthetical from the startup-file caution.
- If `lint-reuse-compliance.yaml` was deleted but the "REUSE Compliance" subsection still references it,
  remove the entire subsection.
- If the `if` guard was removed from `lint-reuse-compliance.yaml`
  but the "REUSE Compliance" subsection still says "This check is scoped to the template repository itself",
  replace the paragraph about the scoping and the `if` guard
  (from "This check is scoped…" through "…remove the `if` guard from the `lint-reuse-compliance` job.") with:

  ```markdown
  The check runs in this repository, so every file you add must carry copyright and licensing information,
  either in an SPDX header or in an annotation in [`REUSE.toml`](REUSE.toml).
  ```

- Check the clause of the "Required Status Checks" subsection
  that runs from "checks from other workflows" through "have to be required separately.", over one line or two.
  Unless it is already the variant below for the current state,
  replace the whole clause with that variant (the comments only label the variants).
  The REUSE check runs when `lint-reuse-compliance.yaml` is present without the `if` guard:

  ```markdown
  <!-- The REUSE check runs, and the lint-pull-request-title job is uncommented -->
  checks from other workflows, such as `Lint pull request title` and `Lint REUSE compliance`,
  have to be required separately.
  <!-- The REUSE check runs, and the lint-pull-request-title job is commented out -->
  checks from other workflows, such as `Lint REUSE compliance`, have to be required separately.
  <!-- The REUSE check does not run (as shipped) -->
  checks from other workflows, such as `Lint pull request title`, have to be required separately.
  ```

- Review the rest of `README.md` for any remaining template-specific wording
  (e.g. phrasing that describes the template repository rather than the user's own repository,
  such as "configuration template" or "This template imports" in the introduction)
  and adjust it to reflect that this is now the user's personal configuration repository.

## 8. Clean up the setup skill (opt-in)

Ask whether to remove this skill now that setup is complete, recommending yes.
This concerns `repo-setup` only; leave `customize` and `sync-template` in place, since both stay useful afterwards.
If yes:

- Delete the `.agents/skills/repo-setup/` directory and the `.claude/skills/repo-setup` symlink,
  and remove `.agents/` and `.claude/` entirely if they are empty afterwards.
  Delete them with `rm`, not `git rm`, and leave the index alone (no `git reset` either),
  so that nothing the user has staged is affected.
- Remove the `repo-setup` entry from the "Agent Skills" section of `README.md`, since it points to the deleted skill.
- Remove the `.agents/**` and `.claude/**` entries from `REUSE.toml` if no other skills remain there.

## 9. Wrap up

Show a summary of everything that was changed or skipped.

Then mention what the user can do outside the repository, as options rather than required steps:

- Requiring status checks is optional, and possible only where the GitHub plan supports it for this repository.
  To have checks block merging, require `Check CI results` and `Check test results`
  in a branch ruleset for the default branch (see "Required Status Checks" in `README.md`).
- Judge from the repository as it stands, not from which steps ran this time,
  whether `Lint pull request title` (its job in `.github/workflows/manage-pull-requests.yaml` is uncommented)
  and `Lint REUSE compliance` (`.github/workflows/lint-reuse-compliance.yaml` is present without the `if` guard)
  are enabled.
  Name the enabled ones, and add that they come from workflows outside CI and Test and have to be required separately,
  and that a ruleset can select them only once the changes that enable them are on the default branch
  and each workflow has run with them.
  `Lint pull request title` runs on pull requests only, so it appears with the next pull request after that.
  Do not suggest requiring them before then.

Then check whether `prek` is on `PATH`, or failing that, whether `uv` is available to run it as `uvx prek`.
If neither is, tell the user that checking the edited files with the hooks is skipped because neither is available,
and that the `run-prek-hooks` CI job runs them on the pull request.

Otherwise, ask whether to run `prek run --all-files --skip no-commit-to-branch` (or the same via `uvx prek`)
to verify the edited files pass the hooks (`no-commit-to-branch` must be skipped when working on `main`),
recommending yes, and run it only on an explicit yes.
Without `nix` on `PATH`, also skip `nixfmt`, `deadnix`, and `statix`, which call it,
and say so when asking, adding that the `run-prek-hooks` CI job runs them on the pull request.
Do not run the hooks at any earlier point of the setup either:
some of them, such as `rumdl-check` and `pretty-format-json`, fix files in place.
Leave all changes uncommitted; committing and pushing are up to the user unless explicitly requested.
