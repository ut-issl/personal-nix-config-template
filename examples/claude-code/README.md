# Claude Code

[Claude Code](https://code.claude.com/docs) is a coding agent that works in your terminal.
This recipe installs it through Home Manager, together with instructions, rules, and a skill of your own.
Running it needs a Claude account, which `claude` asks you to sign in with on its first run.

## Fragments

- `claude-code.nix` — add as `home-modules/claude-code/claude-code.nix`.
- `CLAUDE.md`, `rules/`, and `skills/`, the files that `claude-code.nix` deploys —
  copy into `home-modules/claude-code/`, beside it.

## Instructions, rules, and skills

`programs.claude-code.context` links `CLAUDE.md` to `~/.claude/CLAUDE.md`,
the instructions that Claude Code reads in every session.
`programs.claude-code.rulesDir` links the contents of `rules/` into `~/.claude/rules/`,
which Claude Code also reads in every session.
`programs.claude-code.skills` links the contents of `skills/`, one directory per skill holding a `SKILL.md`,
into `~/.claude/skills/`.
Claude Code uses a skill when its description matches the task, or when you invoke it as `/<name>`.

The files in the recipe are one taste, not a requirement:

- `CLAUDE.md` keeps the conversation in your language and what Claude Code writes into a repository in English,
  and asks for concise answers.
- `rules/commit-messages.md` has Claude Code write commit messages that follow [Conventional Commits](https://www.conventionalcommits.org/).
- `rules/branch-naming.md` names branches after the same commit types.
- `skills/subagent-prompting` guides how Claude Code briefs the subagents it delegates work to.

Replace them with your own, or drop them and keep `enable` alone.

Home Manager links these files read-only, so edit them in your repository and re-apply.
Neither `/memory` nor a request to Claude Code can change them in place.

The shared ISSL environment puts its package management practices into `~/.claude/rules/` as `issl-environment.md`,
so give none of your rules that name.

For short content, `context`, `rules`, and `skills` also take inline text:

```nix
programs.claude-code.rules.shell = ''
  # Shell

  - Prefer `rg` to `grep` and `fd` to `find`.
'';
```

`context` takes either a file or inline text, `rules` and `rulesDir` cannot be set together,
and `skills` takes either a directory or inline entries, not both.

## What to leave to Claude Code

Leave `programs.claude-code.settings` unset, and `programs.claude-code.marketplaces` too, which writes the same file.
Either turns `~/.claude/settings.json` into a read-only file,
while Claude Code writes that file itself when you change a setting from inside it,
such as turning auto memory on or off in `/memory`, and those changes then fail.
