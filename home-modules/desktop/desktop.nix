# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
# SPDX-FileCopyrightText: 2026 Riki Nakamura
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{ config, lib, ... }:

{
  config = lib.mkIf config.local.desktop.enable {
    # Settings for a host used through its graphical desktop, applied by `.#user-desktop`.
    # Uncomment the line below once something installed here renders through OpenGL;
    # it asks for a one-time privileged setup on each machine.
    # See "Install Desktop Applications" in `README.md`.

    # targets.genericLinux.gpu.enable = true;
  };
}
