# Examples

Optional setups that this template does not apply by default.

Each subdirectory is one recipe.
Read its `README.md` first: it says what the recipe does and what it needs outside this repository,
such as a font or a terminal setting.

A recipe is made of Nix fragments named after the module they belong to.
`shell.nix` means "add these lines to `home-modules/shell/shell.nix`", which already exists.
A name with no module of its own under `home-modules/` is one you add as `<name>/<name>.nix`.

Take the lines into your own modules rather than the files themselves:
the first line of a fragment names its destination and is not part of the setting.
A recipe may also hold files that a fragment deploys, beside the fragment or in a directory of their own.
Copy them into your module directory as they are, since the fragment refers to them by a relative path.
The fragments and the files they deploy carry no SPDX header,
and MIT-0 asks for none to be carried over when you adopt them.
If your repository enforces REUSE compliance,
give the module you end up with a header of the same shape as the other modules under `home-modules/`.

Every fragment is evaluated by `nix flake check`, so a recipe that no longer works with the shared configuration fails there.

## Recipes

- [`claude-code`](claude-code/) — install [Claude Code](https://code.claude.com/docs) with instructions, rules, and a skill of your own.
- [`gnuplot`](gnuplot/) — install [gnuplot](http://www.gnuplot.info) with a startup file of plotting defaults.
- [`latex`](latex/) — install [TeX Live](https://tug.org/texlive/) with Japanese support and a latexmk configuration file.
- [`pdf`](pdf/) — install a command-line PDF tool on every host and a graphical one on a desktop host.
- [`starship`](starship/) — replace the shared prompt with [Starship](https://starship.rs).
