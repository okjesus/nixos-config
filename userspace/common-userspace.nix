# common-userspace nixos configuration

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
  awww-flake = builtins.getFlake "git+https://codeberg.org/LGFae/awww";
  awww-pkg = awww-flake.packages.${pkgs.stdenv.hostPlatform.system}.awww;
  protonGeCompat = pkgs.runCommand "proton-ge-bin-compat" { nativeBuildInputs = [ pkgs.coreutils  ]; } ''
    mkdir -p "$out"
    install -m 0644 ${pkgs.proton-ge-bin} "$out/proton-ge-bin"
  '';
in
{
  # automatic upgrades
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # packages
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
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
    greetd
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
    vscodium
    v4l-utils
    vulkan-tools
    curl
    gnupg
    zip
    git-repo
    pass
    pinentry-curses
    curl
    zip
    unzip
    maven
    javaPackages.compiler.openjdk8
    ungoogled-chromium
    steam
    xwayland-satellite
    blender
    parted
    blueman
    zsh
    oh-my-posh
    awww-pkg
    wireguard-tools
    protonvpn-gui
    fcitx5
    fcitx5-mozc
    qt6Packages.fcitx5-chinese-addons
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

  # sddm
  services.displayManager = {
    gdm = {
    	enable = true;
    	wayland = true;
        banner = "Behold the Lamb of God.";
        autoSuspend = true;
    };
    autoLogin = {
    	enable = true;
	user = "jesus";
    };
  };

  # zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellInit = ''
      eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/spaceship.omp.json)"
    '';
  };
  environment.shells = [ pkgs.zsh ];

  users.defaultUserShell = pkgs.zsh;
  
  # blueman
  services.blueman.enable = true;

  # niri setup
  programs.niri.enable = true;

  # steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [ 
      protonGeCompat 
    ];
  };

  # networking
  networking.firewall.checkReversePath = false;
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
  
  # enable the GNOME Virtual File System for network and trash support.
  services.gvfs.enable = true;

  # fonts
  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
    noto-fonts
    openmoji-color
    ipafont
    kochi-substitute
  ];

  fonts.fontconfig = {
    defaultFonts = {
      monospace = [
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono"
        "Noto Sans Japanese"
        "Noto Sans Simplified Chinese"
        "Noto Sans Korean"
        "Noto Sans Traditional Chinese"
      ];

      serif = [
        "Noto Serif"
        "Noto Serif Japanese"
        "Noto Serif Korean"
        "Noto Serif Traditional Chinese"
        "Noto Serif Simplified Chinese"
      ];

      sansSerif = [
        "Noto Sans"
        "Noto Sans Korean"
        "Noto Sans Traditional Chinese"
        "Noto Sans Simplified Chinese"
      ];
      emoji = [ "OpenMoji Color" ];
    };
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
        fcitx5-mozc
        qt6Packages.fcitx5-chinese-addons
    ];
  };

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

  # pinentry
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

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
