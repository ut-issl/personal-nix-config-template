# Add this file as `home-modules/claude-code/claude-code.nix`, with `CLAUDE.md`, `rules/` and `skills/` beside it.

{
  programs.claude-code = {
    enable = true;
    context = ./CLAUDE.md;
    rulesDir = ./rules;
    skills = ./skills;
  };
}
