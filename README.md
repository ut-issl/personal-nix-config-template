# repository-template

General-purpose repository template for the ISSL organization.

## [Required] Configure CODEOWNERS

You must update [.github/CODEOWNERS](.github/CODEOWNERS) right after creating a repository from this template.

- Uncomment the default `*` line and replace `@your-username` with the actual owner —
  a real user (`@person`) or a team (`@ut-issl/<team-slug>`).
- Add path-specific overrides as needed, for example:

  ```text
  .github/        @infra-manager
  docs/           @docs-manager
  ```

See the [GitHub docs](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
for the full syntax.

## Pre-commit Setup

This template uses [prek](https://prek.j178.dev), a faster drop-in replacement for [pre-commit](https://pre-commit.com).

```console
prek install --hook-type pre-commit --hook-type pre-push
```

If you prefer `pre-commit`, substitute `pre-commit` for `prek` in the command above.

## Opt-in Features

By default only `lint-gh-actions` (GitHub Actions workflow lint) and `check-prek` (runs the pre-commit hooks)
run on PRs; everything else is disabled.
Enable any of the below if you want them.

### Additional CI Jobs

The following jobs are commented out in [ci.yaml](.github/workflows/ci.yaml).
Uncomment the corresponding block to enable each one.
Each job runs only when the relevant files change.

- [`validate-renovate-config`](.github/workflows/ci.yaml#L105-L129) — validate the Renovate config
- [`lint-markdown`](.github/workflows/ci.yaml#L131-L176) — lint Markdown files
- [`lint-json5`](.github/workflows/ci.yaml#L178-L214) — lint JSON5 files
- [`lint-toml`](.github/workflows/ci.yaml#L216-L289) — lint and format TOML files
- [`lint-yaml`](.github/workflows/ci.yaml#L291-L325) — lint YAML files
- [`check-typos`](.github/workflows/ci.yaml#L343-L372) — check for typos

### Conventional Commits Enforcement (Commitizen)

Enforces [Conventional Commits](https://www.conventionalcommits.org) on commit messages and PR titles
via [commitizen](https://github.com/commitizen-tools/commitizen).
Once enabled, all commits and PR titles must follow the spec.
Linting the PR title is especially useful with squash merging,
since the PR title becomes the subject of the squashed commit by default.

Uncomment both blocks:

- [`lint-commit-messages` in ci.yaml](.github/workflows/ci.yaml#L374-L397)
- [`lint-pr-title` in manage-pull-requests.yaml](.github/workflows/manage-pull-requests.yaml#L27-L42)

To author Conventional Commits interactively:

```console
uv tool install commitizen
cz commit
```

### Renovate

[Renovate](https://docs.renovatebot.com) is preconfigured in [.github/renovate.json5](.github/renovate.json5)
to track Action SHAs, pinned tool versions inside [ci.yaml](.github/workflows/ci.yaml), and pre-commit hooks.
To opt in, remove the `enabled: false,` line at [renovate.json5#L3](.github/renovate.json5#L3)
(or change it to `true`) and make sure the Renovate GitHub App is installed for the repository.
