# Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/).

## Format

```text
<type>[(scope)][!]: <description>

[body]

[footer(s)]
```

- `scope` is optional.
  It MUST be a noun describing a section of the codebase, in parentheses (e.g. `feat(parser): add array parsing`).
- `!` is optional and indicates a breaking change (see below).
- `description` is in imperative mood, no trailing period.
- `body` is optional, MUST start one blank line after the description, and MAY span multiple paragraphs.
- One or more `footer`s MAY follow one blank line after the body.
- Type/scope MUST be lowercase.

## Allowed Types

| Type       | Purpose                                                                                                                         | SemVer |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------- | ------ |
| `feat`     | New feature                                                                                                                     | MINOR  |
| `fix`      | Bug fix                                                                                                                         | PATCH  |
| `refactor` | Code change that neither fixes a bug nor adds a feature                                                                         | —      |
| `perf`     | Performance improvement                                                                                                         | —      |
| `style`    | Formatting, whitespace, semicolons — no code meaning change                                                                     | —      |
| `docs`     | Documentation only                                                                                                              | —      |
| `test`     | Add or fix tests                                                                                                                | —      |
| `build`    | Build system or external deps. Use `deps` / `deps-dev` scope for dependency updates; other scope examples: `docker`, `cargo`, … | —      |
| `ci`       | CI configuration                                                                                                                | —      |
| `chore`    | Other maintenance                                                                                                               | —      |

Notes:

- `docs` is strictly for documentation files (README, `docs/`, code comments).
  A document that is itself the deliverable (e.g. a Typst/LaTeX paper or slide source) is content, not documentation —
  use `feat`, `fix`, `chore`, etc. as appropriate.

## Self-Containment

Keep each commit self-contained within its repository.
Do not reference other repositories or their PRs/issues in the commit message unless explicitly instructed.

## Footers

Footers follow the [Git trailer convention](https://git-scm.com/docs/git-interpret-trailers), on which Conventional Commits footers are based.

Each footer is `Token: value`.
The token is capitalized first letter only and uses `-` in place of whitespace (e.g. `Signed-off-by`, `Reviewed-by`, `Refs`).
The sole exception is `BREAKING CHANGE`, which MUST be uppercase and keeps the whitespace (not a hyphen).

Multiple footers form a single contiguous block — **do NOT insert blank lines between footers**.

### Footer Order

Use the following semantic order:

1. **`BREAKING CHANGE`** — breaking change declaration (if any).
2. **References** — `Closes`, `Fixes`, `Refs`, … (what this commit relates to).
3. **Attribution / Review** — `Co-authored-by`, `Reported-by`, `Suggested-by`, `Reviewed-by`,
   `Acked-by`, `Tested-by`, … (who was involved, in causal order where meaningful).
4. **`Signed-off-by`** — DCO sign-off.

Example with multiple footers:

```text
BREAKING CHANGE: clients must migrate to /v2 endpoints.
Closes: #109
Refs: #123
Co-authored-by: Alice <alice@example.com>
Reviewed-by: Bob <bob@example.com>
Signed-off-by: Carol <carol@example.com>
```

## Breaking Changes

A breaking change correlates with MAJOR in SemVer and can be combined with any type.
Indicate it with both:

- Header: append `!` immediately before `:` (e.g. `feat(api)!: drop v1`).
- Footer: `BREAKING CHANGE: <description>`.

## Examples

```text
feat(auth): add password reset flow
```

```text
fix: handle null user in session lookup
```

```text
refactor(api): extract validation into middleware
```

```text
build(deps): update dependency tokio to 1.40
```

```text
build(deps-dev):update dependency ruff to 0.15.13
```

```text
feat(api)!: remove deprecated v1 endpoints

BREAKING CHANGE: clients must migrate to /v2 endpoints.
```
