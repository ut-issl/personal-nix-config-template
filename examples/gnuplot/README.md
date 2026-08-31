# gnuplot

[gnuplot](http://www.gnuplot.info) plots data and functions from the command line.
This recipe installs it and gives it a startup file that sets the defaults you would otherwise repeat in every plot.

## Fragments

- `gnuplot.nix` — add as `home-modules/user/gnuplot.nix`.

## The startup file

gnuplot reads `$XDG_CONFIG_HOME/gnuplot/gnuplotrc` on startup, after its system-wide initialization files.
The commands in it apply to every session, interactive or scripted, and a script can still override any of them.

The settings in the fragment are one taste, not a requirement:

- `set mxtics`, `set mytics` and `set mztics` put minor tick marks between the labelled ones.
- `set grid` draws grid lines at both the major and the minor ticks of all three axes.
- `set xzeroaxis`, `set yzeroaxis` and `set zzeroaxis` draw the lines through the origin,
  which are otherwise invisible unless an axis happens to sit there.

Adjust the commands to your own preferences, or drop them and keep the package alone.
`help mxtics`, `help grid` and `help zeroaxis` inside gnuplot describe each of them.

## Interactive terminal

`pkgs.gnuplot` is built with the `x11` terminal and without the Qt and wxWidgets ones,
so an interactive plot needs a display that X11 can reach.
Replace the package with `pkgs.gnuplot_qt` if you prefer the `qt` terminal.
