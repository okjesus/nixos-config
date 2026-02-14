# okjesus nixos configuration

{ config, pkgs, ... }:

let
  # Import the unstable Nixpkgs channel to access newer packages.
  # This fetchTarball URL points to the unstable branch.
  unstable = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    config = {
      # This is optional, but allows for unfree packages if needed.
      allowUnfree = true;
    };
  };
in
{
  # automatic upgrades
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # packages
  environment.systemPackages = with pkgs; [
    # stable packages
    usbutils
    lshw
    vim
    emacs
    git
    tree
    neofetch
    fuzzel
    alacritty
    zellij
    mako
    swaybg
    waybar
    swayidle
    greetd.greetd
    pciutils
    nautilus
    wofi
    pavucontrol
    networkmanagerapplet
    signal-desktop
    obs-studio
    obs-studio-plugins.obs-pipewire-audio-capture
    pipewire
    dbus-broker
    vscode
    v4l-utils
    vulkaninfo
    curl
    gnupg
    zip
    make
    maven
    javaPackages.compiler.openjdk8
    ungoogled-chromium
    steam
  ] ++ (with unstable; [
    # unstable packages
    wlgreet
  ]);

  # environment variables
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "niri";
  };

  # greetd
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.niri}/bin/niri --config /etc/niri/config.kdl --session";
        user = "okjesus";
      };
    };
  };

  # gnome
  services.xserver.desktopManager.gnome.enable = true;

  # niri setup
  programs.niri.enable = true;

  # steam
  programs.steam.enable = true

  # network manager
  networking.networkmanager.enable = true;

  # pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pipewire.wireplumber.enable = true;

  # rtkit
  security.rtkit.enable = true;
  
  # dbus
  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.dbus-broker ];

  # xdg portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config = {
      common = {
        default = [ "wlr" ];
      };
      niri = {
        default = [ "wlr" ];
        # Use gnome for screencasting specifically
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      };
    };
  };
  

  # Enable the GNOME Virtual File System for network and trash support.
  services.gvfs.enable = true;

  # Fonts
  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
  ]; 

  # obs
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
  }; 
  security.polkit.enable = true;
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];

  # overlays
  nixpkgs.overlays = [
    (self: super: {
      gnome-control-center = super.gnome-control-center.overrideAttrs (old: {
        postInstall = old.postInstall or "" + ''
          wrapProgram "$out/bin/gnome-control-center" \
            --set XDG_CURRENT_DESKTOP GNOME
        '';
      });
    })
  ];
}
