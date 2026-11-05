# Claude Code

[Claude Code](https://code.claude.com/docs) is a coding agent that works in your terminal.
This recipe installs it through Home Manager.
Running it needs a Claude account, which `claude` asks you to sign in with on its first run.

## Fragments

- `claude-code.nix` — add as `home-modules/claude-code/claude-code.nix`.

## The shared configuration

The shared ISSL environment passes its package management practices to Claude Code as a rule,
so this recipe adds none of its own.
