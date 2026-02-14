# jephthah specific configuration

{ config, pkgs, ...}:

{
  # enable graphics acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # packages
  nixpkgs.config.allowUnfree = true;
}
