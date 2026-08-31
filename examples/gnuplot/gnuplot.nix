# Add this file as `home-modules/user/gnuplot.nix`.

{ pkgs, ... }:

{
  home.packages = [ pkgs.gnuplot ];

  xdg.configFile."gnuplot/gnuplotrc".text = ''
    set mxtics
    set mytics
    set mztics
    set grid xtics ytics ztics mxtics mytics mztics
    set xzeroaxis
    set yzeroaxis
    set zzeroaxis
  '';
}
