# Examples

Optional setups that this template does not apply by default.

Each subdirectory is one recipe.
Read its `README.md` first: it says what the recipe does and what it needs outside this repository,
such as a font or a terminal setting.

A recipe is made of Nix fragments named after the module they belong to.
`shell.nix` means "add these lines to `home-modules/user/shell.nix`", which already exists.
A name with no counterpart under `home-modules/user/` is a module you add yourself.

Take the lines into your own modules rather than the files themselves:
the first line of a fragment names its destination and is not part of the setting.
The fragments carry no SPDX header, and MIT-0 asks for none to be carried over when you adopt one.
If your repository enforces REUSE compliance,
give the module you end up with a header of the same shape as the other files under `home-modules/user/`.

Every fragment is evaluated by `nix flake check`,
so a recipe that no longer works with the shared configuration fails there.

## Recipes

- [`gnuplot`](gnuplot/) — install [gnuplot](http://www.gnuplot.info) with a startup file of plotting defaults.
- [`starship`](starship/) — replace the shared prompt with [Starship](https://starship.rs).
