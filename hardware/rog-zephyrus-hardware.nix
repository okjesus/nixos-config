# rog zephyrus specific configuration

{ config, pkgs, ...}:

{
  # enable graphics acceleration
  hardware.graphics = {
    enable = true;
  };

  # packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    blackmagic-desktop-video
  ];

  # Enable the Blackmagic Decklink driver hardware support
  hardware.decklink.enable = true;

  # load nvidiq driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  
  hardware.nvidia = {
    # mode setting is required
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the Nvidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver)
    # Support is limited to the Turing and later architectures. Full list of
    # supporte GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only avaailable from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # offload
    prime = {
      # Make sure to use the correct Bus ID values for your system!
      amdgpuBusId = "PCI:04:00:0";
      nvidiaBusId = "PCI:01:00:0";
      # Offload
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
