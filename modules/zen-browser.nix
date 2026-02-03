self:
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.zen-browser;
in {
  options.programs.zen-browser = {
    enable = lib.mkEnableOption "Zen Browser (stable)";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.system}.zen-browser-stable-bin;
      defaultText = "inputs.<name>.packages.${pkgs.system}.zen-browser-stable-bin";
      description = "Zen Browser package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
