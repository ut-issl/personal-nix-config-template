# LaTeX

[TeX Live](https://tug.org/texlive/) is the distribution that provides LaTeX and the packages documents load.
This recipe installs TeX Live with Japanese support and [latexmk](https://ctan.org/pkg/latexmk),
and gives latexmk a configuration file.

## Fragments

- `latex.nix` — add as `home-modules/latex/latex.nix`.

## The TeX Live installation

`pkgs.texliveSmall.withPackages` installs the small scheme of TeX Live,
together with the collections and packages in the list:

- `collection-bibtexextra` brings bibliography packages and tools, such as `biblatex` and `biber`.
- `collection-langjapanese` brings Japanese support, such as `luatexja` and `jlreq`.
- `collection-latexextra` brings a large set of additional LaTeX packages, such as `cleveref` and `enumitem`.
- `collection-mathscience` brings packages for mathematics and the sciences, such as `siunitx` and `physics`.
- `latexmk` adds latexmk, which the small scheme leaves out.

Add a package to the list by its TeX Live name, which is usually its [CTAN](https://ctan.org) name,
such as `ps.latexindent`.
Replace the whole expression with `pkgs.texliveFull` to install everything, at more than twice the size.

## The latexmk configuration

`xdg.configFile` writes the configuration to `~/.config/latexmk/latexmkrc`, where latexmk looks for it.
The settings in the fragment are one taste, not a requirement:

- `$pdf_mode = 4` builds PDF files with LuaLaTeX.
- `$lualatex` adds SyncTeX data, keeps LuaLaTeX from stopping for input on an error, and reports errors as `file:line:`.
- `$out_dir = 'build'` writes the PDF file and the auxiliary files into `build/`.
- `$bibtex` runs `upbibtex`, which also handles Japanese bibliography styles, in place of `bibtex`.

Adjust them to your own preferences.
