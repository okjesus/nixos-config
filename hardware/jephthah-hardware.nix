# jephthah specific configuration

{ config, pkgs, ...}:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
	FastConnectable = true;
      };
      Policy = {
	AutoEnable = true;
      };
    };  
  };

  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "drm.edid_firmware=card1-HDMI-A-1:edid/dell-monitor-u2723qx-edid.bin"
      "drm.edid_firmware=card1-HDMI-A-2:edid/dell-monitor-u2723qx-edid.bin"
      "video=card1-HDMI-A-1:e"
      "video=card1-HDMI-A-2:e"
    ];
  };

  hardware.firmware = [
  (
    pkgs.runCommand "dell-monitor-u2723qx-edid.bin" {} ''
      mkdir -p $out/lib/firmware/edid
      cp ${./monitors/dell-monitor-u2723qx-edid.bin} $out/lib/firmware/edid/dell-monitor-u2723qx-edid.bin
    ''
  )];
  
  services.xserver.videoDrivers = [ "amdgpu" ];

  # enable graphics acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # packages
  nixpkgs.config.allowUnfree = true;
}
