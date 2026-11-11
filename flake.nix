# SPDX-FileCopyrightText: 2026 Intelligent Space Systems Laboratory, The University of Tokyo
# SPDX-FileCopyrightText: 2026 Riki Nakamura
#
# SPDX-License-Identifier: MIT OR Apache-2.0

{
  description = "Personal Home Manager configuration template for the ISSL environment";

  inputs = {
    issl.url = "github:ut-issl/issl-environment/v0.11.2";
    nixpkgs.follows = "issl/nixpkgs";
    home-manager.follows = "issl/home-manager";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      issl,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      mkPkgs = system: import nixpkgs { inherit system; };
      requireEnv =
        name:
        let
          value = builtins.getEnv name;
        in
        if value != "" then
          value
        else
          throw "Environment variable ${name} is required. Run Home Manager with --impure.";
      defaultSystem =
        builtins.currentSystem
          or (throw "builtins.currentSystem is required. Run Home Manager with --impure.");
      mkHomeConfiguration =
        {
          system ? defaultSystem,
          username ? requireEnv "USER",
          homeDirectory ? requireEnv "HOME",
          enableDesktop ? false,
          extraModules ? [ ],
        }:
        let
          pkgs = mkPkgs system;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            issl.homeModules.default
            ./home-modules
            {
              local.desktop.enable = enableDesktop;
              home = {
                inherit username homeDirectory;
                stateVersion = "26.05";
              };
            }
          ]
          ++ extraModules;
        };
      mkCheckArgs =
        system: args:
        {
          inherit system;
          username = "user";
          homeDirectory = "/tmp/user-home";
        }
        // args;
      mkCheck = system: args: (mkHomeConfiguration (mkCheckArgs system args)).activationPackage;
    in
    {
      packages = forAllSystems (system: {
        default = home-manager.packages.${system}.home-manager;
        inherit (home-manager.packages.${system}) home-manager;
      });

      homeConfigurations = {
        user = mkHomeConfiguration { };
        user-desktop = mkHomeConfiguration { enableDesktop = true; };
      };

      lib = {
        inherit mkCheck;
      };

      formatter = forAllSystems (system: (mkPkgs system).nixfmt);

      checks = forAllSystems (
        system:
        let
          mkConfig = args: (mkHomeConfiguration (mkCheckArgs system args)).config;
        in
        {
          home = mkCheck system { };
          home-desktop = mkCheck system { enableDesktop = true; };
          home-bash-only = mkCheck system { extraModules = [ { issl.zsh.enable = false; } ]; };
          home-desktop-gpu = mkCheck system {
            enableDesktop = true;
            extraModules = [ { targets.genericLinux.gpu.enable = true; } ];
          };
          desktop-axis =
            assert nixpkgs.lib.assertMsg
              (!(mkConfig { }).local.desktop.enable && (mkConfig { enableDesktop = true; }).local.desktop.enable)
              "local.desktop.enable is switched by the configuration you apply, not by a definition in a module.";
            (mkPkgs system).emptyFile;
        }
      );
    };
}
