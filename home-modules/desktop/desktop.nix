# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
# SPDX-FileCopyrightText: 2026 Riki Nakamura
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{ config, lib, ... }:

{
  config = lib.mkIf config.local.desktop.enable {
    # Settings for a host used through its graphical desktop, applied by `.#user-desktop`.
    # The line below is for applications installed here that render through OpenGL;
    # it needs a one-time privileged setup on each machine.
    # See "Install Desktop Applications" in `README.md`.

    # targets.genericLinux.gpu.enable = true;
  };
}
