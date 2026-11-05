# PDF Tools

[qpdf](https://qpdf.readthedocs.io) merges, splits, rotates and decrypts PDF files from the command line,
and [PDF Arranger](https://github.com/pdfarranger/pdfarranger) merges, splits and rotates them
through a graphical interface where you drag pages into a new order.
This recipe installs both in a module named after their purpose, with the graphical one on a desktop host alone.

## Fragments

- `pdf.nix` — add as `home-modules/pdf/pdf.nix`.

## Command-line and graphical tools

qpdf is installed on every host, including WSL and headless servers.
PDF Arranger is only worth installing on a host you use graphically,
so the fragment lists it under `lib.mkIf config.local.desktop.enable`,
which sends it to `.#user-desktop` and keeps it out of `.#user`.

The graphical tool stays in this module rather than in `home-modules/desktop/desktop.nix`,
because this module already covers its subject.
Add the next PDF tool here as well, under the gate if it is graphical.

PDF Arranger renders without OpenGL, so the recipe leaves `targets.genericLinux.gpu.enable` alone.
A graphical tool that does render through OpenGL needs it,
as [Install Desktop Applications](../../README.md#install-desktop-applications) describes.
