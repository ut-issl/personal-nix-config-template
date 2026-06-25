# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{ config, ... }:

let
  isslConfigHome = "${config.xdg.configHome}/issl";
in
{
  home.file.".python/.pythonrc.py".text = ''
    import runpy
    from pathlib import Path

    shared_pythonrc = Path("${isslConfigHome}/python/pythonrc.py")
    if shared_pythonrc.is_file():
        runpy.run_path(str(shared_pythonrc), run_name="__main__")

    # Add your personal interactive Python startup below.
    # The commented lines below are examples. Uncomment and adjust them if you want these preferences.

    # import math
    # import statistics as stats
  '';
}
